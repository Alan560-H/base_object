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
  // GetX单例获取方式
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

  ///  使用以下代码获取广告状态（返回值类型为Map） key-value如下：
  /// 1、isLoading：是否正在加载
  /// 2、isReady：是否有广告缓存
  /// 3、adInfo：当前优先级最高的广告缓存信息
  Future<Map<dynamic, dynamic>> checkRewardedVideoLoadStatus() async {
    return ATRewardedManager.checkRewardedVideoLoadStatus(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  getRewardedVideoValidAds() async {
    await ATRewardedManager.getRewardedVideoValidAds(
      placementID: AppAdConfig.rewarderPlacementID,
    ).then((value) {
      Utils.logError(
        '激励广告：激励视频有效广告数量：$value',
      ); // 原"getRewardedVideoValidAds"→"激励视频有效广告数量"
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
  // 激励广告监听
  rewardedAdListen() {
    if (_rewardedSubscription != null) {
      return;
    }
    _rewardedSubscription = ATListenerManager.rewardedVideoEventHandler.listen((
      value,
    ) {
      switch (value.rewardStatus) {
        //广告加载失败
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
        //广告加载成功
        case RewardedStatus.rewardedVideoDidFinishLoading:
          Utils.logError("激励广告 激励失败 ---- placementID: ${value.placementID}");
          EasyLoading.dismiss();
          break;
        //激励成功（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
        //激励成功，建议在此回调中下发奖励
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

        //广告被关闭
        case RewardedStatus.rewardedVideoDidClose:
          Utils.logError(
            "激励广告 rewardedVideoDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告结束播放
        case RewardedStatus.rewardedVideoDidEndPlaying:
        //广告播放失败
        case RewardedStatus.rewardedVideoDidFailToPlay:
        //广告开始播放
        case RewardedStatus.rewardedVideoDidStartPlaying:
          break;
        //广告被点击
        case RewardedStatus.rewardedVideoDidClick:
          break;
        //Deeplink
        case RewardedStatus.rewardedVideoDidDeepLink:
          break;
        //广告开始播放（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
        //广告结束播放（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
        //广告播放失败（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:

        //广告被点击（只针对穿山甲的再看一个广告）
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
