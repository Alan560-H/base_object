import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/ad_log_collector.dart';
import 'package:base_object/utils/ad_log_formatter.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

/// 首页横幅占位条展示用状态
enum HomeBannerSlotState { idle, loading, ready, failed }

class BannerTool extends GetxService {
  static BannerTool get to =>
      Get.isRegistered<BannerTool>()
          ? Get.find<BannerTool>()
          : Get.put(BannerTool());

  final Rx<HomeBannerSlotState> bannerSlotState = HomeBannerSlotState.idle.obs;

  /// 展示成功后间隔此时长再发起下一次 [loadBannerAd]（多次展示回调时仅最后一次生效）
  static const Duration _bannerReloadAfterShowDelay = Duration(seconds: 16);

  int _reloadAfterShowToken = 0;

  /// [logicalWidth] 屏宽逻辑像素，用于 320:50 比例；默认 [Get.width]
  Future<void> loadBannerWith(
    Map<dynamic, dynamic> extraMap, {
    double? logicalWidth,
  }) async {
    final double w = logicalWidth ?? Get.width;
    final double h = w * 50 / 320;
    final Map<dynamic, dynamic> merged = Map<dynamic, dynamic>.from(extraMap);
    merged[ATCommon.getAdSizeKey()] = ATBannerManager.createLoadBannerAdSize(
      w,
      h,
    );

    Utils.logError("横幅广告透传参数:$merged");
    bannerSlotState.value = HomeBannerSlotState.loading;
    try {
      await ATBannerManager.loadBannerAd(
        placementID: AppAdConfig.bannerPlacementID,
        extraMap: merged,
      );
    } catch (e, st) {
      bannerSlotState.value = HomeBannerSlotState.failed;
      Utils.logError("横幅 loadBannerAd 异常: $e $st");
    }
  }

  Future<bool> bannerAdReady() async {
    return await ATBannerManager.bannerAdReady(
      placementID: AppAdConfig.bannerPlacementID,
    );
  }

  getBannerValidAds() async {
    await ATBannerManager.getBannerValidAds(
      placementID: AppAdConfig.bannerPlacementID,
    ).then((value) {
      Utils.logError('横幅广告 getBannerValidAds: $value');
    });
  }

  checkBannerLoadStatus() async {
    await ATBannerManager.checkBannerLoadStatus(
      placementID: AppAdConfig.bannerPlacementID,
    ).then((value) {
      Utils.logError('横幅广告 checkBannerLoadStatus: $value');
    });
  }

  showBannerInRectangle() async {
    await ATBannerManager.showBannerInRectangle(
      placementID: AppAdConfig.bannerPlacementID,
      extraMap: {
        ATCommon.getAdSizeKey(): ATBannerManager.createLoadBannerAdSize(
          400,
          500,
          x: 0,
          y: 200,
        ),
      },
    );
  }

  showSceneBannerInRectangle() async {
    await ATBannerManager.showSceneBannerInRectangle(
      placementID: AppAdConfig.bannerPlacementID,
      sceneID: AppAdConfig.bannerSceneID,
      extraMap: {
        ATCommon.getAdSizeKey(): ATBannerManager.createLoadBannerAdSize(
          400,
          500,
          x: 0,
          y: 200,
        ),
      },
    );
  }

  Future<void> showAdInPosition() async {
    await ATBannerManager.showAdInPosition(
      placementID: AppAdConfig.bannerPlacementID,
      position: ATCommon.getAdATBannerAdShowingPositionBottom(),
    );
  }

  Future<void> showSceneBannerAdInPosition() async {
    await ATBannerManager.showSceneBannerAdInPosition(
      placementID: AppAdConfig.bannerPlacementID,
      sceneID: AppAdConfig.bannerSceneID,
      position: ATCommon.getAdATBannerAdShowingPositionBottom(),
      showCustomExt: '{"isShow":true}',
    );
  }

  removeBannerAd() async {
    await ATBannerManager.removeBannerAd(
      placementID: AppAdConfig.bannerPlacementID,
    );
  }

  hideBannerAd() async {
    await ATBannerManager.hideBannerAd(
      placementID: AppAdConfig.bannerPlacementID,
    );
  }

  afreshShowBannerAd() async {
    await ATBannerManager.afreshShowBannerAd(
      placementID: AppAdConfig.bannerPlacementID,
    );
  }

  readyStatus() async {
    await bannerAdReady();
    checkBannerLoadStatus();
    getBannerValidAds();
  }

  void _scheduleLoadNextBannerAfterShow() {
    final int token = ++_reloadAfterShowToken;
    unawaited(() async {
      await Future<void>.delayed(_bannerReloadAfterShowDelay);
      if (token != _reloadAfterShowToken) {
        return;
      }
      try {
        Utils.logError(
          '横幅展示满 ${_bannerReloadAfterShowDelay.inSeconds}s，发起下一条 loadBannerAd',
        );
        await loadBannerWith({}, logicalWidth: Get.width);
      } catch (e, st) {
        Utils.logError('横幅延时 reload 异常: $e $st');
      }
    }());
  }

  StreamSubscription<ATBannerResponse>? _bannerSubscription;

  /// 横幅广告监听
  void bannerListen() {
    if (_bannerSubscription != null) {
      return;
    }
    _bannerSubscription = ATListenerManager.bannerEventHandler.listen((value) {
      final CuNavBarController cuNavBarController =
          Get.isRegistered<CuNavBarController>()
              ? Get.find<CuNavBarController>()
              : Get.put(CuNavBarController());
      switch (value.bannerStatus) {
        case BannerStatus.bannerAdFailToLoadAD:
          bannerSlotState.value = HomeBannerSlotState.failed;
          AdLogCollector.addLog(
            AdLogFormatter.bannerFail(
              placementId: value.placementID.toString(),
              requestMessage: value.requestMessage,
              extraMap: value.extraMap,
            ),
          );
          break;
        case BannerStatus.bannerAdDidFinishLoading:
          Utils.logError(
            "横幅广告 bannerAdDidFinishLoading ---- placementID: ${value.placementID}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '加载完成',
            ),
          );
          bannerSlotState.value = HomeBannerSlotState.ready;
          showSceneBannerAdInPosition();
          break;
        case BannerStatus.bannerAdAutoRefreshSucceed:
          Utils.logError(
            "横幅广告 bannerAdAutoRefreshSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '自动刷新成功',
            ),
          );
          cuNavBarController.upDataADFn(value);
          break;
        case BannerStatus.bannerAdDidClick:
          Utils.logError(
            "横幅广告 bannerAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '点击',
            ),
          );
          break;
        case BannerStatus.bannerAdDidDeepLink:
          Utils.logError(
            "横幅广告 bannerAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: 'DeepLink（成功:${value.isDeeplinkSuccess}）',
            ),
          );
          break;
        case BannerStatus.bannerAdDidShowSucceed:
          Utils.logError(
            "横幅广告 bannerAdDidShowSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerSuccess(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
            ),
          );
          Store.instance.addAdInfos(
            AdInfo.fromTakuExtra(
              extraMap: value.extraMap,
              placementID: value.placementID.toString(),
              createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
              adType: AdInfo.typeBanner,
            ),
          );
          _scheduleLoadNextBannerAfterShow();
          break;
        case BannerStatus.bannerAdTapCloseButton:
          Utils.logError(
            "横幅广告 bannerAdTapCloseButton ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '点击关闭',
            ),
          );
          break;
        case BannerStatus.bannerAdAutoRefreshFail:
          Utils.logError(
            "横幅广告 bannerAdAutoRefreshFail ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerFail(
              placementId: value.placementID.toString(),
              requestMessage: value.requestMessage,
              extraMap: value.extraMap,
            ),
          );
          break;
        case BannerStatus.bannerAdUnknown:
          Utils.logError("横幅广告 bannerAdUnknown");
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '未知状态',
            ),
          );
          break;
      }
    });
  }
}
