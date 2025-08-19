import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';


class RewarderTool extends GetxService{
  // GetX单例获取方式
  static RewarderTool get to => Get.find<RewarderTool>();

  loadRewardedVideo() async {
    await ATRewardedManager.loadRewardedVideo(
        placementID: AppAdConfig.rewarderPlacementID,
        extraMap: {
          ATRewardedManager.kATAdLoadingExtraUserDataKeywordKey(): '1234',
          ATRewardedManager.kATAdLoadingExtraUserIDKey(): '1234',
        });
  }

  rewardVideocheck() async{
    rewardedVideoReady();
    checkRewardedVideoLoadStatus();
    getRewardedVideoValidAds();
  }

  rewardedVideoReady() async {
    await ATRewardedManager
        .rewardedVideoReady(
      placementID: AppAdConfig.rewarderPlacementID,
    )
        .then((value) {
      Utils.logError('flutter：激励视频是否就绪：$value'); // 原"rewardedVideoReady"→"激励视频是否就绪"
    });
  }

  checkRewardedVideoLoadStatus() async {
    await ATRewardedManager
        .checkRewardedVideoLoadStatus(
      placementID: AppAdConfig.rewarderPlacementID,
    )
        .then((value) {
      Utils.logError('flutter：激励视频加载状态：$value'); // 原"checkRewardedVideoLoadStatus"→"激励视频加载状态"
    });
  }

  getRewardedVideoValidAds() async {
    await ATRewardedManager.getRewardedVideoValidAds(
      placementID: AppAdConfig.rewarderPlacementID,
    ).then((value) {
      Utils.logError('flutter：激励视频有效广告数量：$value'); // 原"getRewardedVideoValidAds"→"激励视频有效广告数量"
    });
  }

  showRewardedVideo() async {
    await ATRewardedManager
        .showRewardedVideo(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  showSceneRewardedAd() async {
    await ATRewardedManager
        .showSceneRewardedVideo(
      sceneID: AppAdConfig.rewarderSceneID,
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }
}