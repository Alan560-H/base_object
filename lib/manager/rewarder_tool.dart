import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/models/localModels/UpADModel.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
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

  // 查询激励广告奖励
  checkRewarderAd(dynamic event) async {
    try {
      /// 先看低保任务 是否接了
      await Store.instance.postMinAdPrizeList();

      /// 如果接了任务,就退出方法
      if (Store.instance.isTaskStatus == 1) {
        await Future.delayed(const Duration(seconds: 2));
        await Store.instance.postMinAdPrizeList();

        /// 如果任务完成
        if (Store.instance.adTaskModel.value.numConfig -
                Store.instance.adTaskModel.value.userNum <=
            0) {
          await Store.instance.postMinAdEnd();
          return;
        }
        CuToast.error(
          msg:
              "距离任务完成还差${Store.instance.adTaskModel.value.numConfig - Store.instance.adTaskModel.value.userNum}，请继续观看广告",
        );
        Store.instance.setRemainingSeconds();
        // 开始倒计时
        Store.instance.countDown();
        return;
      }
      await Store.instance.checkFkConfig();

      UpDataADForm upDataADForm = UpDataADForm();
      upDataADForm.extra =
          "userid_${UserInfo.instance.userModel.id}_type_1_amount_${event.extraMap['publisher_revenue_cny']}_time_0";
      upDataADForm.transId = event.extraMap?['id'];
      upDataADForm.channelPackage =
          Store.instance.getAppUpLoadModel.channelPackage;

      Utils.logError("激励视频凑成的字符串${upDataADForm.toJson()}");
      // 先转成 String 再解析 double（兼容 int/String 类型，避免直接赋值类型冲突）
      // 逐层判空+类型兼容，最终转成 double? 赋值给 amount
      dynamic publisherRevenueCny = event.extraMap['publisher_revenue_cny'];
      String reqId = event.extraMap?['req_id'];
      String adsourceId = event.extraMap?['adsource_id'];
      double? amount = double.tryParse(publisherRevenueCny?.toString() ?? "0");
      upDataADForm.amount = amount;
      Utils.logError(
        "激励广告金额$amount，限制金额${Store.instance.getFkConfig.wactchMaxAmountV1}",
      );
      if (!UserInfo.instance.isLoginIn) return;
      if (amount == null) return;
      double amount1 = amount * 10000;
      UpADModel upADModel = UpADModel(
        adsourceId: adsourceId,
        reqId: reqId,
        adType: "激励广告",
        adAmount: amount1,
      );

      /// 如果广告金额大于风控设置的最高金额
      if (amount1 > Store.instance.getFkConfig.wactchMaxAmount) {
        Store.instance.addWactchMainMaxADList(upADModel);
      }

      /// 如果广告金额小于风控设置得最低金额
      if (amount1 < Store.instance.getFkConfig.wactchMinAmount) {
        Store.instance.addWactchMainMinADList(upADModel);
      }

      await Future.delayed(const Duration(seconds: 2));
      Utils.logError("查询奖励");

      /// 查询奖励
      RewarderModel rewarderModel = await Api.to.getSelectAd(upDataADForm);
      if (rewarderModel.amount > 0) {
        Utils.debounce(() async {
          CuToast.success(msg: "存钱罐成功增加${rewarderModel.amount * 10000}");
          CuCircularProgressController.to.getCurrentValue();
          // 增加次数
          Store.instance.addCurrentCount(1);
          await LocalStorage.setString(
            AppKeys.rewarderTime,
            Store.instance.getFkConfig.adTime,
          );
          // 重置间隔时间
          Store.instance.setRemainingSeconds();
          // 开始倒计时
          Store.instance.countDown();
        }, duration: Duration(seconds: 1));
      }
    } catch (e) {
      Utils.logError("领取激励视频奖励失败：$e");
    } finally {}
  }

  /// 领取存钱罐奖励
  Future<void> checkClaim() async {
    try {
      EasyLoading.show(status: "正在领取中...");

      BackModel backModel = await Api.to.getAdAmount();
      Utils.logError("领取存钱罐奖励返回数据：${backModel.toJson()}");
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: "存钱罐领取成功${backModel.data}");
        UserInfo.instance.getUserInfoFn();
        Store.instance.setIsOpenClaim(false);
        CuCircularProgressController.to.resetProgressTimer();
        Get.back();
      }
    } catch (e) {
      Utils.logError("领取存钱罐失败$e");
    } finally {
      EasyLoading.dismiss();
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
            "激励广告 加载失败 ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
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
          AdInfo adInfo = AdInfo(
            value.extraMap['publisher_revenue_cny'],
            value.placementID,
            value.extraMap['req_id'],
            value.extraMap['network_firm_id'],
            value.extraMap['adsource_id'],
            Jiffy.now().format(),
          );
          Utils.logError(value.extraMap['publisher_revenue_cny'] is String);
          Utils.logError(value.placementID is String);
          Utils.logError(value.extraMap['req_id'] is String);
          Utils.logError(value.extraMap['network_firm_id'] is int);
          Utils.logError(value.extraMap['adsource_id'] is String);
          Store.instance.addAdInfos(adInfo);
          // checkRewarderAd(value);
          HomeGroupChat.to.redBagOpen.value = false;

          loadRewardedVideoFlutter(
            // userID: "${UserInfo.instance.userModel.id}",
            // extra:
            //     "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
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
          break;
      }
    });
  }
}
