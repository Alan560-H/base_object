import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/services/ads/banner_ad_upload_handler.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/services/ads/ad_log_collector.dart';
import 'package:base_object/services/ads/ad_log_formatter.dart';
import 'package:base_object/shared/config/screen_layout.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/widgets.dart';
import 'package:jiffy/jiffy.dart';

double _defaultLogicalWidth() => defaultLogicalWidth();

/// 首页横幅占位条展示用状态
enum HomeBannerSlotState { idle, loading, ready, failed }

class BannerTool extends ChangeNotifier {
  BannerTool({required AdStatsNotifier adStatsNotifier})
    : _adStatsNotifier = adStatsNotifier;

  final AdStatsNotifier _adStatsNotifier;

  static BannerTool get to => globalContainer.read(bannerToolProvider);

  /// 与 [loadBannerWith] 一致的 320:50 横幅高度。
  static double standardBannerHeight(double logicalWidth) =>
      logicalWidth * 50 / 320;

  /// 横幅播放中时，页面底部需预留高度（含安全区），避免列表被 SDK 横幅遮挡。
  double contentBottomInset(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    if (_bannerPlaybackPaused) return safeBottom;
    return standardBannerHeight(MediaQuery.sizeOf(context).width) + safeBottom;
  }

  HomeBannerSlotState _bannerSlotState = HomeBannerSlotState.idle;
  HomeBannerSlotState get bannerSlotState => _bannerSlotState;

  /// 未点「开始横幅」前为 true：不自动 load/show；用户开始后为 false，直至停止或加载失败
  bool _bannerPlaybackPaused = true;
  bool get bannerPlaybackPaused => _bannerPlaybackPaused;

  void _setBannerSlotState(HomeBannerSlotState value) {
    _bannerSlotState = value;
    notifyListeners();
  }

  void _setBannerPlaybackPaused(bool value) {
    _bannerPlaybackPaused = value;
    notifyListeners();
  }

  /// 停止横幅：移除原生横幅容器
  Future<void> pauseBannerPlayback() async {
    _setBannerPlaybackPaused(true);
    await removeBannerAd();
    _setBannerSlotState(HomeBannerSlotState.idle);
  }

  /// 开始横幅：load → DidFinishLoading → show
  Future<void> startBannerPlayback() async {
    _setBannerPlaybackPaused(false);
    await loadBannerWith({}, logicalWidth: _defaultLogicalWidth());
  }

  /// [logicalWidth] 屏宽逻辑像素，用于 320:50 比例
  Future<void> loadBannerWith(
    Map<dynamic, dynamic> extraMap, {
    double? logicalWidth,
  }) async {
    final double w = logicalWidth ?? _defaultLogicalWidth();
    final double h = standardBannerHeight(w);
    final Map<dynamic, dynamic> merged = Map<dynamic, dynamic>.from(extraMap);
    merged[ATCommon.getAdSizeKey()] = ATBannerManager.createLoadBannerAdSize(
      w,
      h,
    );

    Utils.logError("横幅广告透传参数:$merged");
    _setBannerSlotState(HomeBannerSlotState.loading);
    try {
      await ATBannerManager.loadBannerAd(
        placementID: AppAdConfig.bannerPlacementID,
        extraMap: merged,
      );
    } catch (e, st) {
      _setBannerSlotState(HomeBannerSlotState.failed);
      if (!_bannerPlaybackPaused) {
        _setBannerPlaybackPaused(true);
      }
      Utils.logError("横幅 loadBannerAd 异常: $e $st");
    }
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

  Future<void> showAdInPosition() async {
    await ATBannerManager.showAdInPosition(
      placementID: AppAdConfig.bannerPlacementID,
      position: ATCommon.getAdATBannerAdShowingPositionBottom(),
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

  StreamSubscription<ATBannerResponse>? _bannerSubscription;

  /// 横幅广告监听（换条由 SDK bannerAdAutoRefreshSucceed 负责）
  void bannerListen() {
    if (_bannerSubscription != null) {
      return;
    }
    _bannerSubscription = ATListenerManager.bannerEventHandler.listen((value) {
      switch (value.bannerStatus) {
        case BannerStatus.bannerAdFailToLoadAD:
          _setBannerSlotState(HomeBannerSlotState.failed);
          if (!_bannerPlaybackPaused) {
            _setBannerPlaybackPaused(true);
          }
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
          _setBannerSlotState(HomeBannerSlotState.ready);
          if (!_bannerPlaybackPaused) {
            // 非场景展示，仅用 placementID（与 AppAdConfig 一致）
            showAdInPosition();
          }
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
          _adStatsNotifier.addAdInfos(
            AdInfo.fromTakuExtra(
              extraMap: value.extraMap,
              placementID: value.placementID.toString(),
              createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
              adType: AdInfo.typeBanner,
            ),
          );
          handleBannerAdUpload(value);
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
          _adStatsNotifier.addAdInfos(
            AdInfo.fromTakuExtra(
              extraMap: value.extraMap,
              placementID: value.placementID.toString(),
              createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
              adType: AdInfo.typeBanner,
            ),
          );
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
