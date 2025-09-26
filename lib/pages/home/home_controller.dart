import 'dart:async';
import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/components/dialogs/NoticeDialog.dart';
import 'package:base_object/core/components/dialogs/interAdDialog/interAdDialog.dart';
import 'package:base_object/core/config/app_ad_config.dart';
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
  Timer? _autoMessageTimer; // 普通消息定时器（5秒/条）
  // 1. 声明定时器变量，用于管理定时任务（初始为null）
  Timer? _addAdTimer;
  bool isAddNative = false;
  int indexNative = -1;
  // 2. 新增：启动「每6秒添加广告」的定时任务
  Future<void> startPeriodicAddAd() async {
    // 先取消已有的定时器（防止重复启动，比如多次点击按钮）
    if (_addAdTimer != null && _addAdTimer!.isActive) {
      _addAdTimer!.cancel();
    }
    // 启动定时任务：每6秒执行一次回调
    _addAdTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      // 判断广告是否准备好，避免添加无效容器
      bool isADReady = await NativeTool.to.nativeAdReady();
      if (isADReady) {
        Utils.logError("15秒定时添加广告容器");
        isAddNative = true; // 添加新的广告容器
      }
    });
  } // NativeTool.to.getNativeView()

  // 1. 添加滚动控制器（响应式，确保 View 能拿到同一实例）
  ScrollController scrollController = ScrollController();
  // 2. 封装“滚动到最底部”的方法（关键：等列表构建完成后再滚动）
  void scrollToBottom() {
    // 延迟到当前帧构建完成后执行，避免获取不到最新滚动位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 确保控制器已绑定到 ListView，且有可滚动空间
      if (scrollController.hasClients) {
        // 平滑滚动到最底部（也可用 controller.jumpTo 实现瞬时滚动）
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), // 滚动动画时长
          curve: Curves.easeInOut, // 滚动曲线
        );
      }
    });
  }

  // 启动普通消息定时器（5秒/条）
  void _startAutoMessageTimer() {
    _autoMessageTimer = Timer.periodic(
      const Duration(seconds: 6),
      (Timer timer) => _addRandomChatMessage(),
    );
  }

  // 生成聊天消息（支持普通/红包/广告消息）
  void _addRandomChatMessage() async {
    try {
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
      bool isRewardReady =
          await RewarderTool.to.rewardedVideoReady(); // 激励视频是否准备好
      bool isShowRedBag = HomeUtils.random.nextDouble() < 0.2; // 是否展示红包
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
      bool isHasNative = false;
      if (isAddNative) {
        bool ms = await NativeTool.to.nativeAdReady();
        bool ma = NativeTool.to.isViewCreated.value;
        String isHasAd = await NativeTool.to.getNativeValidAds();
        bool isLoading = await NativeTool.to.checkNativeAdLoadStatus();
        Utils.logError("黄忠胜信息流广告加载状态？$isLoading");
        Utils.logError("home获取当前广告位下所有可用广告的信息$isHasAd");
        // CuToast.success(msg: "我可以添加原生广告吗$ms,$ma");
        if (ma && ms && isHasAd.isNotEmpty) {
          // CuToast.success(msg: "我要添加了哦");

          /// 如果有信息流广告了，那么就删除他
          indexNative = messages.indexWhere((message) => message.isHasNative);
          if (indexNative != -1) {
            // 2. 从原位置移除（临时移除，用于调整位置）
            messages.removeAt(indexNative);
          }
          content = NativeTool.to.getNativeView();
          isAddNative = false;
          isHasNative = true;
        }
      }
      // 3. 创建消息对象
      final ChatMessage newMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        user: randomUser,
        content: content,
        isHasNative: isHasNative,
        timestamp: DateTime.now(),
      );

      // 4. 添加消息并限制列表长度（最多20条）
      messages.add(newMessage);
      if (messages.length > 10) {
        messages.removeAt(0);
      }
    } catch (e) {
      Utils.logError("添加消息失败$e");
    } finally {
      if (messages.length > 5) {
        scrollToBottom();
      }
    }
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

  RxBool isNativeReady = false.obs;
  setIsNativeReady(bool val) {
    isNativeReady.value = val;
  }

  RxBool redBagOpen = false.obs;

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
    scrollController = ScrollController();
    // 初始化用户信息
    UserInfo.instance.initialize();
    RewarderTool.to.loadRewardedVideo(
      userID: "${UserInfo.instance.userModel.id}",
      extra: "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
    );

    /// 是否显示新人邀请
    isShowNewUser();

    /// 是否显示公告框
    isShow();
    // 初始化app升级信息
    await getAppUpdata(isReturn: true);

    ///同意隐私政策之后调用
    await _pangrowthInit();

    // 初始化消息（5条普通消息）
    for (int i = 0; i < 5; i++) {
      _addRandomChatMessage();
    }
    // 启动定时器
    _startAutoMessageTimer();
    startPeriodicAddAd();
  }

  @override
  void onInit() {
    Utils.logError("首页页面onInit");
    InterAdDialog.to.restartTimer();
    NativeTool.to.nativeLisListen();
    NativeTool.to.loadNativeWith();
    allInit();
    super.onInit();
  }

  @override
  void onClose() {
    Utils.logError("首页页面关闭");
    super.onClose();
    // 取消定时器，防止内存泄漏
    _autoMessageTimer?.cancel();

    _addAdTimer?.cancel();
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
