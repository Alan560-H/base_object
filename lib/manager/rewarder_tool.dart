import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:get/get.dart';

import 'native_tool.dart';

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
        '激励广告：激励视频加载状态：$value',
      ); // 原"checkRewardedVideoLoadStatus"→"激励视频加载状态"
    });
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

  /// 领取存钱罐奖励
  Future<void> checkClaim() async {
    if (Get.isRegistered<Api>()) {
      BackModel backModel = await Api.to.getAdAmount();
      Utils.logError("领取存钱罐奖励返回数据：${backModel.toJson()}");
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: "存钱罐领取成功");
        UserInfo.instance.getUserInfoFn();
        Store.instance.setIsOpenClaim(false);
        CuCircularProgressController.to.resetProgressTimer();
        NativeTool.to.removeNativeAd();
        NativeTool.to.loadNativeWith();
        Get.back();
      }
    }
  }

  // 查询激励广告奖励
  checkRewarderAd(dynamic event) async {
    try {
      UpDataADForm upDataADForm = UpDataADForm();
      upDataADForm.extra =
          "userid_${UserInfo.instance.userModel.id}_type_1_amount_${event.extraMap['adsource_price']}_time_0";
      upDataADForm.transId = event.extraMap?['id'];
      Utils.logError("激励视频凑成的字符串${upDataADForm.toJson()}");
      // 先转成 String 再解析 double（兼容 int/String 类型，避免直接赋值类型冲突）
      // 逐层判空+类型兼容，最终转成 double? 赋值给 amount
      dynamic adSourcePrice = event.extraMap?['adsource_price'];
      double? amount = double.tryParse(adSourcePrice?.toString() ?? "0");
      int pross = amount?.toInt() ?? 0;
      // 如果金额超出限制，上报异常
      if (pross > Store.instance.getFkConfig.wactchMaxAmountV1) {
        CheckDeviceForm checkDeviceForm = CheckDeviceForm();
        checkDeviceForm.oaid = await FlutterAndroidOaidPlugin.getOAID();
        checkDeviceForm.userId = UserInfo.instance.userModel.id;
        checkDeviceForm.address = Store.instance.locationData?.address;
        checkDeviceForm.latitude = Store.instance.locationData?.latitude;
        checkDeviceForm.longitude = Store.instance.locationData?.longitude;
        checkDeviceForm.msg = "激励视频金额超出限制";
        checkDeviceForm.type = 2;
        await Api.to.getVer(checkDeviceForm);
        Get.offAllNamed(AppRoutes.userError);
      }

      /// 查询奖励
      RewarderModel rewarderModel = await Api.to.getSelectAd(upDataADForm);
      if (rewarderModel.amount > 0) {
        Utils.debounce(() async {
          await checkClaim();
          UserInfo.instance.getUserInfoFn();
          // 增加次数
          Store.instance.addCurrentCount(1);
          // 重置间隔时间
          Store.instance.setRemainingSeconds();
          // 开始倒计时
          Store.instance.countDown();
        }, duration: Duration(seconds: 1));
      }
    } catch (e) {
      Utils.logError("领取激励视频奖励失败：$e");
    } finally {
      NativeTool.to.removeNativeAd();
      NativeTool.to.loadNativeWith();
      Get.back();
    }
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
            "激励广告 rewardedVideoDidFailToLoad ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          break;
        //广告加载成功
        case RewardedStatus.rewardedVideoDidFinishLoading:
          Utils.logError(
            "激励广告 rewardedVideoDidFinishLoading ---- placementID: ${value.placementID}",
          );
          break;
        //广告开始播放
        case RewardedStatus.rewardedVideoDidStartPlaying:
          Utils.logError(
            "激励广告 rewardedVideoDidStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告结束播放
        case RewardedStatus.rewardedVideoDidEndPlaying:
          Utils.logError(
            "激励广告 rewardedVideoDidEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告播放失败
        case RewardedStatus.rewardedVideoDidFailToPlay:
          Utils.logError(
            "激励广告 rewardedVideoDidFailToPlay ---- placementID: ${value.placementID} ---- errStr:${value.extraMap}",
          );
          break;
        //激励成功，建议在此回调中下发奖励
        case RewardedStatus.rewardedVideoDidRewardSuccess:
          Utils.logError(
            "激励广告 rewardedVideoDidRewardSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告被点击
        case RewardedStatus.rewardedVideoDidClick:
          Utils.logError(
            "激励广告 rewardedVideoDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //Deeplink
        case RewardedStatus.rewardedVideoDidDeepLink:
          Utils.logError(
            "激励广告 rewardedVideoDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          break;
        //广告被关闭
        case RewardedStatus.rewardedVideoDidClose:
          Utils.logError(
            "激励广告 rewardedVideoDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          loadRewardedVideo(
            userID: "${UserInfo.instance.userModel.id}",
            extra:
                "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
          );
          checkRewarderAd(value);
          HomeGroupChat.to.redBagOpen.value = false;

          break;

        //广告开始播放（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
          Utils.logError(
            "激励广告 rewardedVideoDidAgainStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告结束播放（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
          Utils.logError(
            "激励广告 rewardedVideoDidAgainEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告播放失败（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:
          Utils.logError(
            "激励广告 rewardedVideoDidAgainFailToPlay ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //激励成功（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          Utils.logError(
            "激励广告 rewardedVideoDidAgainRewardSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告被点击（只针对穿山甲的再看一个广告）
        case RewardedStatus.rewardedVideoDidAgainClick:
          Utils.logError(
            "激励广告 rewardedVideoDidAgainClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );

        case RewardedStatus.rewardedVideoUnknown:
          Utils.logError("激励广告 rewardedVideoUnknown");
          break;
      }
    });
  }
}
