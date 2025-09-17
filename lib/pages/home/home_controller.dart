import 'dart:async';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/components/dialogs/NoticeDialog.dart';
import 'package:base_object/core/components/dialogs/interAdDialog/interAdDialog.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_utils.dart';

class HomeController extends GetxController {
  // 定时器相关
  Timer? _autoMessageTimer; // 普通消息定时器（3秒/条）
  Timer? _placeholderTimer; // 广告消息定时器（6秒/条）

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
      if (!Get.isRegistered<RewarderTool>()) {
        Get.put<RewarderTool>(RewarderTool());
      }
      bool isRewardReady =
          await RewarderTool.to.rewardedVideoReady(); // 激励视频是否准备好
      bool isShowRedBag = HomeUtils.random.nextDouble() < 0.2; // 是否展示红包
      // bool isNativeReady = await NativeTool.to.nativeAdReady(); // 原生广告是否准备好
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
          onTap:
              () => CuCircularProgressController.to.showDialog(
                isShowRedBag: false,
              ),
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
  Future<void> getAppUpdata({bool isReturn = false}) async {
    await HomeUtils.getAppUpdata(isReturn: isReturn);
  }

  RxBool isShowNew = false.obs;

  /// 是否显示新人奖励
  isShowNewUser() async {
    Utils.logError("登录？？${UserInfo.instance.isLoginIn}");
    if (!UserInfo.instance.isLoginIn) return false;
    isShowNew.value = await UserInfo.instance.isNewUser();
  }

  /// 显示公告框
  isShow() async {
    if (await NoticeDialog.shouldShow()) {
      Dialogs.noticeDialog();
    }
  }

  Future _pangrowthInit() async {
    // 这里的appid  和logappid 填写穿山甲的sdkjson文件李的值
    await PangrowthVideo.registerVideo(
      appName: "",
      andoridAppId: "5670418",
      appLogAppId: "751081",
      iosAppId: "",
      debug: true,
    );
  }

  // ------------------- 生命周期 -------------------
  void allInit() async {
    // 初始化广告监听和加载
    // rewarderEvent();
    // 初始化用户信息
    UserInfo.instance.initialize();

    RewarderTool.to.loadRewardedVideo(
      userID: "${UserInfo.instance.userModel.id}",
      extra: "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
    );
    isShowNewUser();
    // 初始化app升级信息
    await getAppUpdata(isReturn: true);

    /// 是否显示公告狂
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
    InterAdDialog.to.restartTimer();
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

// 显示激励广告
// () async {
//   if (Get.isRegistered<NativeTool>()) {
//     NativeTool.to.loadNativeWith();
//     Utils.logError(NativeTool.to.checkNativeLoadStatus());
//     if (await NativeTool.to.nativeAdReady()) {
//       NativeTool.to.();
//     }
//   }
//
//   if (await Store.instance.canLookReward()) {
//     Get.dialog(
//       Container(
//         constraints: BoxConstraints(
//           maxWidth: Get.width,
//           maxHeight: Get.height,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               height: 300.h,
//               child: Stack(
//                 children: [
//                   InkWell(
//                     onTap: () async {
//                       if (!UserInfo.instance.isLoginIn) {
//                         Get.toNamed(AppRoutes.login);
//                         return;
//                       }
//                       if (Store.instance.isTimeOver) {
//                         // CuToast.error(msg: "红包被抢完了");
//                         EasyLoading.showError("稍等片刻，红包正在准备准备中");
//                         return;
//                       }
//                       bool isRewReady =
//                           await RewarderTool.to.rewardedVideoReady();
//                       if (isRewReady) {
//                         redBagOpen.value = true;
//                         await RewarderTool.to.showRewardedVideo();
//                       } else {
//                         redBagOpen.value = false;
//                         CuToast.error(msg: "激励广告加载失败，请稍后重试");
//                       }
//                     },
//                     child: Center(
//                       child: CachedNetworkImage(
//                         imageUrl: ImageConfig.hongbaoCover,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 0.h,
//                     right: 50.w,
//                     child: CuButton(
//                       text: "",
//                       icons: Icons.close,
//                       fontSize: TextConfig.textSize_24,
//                       onPressed: () {
//                         NativeTool.to.removeNativeAd();
//                         NativeTool.to.loadNativeWith();
//                         Get.back();
//                       },
//                     ),
//                   ),
//                   Positioned(
//                     top: 80.h,
//                     left: 0,
//                     child: Container(
//                       width: Get.width,
//                       alignment: Alignment.center,
//                       child: Text(
//                         "今日已领取红包${Store.instance.getCurrentCount.dayMaxCount}/${Store.instance.getFkConfig.dayMax}",
//                         style: TextStyle(
//                           fontSize: TextConfig.textSize_20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.yellowAccent,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 110.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
