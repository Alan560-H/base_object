import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class RewarderTool extends GetxController {
  // GetX单例获取方式
  static RewarderTool get to =>
      Get.isRegistered<RewarderTool>()
          ? Get.find<RewarderTool>()
          : Get.put(RewarderTool());
  loadRewardedVideo({userID = '', extra = ""}) async {
    Utils.logError("初始化的userId:$userID,extra=$extra");
    await ATRewardedManager.loadRewardedVideo(
      placementID: AppAdConfig.rewarderPlacementID,
      extraMap: {
        ATRewardedManager.kATAdLoadingExtraUserDataKeywordKey(): extra,
        ATRewardedManager.kATAdLoadingExtraUserIDKey(): userID,
      },
    );
  }

  rewardVideocheck() async {
    rewardedVideoReady();
    checkRewardedVideoLoadStatus();
    getRewardedVideoValidAds();
  }

  Future<bool> rewardedVideoReady() async {
    return await ATRewardedManager.rewardedVideoReady(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  checkRewardedVideoLoadStatus() async {
    await ATRewardedManager.checkRewardedVideoLoadStatus(
      placementID: AppAdConfig.rewarderPlacementID,
    ).then((value) {
      Utils.logError(
        'flutter：激励视频加载状态：$value',
      ); // 原"checkRewardedVideoLoadStatus"→"激励视频加载状态"
    });
  }

  getRewardedVideoValidAds() async {
    await ATRewardedManager.getRewardedVideoValidAds(
      placementID: AppAdConfig.rewarderPlacementID,
    ).then((value) {
      Utils.logError(
        'flutter：激励视频有效广告数量：$value',
      ); // 原"getRewardedVideoValidAds"→"激励视频有效广告数量"
    });
  }

  showRewardedVideo() async {
    await ATRewardedManager.showRewardedVideo(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  showSceneRewardedAd() async {
    await ATRewardedManager.showSceneRewardedVideo(
      sceneID: AppAdConfig.rewarderSceneID,
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  StreamSubscription<ATRewardResponse>? _rewardedSubscription;
  // 激励广告监听
  rewardedAdListen() {
    _rewardedSubscription?.cancel();
    _rewardedSubscription = ATListenerManager.rewardedVideoEventHandler.listen((
      value,
    ) {
      HomeController homeController = Get.find<HomeController>();
      switch (value.rewardStatus) {
        //广告加载失败
        case RewardedStatus.rewardedVideoDidFailToLoad:
          Utils.logError(
            "flutter rewardedVideoDidFailToLoad ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          break;
        //广告加载成功
        case RewardedStatus.rewardedVideoDidFinishLoading:
          Utils.logError(
            "flutter rewardedVideoDidFinishLoading ---- placementID: ${value.placementID}",
          );
          break;
        //广告开始播放
        case RewardedStatus.rewardedVideoDidStartPlaying:
          Utils.logError(
            "flutter rewardedVideoDidStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告结束播放
        case RewardedStatus.rewardedVideoDidEndPlaying:
          Utils.logError(
            "flutter rewardedVideoDidEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告播放失败
        case RewardedStatus.rewardedVideoDidFailToPlay:
          Utils.logError(
            "flutter rewardedVideoDidFailToPlay ---- placementID: ${value.placementID} ---- errStr:${value.extraMap}",
          );
          break;
        //激励成功，建议在此回调中下发奖励
        case RewardedStatus.rewardedVideoDidRewardSuccess:
          Utils.logError(
            "flutter rewardedVideoDidRewardSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告被点击
        case RewardedStatus.rewardedVideoDidClick:
          Utils.logError(
            "flutter rewardedVideoDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //Deeplink
        case RewardedStatus.rewardedVideoDidDeepLink:
          Utils.logError(
            "flutter rewardedVideoDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          break;
        //广告被关闭
        case RewardedStatus.rewardedVideoDidClose:
          Utils.logError(
            "flutter rewardedVideoDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          loadRewardedVideo(
            userID: "${UserInfo.instance.userModel.id}",
            extra:
                "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
          );
          homeController.redBagOpen.value = false;
          break;

        //广告开始播放（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
          Utils.logError(
            "flutter rewardedVideoDidAgainStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告结束播放（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
          Utils.logError(
            "flutter rewardedVideoDidAgainEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告播放失败（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:
          Utils.logError(
            "flutter rewardedVideoDidAgainFailToPlay ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //激励成功（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          Utils.logError(
            "flutter rewardedVideoDidAgainRewardSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告被点击（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainClick:
          Utils.logError(
            "flutter rewardedVideoDidAgainClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );

        case RewardedStatus.rewardedVideoUnknown:
          Utils.logError("flutter rewardedVideoUnknown");
          break;
      }
    });
  }
}
