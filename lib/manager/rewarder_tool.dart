import 'dart:async';
import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/ad_log_collector.dart';
import 'package:base_object/utils/ad_log_formatter.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class RewarderTool extends GetxService {
  static RewarderTool get to =>
      Get.isRegistered<RewarderTool>()
          ? Get.find<RewarderTool>()
          : Get.put(RewarderTool());

  /// 激励视频加载
  loadRewardedVideoFlutter({userID = '', extra = ""}) async {
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

  Future<Map<dynamic, dynamic>> checkRewardedVideoLoadStatus() async {
    return ATRewardedManager.checkRewardedVideoLoadStatus(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  getRewardedVideoValidAds() async {
    await ATRewardedManager.getRewardedVideoValidAds(
      placementID: AppAdConfig.rewarderPlacementID,
    ).then((value) {
      Utils.logError('激励广告：激励视频有效广告数量：$value');
    });
  }

  showRewardedVideoFlutter() async {
    bool isOk = await Store.instance.canLookReward();
    if (!isOk) {
      return;
    }

    await ATRewardedManager.showRewardedVideo(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  StreamSubscription<ATRewardResponse>? _rewardedSubscription;

  rewardedAdListen() {
    if (_rewardedSubscription != null) {
      return;
    }
    _rewardedSubscription = ATListenerManager.rewardedVideoEventHandler.listen((
      value,
    ) {
      switch (value.rewardStatus) {
        case RewardedStatus.rewardedVideoDidFailToLoad:
          Utils.logError(
            "激励广告 加载失败 ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.rewardedFail(
              placementId: value.placementID.toString(),
              requestMessage: value.requestMessage,
              extraMap: value.extraMap,
            ),
          );
          break;
        case RewardedStatus.rewardedVideoDidFinishLoading:
          Utils.logError("激励广告 激励失败 ---- placementID: ${value.placementID}");
          EasyLoading.dismiss();
          break;
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
        case RewardedStatus.rewardedVideoDidRewardSuccess:
          Utils.logError(
            "激励广告 激励成功 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.rewardedSuccess(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
            ),
          );
          final AdInfo adInfo = AdInfo.fromTakuExtra(
            extraMap: value.extraMap,
            placementID: value.placementID.toString(),
            createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
            adType: AdInfo.typeRewarded,
          );
          Store.instance.addAdInfos(adInfo);
          CuToast.success(msg: "观看完成，已记录收益");
          loadRewardedVideoFlutter(
            userID: "${UserInfo.instance.userModel.id}",
            extra:
                "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
          );
          break;
        case RewardedStatus.rewardedVideoDidClose:
          Utils.logError(
            "激励广告 rewardedVideoDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        case RewardedStatus.rewardedVideoDidEndPlaying:
        case RewardedStatus.rewardedVideoDidFailToPlay:
        case RewardedStatus.rewardedVideoDidStartPlaying:
          break;
        case RewardedStatus.rewardedVideoDidClick:
          break;
        case RewardedStatus.rewardedVideoDidDeepLink:
          break;
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:
        case RewardedStatus.rewardedVideoDidAgainClick:
        case RewardedStatus.rewardedVideoUnknown:
          Utils.logError("激励广告 rewardedVideoUnknown");
          AdLogCollector.addLog(
            AdLogFormatter.rewardedFail(
              placementId: value.placementID.toString(),
              requestMessage: value.requestMessage,
              extraMap: value.extraMap,
            ),
          );
          break;
      }
    });
  }
}
