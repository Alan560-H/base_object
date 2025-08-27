import 'dart:developer';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';


class BannerTool extends GetxService{
  static BannerTool get to => Get.find<BannerTool>();

  loadBannerWith(Map<dynamic,dynamic> extraMap) async {
    await ATBannerManager.loadBannerAd(
        placementID: AppAdConfig.bannerPlacementID,
        extraMap: extraMap);
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
          ATCommon.getAdSizeKey():
          ATBannerManager.createLoadBannerAdSize(400, 500, x: 0, y: 200),
        });
  }

  showSceneBannerInRectangle() async {
    await ATBannerManager.showSceneBannerInRectangle(
        placementID: AppAdConfig.bannerPlacementID,
        sceneID: AppAdConfig.bannerSceneID,
        extraMap: {
          ATCommon.getAdSizeKey():
          ATBannerManager.createLoadBannerAdSize(400, 500, x: 0, y: 200),
        });
  }

  showAdInPosition() async {
    await ATBannerManager.showAdInPosition(
        placementID: AppAdConfig.bannerPlacementID,
        position: ATCommon.getAdATBannerAdShowingPositionBottom());
  }
  showSceneBannerAdInPosition() async {
    await ATBannerManager.showSceneBannerAdInPosition(
        placementID: AppAdConfig.bannerPlacementID,
        sceneID: AppAdConfig.bannerSceneID,
        position: ATCommon.getAdATBannerAdShowingPositionBottom(), showCustomExt: '{"isShow":true}');
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
}
