import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/components/dialogs/commonDialog/ClaimAdDialog.dart';
import 'package:base_object/core/components/dialogs/newUserDialog/NewUserDialog.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/components/dialogs/NoticeDialog.dart';
import '../../core/routes/app_routes.dart';
import '../../models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import '../../models/backModel/BackModel.dart';
import 'home_utils.dart';

class HomeController extends GetxController {

  // 激励广告奖励提交方法
  upDataADFn(dynamic event) async {
    try {
      UpDataADForm upDataADForm = UpDataADForm();
      upDataADForm.extra =
          "userid_${UserInfo.instance.userModel.id}_type_1_amount_${event['extraMap']['adsource_price']}_time_0";
      upDataADForm.transId = event?['extraMap']?['id'];
      Utils.logError("激励视频凑成的字符串${upDataADForm.toJson()}");
      // 先转成 String 再解析 double（兼容 int/String 类型，避免直接赋值类型冲突）
      // 逐层判空+类型兼容，最终转成 double? 赋值给 amount
      dynamic adSourcePrice = event?['extraMap']?['adsource_price'];
      double? amount = double.tryParse(adSourcePrice?.toString() ?? "0");
      int pross = amount?.toInt() ?? 0;
      if(pross>Store.instance.getFkConfig.wactchMaxAmountV1){
        CheckDeviceForm checkDeviceForm = CheckDeviceForm();
        checkDeviceForm.oaid = await FlutterAndroidOaidPlugin.getOAID();
        checkDeviceForm.userId = UserInfo.instance.userModel.id;
        checkDeviceForm.type = 2;
        BackModel data = await Api.to.getVer(checkDeviceForm);
        Get.offAllNamed(AppRoutes.userError);
      }
      RewarderModel rewarderModel = await Api.to.getSelectAd(upDataADForm);
      if (rewarderModel.amount > 0) {
        Utils.debounce(() {
          UserInfo.instance.getUserInfoFn();
          CuToast.success(
            msg: "恭喜获得${(rewarderModel.amount * 10000).toStringAsFixed(2)} 金币",
          );
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

  // 定时器相关
  Timer? _autoMessageTimer; // 普通消息定时器（3秒/条）
  Timer? _placeholderTimer; // 广告消息定时器（6秒/条）
  bool _hasShow = false; // 防止重复跳转标记

  /// 订阅激励广告事件
  void rewarderEvent() async {
    ever(ListenerTool.to.rewarderEvent, (event) {
      if (event == null || _hasShow) return;
      String eventType = event["eventType"] ?? "";
      String placementID = event["placementID"] ?? "";

      Utils.logError("激励广告事件：$eventType，广告位ID：$placementID，参数：$event");

      switch (eventType) {
        case "RewardedStatus.rewardedVideoDidFailToLoad":
          Utils.logError("激励广告加载失败，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidFinishLoading":
          Utils.logError("激励广告加载完成，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidStartPlaying":
          Utils.logError("激励广告开始播放，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidEndPlaying":
          Utils.logError("激励广告结束播放，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidFailToPlay":
          Utils.logError("激励广告播放失败，广告位ID：$placementID");
          NativeTool.to.removeNativeAd();
          NativeTool.to.loadNativeWith();
          break;
        case "RewardedStatus.rewardedVideoDidRewardSuccess":
          Utils.logError("激励广告奖励成功，广告位ID：$placementID");

          break;
        case "RewardedStatus.rewardedVideoDidClick":
          Utils.logError("激励广告被点击，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidDeepLink":
          Utils.logError("激励广告深度链接，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidClose":
          Utils.logError("激励广告被关闭，广告位ID：$placementID");
          if(!Get.isRegistered<RewarderTool>()){
            Get.put(RewarderTool());
          }
          RewarderTool.to.loadRewardedVideo(
            userID: "${UserInfo.instance.userModel.id}",
            extra:
            "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
          );
          redBagOpen.value = false;
          if (Get.isRegistered<UserInfo>()) {
            upDataADFn(event);
          }
          Utils.logError("${Store.instance.getIsOpenClaim}，hhhh",);
          if(Store.instance.getIsOpenClaim){
            ClaimAdDialog.checkClaim();
          }
          break;
      }
    });
  }

  // 显示激励广告
  showRewarder() async {

    if(await Store.instance.canLookReward()){
      if (Get.isRegistered<NativeTool>()) {
        NativeTool.to.showNative();
      }
      Get.dialog(
        Container(
          constraints: BoxConstraints(maxWidth: Get.width, maxHeight: Get.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300.h,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        bool isRewReady =
                        await RewarderTool.to.rewardedVideoReady();
                        if (isRewReady) {
                          redBagOpen.value = true;
                          await RewarderTool.to.showRewardedVideo();
                        } else {
                          redBagOpen.value = false;
                          CuToast.error(msg: "激励广告加载失败，请稍后重试");
                        }
                      },
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: ImageConfig.hongbaoCover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.h,
                      right: 50.w,
                      child: CuButton(
                        text: "",
                        icons: Icons.close,
                        fontSize: TextConfig.textSize_24,
                        onPressed: () {
                          NativeTool.to.removeNativeAd();
                          NativeTool.to.loadNativeWith();
                          Get.back();
                        },
                      ),
                    ),
                    Positioned(
                      top: 80.h,
                      left: 0,
                      child: Container(
                        width: Get.width,
                        alignment: Alignment.center,
                        child: Text(
                          "今日已领取红包${Store.instance.getCurrentCount.dayMaxCount}/${Store.instance.getFkConfig.dayMax}",
                          style: TextStyle(
                            fontSize: TextConfig.textSize_20,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellowAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 110.h),
            ],
          ),
        ),
      );
    }

  }

  int timeCount = 0;
  // 启动普通消息定时器（3秒/条）
  void _startAutoMessageTimer() {
    _autoMessageTimer = Timer.periodic(
      const Duration(seconds: 3),
      (Timer timer) => _addRandomChatMessage(),
    );
  }

  // 构建普通消息项
  Widget _buildNormalMessageItem(String content) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      constraints: BoxConstraints(maxHeight: 300.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: TextConfig.textSize_16.sp,
          color: TextConfig.black333,
        ),
        maxLines: 2, // 限制2行，超出显示省略号
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  RxBool redBagOpen = false.obs;
  // 生成聊天消息（支持普通/红包/广告消息）
  void _addRandomChatMessage() async {
    try {
      timeCount++;
      // 1. 生成随机用户信息
      final String randomNickname = HomeUtils.generateRandomNickname();
      final int avatarIndex = HomeUtils.random.nextInt(31); // 0-30共31张头像
      final String localAvatarPath = ImageConfig.getUrlAvatar(avatarIndex);
      final VirtualUser randomUser = VirtualUser(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: randomNickname,
        avatarUrl: localAvatarPath,
      );
      Widget content = _buildNormalMessageItem(
        HomeUtils.getRandomRedPacketQuote(),
      );
      bool isHasNative = false;
      if(!Get.isRegistered<RewarderTool>()){
        Get.put<RewarderTool>(RewarderTool());
      }
      bool isRewardReady =
          await RewarderTool.to.rewardedVideoReady(); // 激励视频是否准备好
      bool isShowRedBag = HomeUtils.random.nextDouble() < 0.2; // 是否展示红包
      bool isNativeReady = await NativeTool.to.nativeAdReady(); // 原生广告是否准备好
      // 如果激励视频准备好，且概率已经小于0.2，则填充红包图片

      // Utils.logError("原生广告加载状态$isNativeReady,");
      // if(timeCount!=0){
      //   Utils.logError("这是6的倍数吗？${timeCount % 6 == 0}");
      //   if (isNativeReady&&timeCount % 6 == 0) {
      //     content = await NativeTool.to.startShowNativeAd();
      //     // content = Placeholder();
      //     isHasNative = true;
      //   }
      // }
      // 生成红包
      if (isRewardReady && isShowRedBag) {
        redBagOpen.value = false;
        content = InkWell(
          onTap: showRewarder,
          child: CachedNetworkImage(
            imageUrl:
                redBagOpen.value
                    ? ImageConfig.hongbaoOpen
                    : ImageConfig.hongbao,
          ),
        );
      }
      // 3. 创建消息对象
      final ChatMessage newMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        user: randomUser,
        content: content,
        timestamp: DateTime.now(),
        isHasNative: isHasNative,
      );

      // 4. 添加消息并限制列表长度（最多20条）
      messages.add(newMessage);
      if (messages.length > 10) {
        if (messages.first.isHasNative) {
          await NativeTool.to.removeNativeAd();
          Utils.logError("先删除广告");
          messages.removeAt(0);
          NativeTool.to.loadNativeWith();
        } else {
          messages.removeAt(0);
        }
      }
    } catch (e) {
      Utils.logError("添加消息失败$e");
    }
  }

  // 获取App升级信息
  getAppUpdata() async {
    await HomeUtils.getAppUpdata();
  }

  RxBool isShowNew = false.obs;
  isShowNewUser()async{
    Utils.logError("登录？？${UserInfo.instance.isLoginIn}");
    if(!UserInfo.instance.isLoginIn)return false;
    isShowNew.value =  await UserInfo.instance.isNewUser();
  }
  isShow() async {
    if (await NoticeDialog.shouldShow()) {
      Dialogs.noticeDialog();
    }
  }
  Future _pangrowthInit() async {
    // final status = await Permission.phone.request();
    // print("phone 权限状态 $status");
    // 这里的appid  和logappid 填写穿山甲的sdkjson文件李的值
    await PangrowthVideo.registerVideo(
      appName: "",
      andoridAppId: "5670418",
      appLogAppId :"751081",
      iosAppId: "",
      debug: true,
    );
  }
  // ------------------- 生命周期 -------------------
  void allInit()async{

    // 初始化广告监听和加载
    rewarderEvent();
    // 初始化用户信息
    UserInfo.instance.initialize();
    isShowNewUser();
    isShow();
    ///同意隐私政策之后调用
    await _pangrowthInit();

    // 初始化消息（5条普通消息）
    for (int i = 0; i < 5; i++) {
      _addRandomChatMessage();
    }
    // 启动定时器
    _startAutoMessageTimer();
  }
  @override
  void onInit() {
    Utils.logError("首页页面onInit");

    super.onInit();
    allInit();
  }

  @override
  void onClose() {
    Utils.logError("首页页面关闭");
    super.onClose();
    // 取消定时器，防止内存泄漏
    _autoMessageTimer?.cancel();
    _placeholderTimer?.cancel();
  }

  @override
  void onReady() {

    Utils.logError("首页页面onReady");
    // TODO: implement onReady
    super.onReady();
  }

  // ------------------- 响应式状态 -------------------
  final RxString appbarTitle = "红包群".obs; // 导航栏标题
  final RxList<ChatMessage> messages = <ChatMessage>[].obs; // 聊天消息列表
}
