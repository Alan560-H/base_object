import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BannerTool extends GetxController {
  static BannerTool get to =>
      Get.isRegistered<BannerTool>()
          ? Get.find<BannerTool>()
          : Get.put(BannerTool());

  loadBannerWith(Map<dynamic, dynamic> extraMap) async {
    Utils.logError("横幅广告透传参数:$extraMap");
    await ATBannerManager.loadBannerAd(
      placementID: AppAdConfig.bannerPlacementID,
      extraMap: extraMap,
    );
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
      Utils.logError('flutter getBannerValidAds: $value');
    });
  }

  checkBannerLoadStatus() async {
    await ATBannerManager.checkBannerLoadStatus(
      placementID: AppAdConfig.bannerPlacementID,
    ).then((value) {
      Utils.logError('flutter checkBannerLoadStatus: $value');
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

  showAdInPosition() async {
    await ATBannerManager.showAdInPosition(
      placementID: AppAdConfig.bannerPlacementID,
      position: ATCommon.getAdATBannerAdShowingPositionBottom(),
    );
  }

  showSceneBannerAdInPosition() async {
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

  StreamSubscription<ATBannerResponse>? _bannerSubscription;

  /// 横幅广告监听
  bannerListen() {
    _bannerSubscription?.cancel();
    _bannerSubscription = ATListenerManager.bannerEventHandler.listen((value) {
      CuNavBarController cuNavBarController = Get.find<CuNavBarController>();
      switch (value.bannerStatus) {
        //广告加载失败
        case BannerStatus.bannerAdFailToLoadAD:
          Utils.logError(
            "flutter bannerAdFailToLoadAD ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          cuNavBarController.setHeight(60.h);
          break;
        //广告加载成功
        case BannerStatus.bannerAdDidFinishLoading:
          Utils.logError(
            "flutter bannerAdDidFinishLoading ---- placementID: ${value.placementID}",
          );
          showAdInPosition();

          cuNavBarController.setHeight(110.h);
          break;
        //广告自动刷新成功
        case BannerStatus.bannerAdAutoRefreshSucceed:
          Utils.logError(
            "flutter bannerAdAutoRefreshSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          cuNavBarController.upDataADFn(value);
          break;
        //广告被点击
        case BannerStatus.bannerAdDidClick:
          Utils.logError(
            "flutter bannerAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //Deeplink
        case BannerStatus.bannerAdDidDeepLink:
          Utils.logError(
            "flutter bannerAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          break;
        //广告展示成功
        case BannerStatus.bannerAdDidShowSucceed:
          Utils.logError(
            "flutter bannerAdDidShowSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告关闭按钮被点击
        case BannerStatus.bannerAdTapCloseButton:
          Utils.logError(
            "flutter bannerAdTapCloseButton ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告自动刷新失败
        case BannerStatus.bannerAdAutoRefreshFail:
          Utils.logError(
            "flutter bannerAdAutoRefreshFail ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          cuNavBarController.setHeight(60.h);
          break;
        case BannerStatus.bannerAdUnknown:
          Utils.logError("flutter bannerAdUnknown");
          break;
      }
    });
  }
}
