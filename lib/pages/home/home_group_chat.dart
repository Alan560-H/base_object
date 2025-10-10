import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_utils.dart';

class HomeGroupChat extends GetxService {
  /// 单例模式，确保全局只有一个实例
  static HomeGroupChat get to =>
      Get.isRegistered<HomeGroupChat>()
          ? Get.find<HomeGroupChat>()
          : Get.put(HomeGroupChat());
  // 定时器相关
  Timer? _autoMessageTimer; // 普通消息定时器（5秒/条）
  Timer? _addAdTimer;

  /// 红包是否打开
  RxBool redBagOpen = false.obs;
  bool isAddNative = false;
  int indexNative = -1;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs; // 聊天消息列表]
  Widget cachedAdWidget = Container(
    width: Get.width,
    height: 250.h,
    color: Colors.blue,
  );
  // 构建广告占位容器（承载原生广告）
  // 修复：返回一个稳定的、可复用的 Widget
  Future<Widget> getNativeView() async {
    bool isHasAdStr = await NativeTool.to.getNativeValidAds();
    Utils.logError("获取原生广告占位容器是否有广告缓存$isHasAdStr");
    if (!isHasAdStr) {
      return Container(
        width: Get.width,
        height: NativeTool.to.adHeight,
        color: Colors.red,
      );
    }
    cachedAdWidget = Container(
      // 修复：使用 const ValueKey，确保 Widget 的“身份”不变
      // key: const ValueKey('SINGLE_NATIVE_AD_CONTAINER'),
      width: double.infinity,
      // height: adHeight,
      constraints: BoxConstraints(maxHeight: NativeTool.to.adHeight),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: PlatformNativeWidget(
        AppAdConfig.nativePlacementID,
        NativeTool.to.getAdConfig(),
        isAdaptiveHeight: true, // 启用自适应高度
      ),
    );
    return cachedAdWidget;
  }

  void homeGroupChatInit() {
    Utils.logError("群聊初始化，消息长度${messages.length}");
    // 初始化消息（5条普通消息）
    if (messages.isEmpty) {
      for (int i = 0; i < 5; i++) {
        _addRandomChatMessage();
      }
    }
    startTimer();
  }

  void startTimer() {
    // 启动定时器
    _startAutoMessageTimer();
    startPeriodicAddAd();
  }

  void pauseTimer() {
    if (_autoMessageTimer != null) {
      _autoMessageTimer!.cancel();
      _autoMessageTimer = null;
    }
    if (_addAdTimer != null) {
      _addAdTimer!.cancel();
      _addAdTimer = null;
    }
  }

  Future<void> startPeriodicAddAd() async {
    // 先取消已有的定时器（防止重复启动，比如多次点击按钮）
    if (_addAdTimer != null) {
      return;
    }
    Utils.logError("启动定时器2");

    // 启动定时任务：每6秒执行一次回调
    _addAdTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // 判断广告是否准备好，避免添加无效容器
      bool isADReady = await NativeTool.to.nativeAdReady();
      if (isADReady) {
        Utils.logError("5秒定时添加广告容器");
        isAddNative = true; // 添加新的广告容器
        //
      }
    });
  } // NativeTool.to.getNativeView()

  // 启动普通消息定时器（5秒/条）
  void _startAutoMessageTimer() {
    if (_autoMessageTimer != null) {
      return;
    }
    Utils.logError("启动定时器1");
    _autoMessageTimer = Timer.periodic(
      const Duration(seconds: 3),
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
          onTap: () {
            if (!UserInfo.instance.isLoginIn) {
              HomeGroupChat.to.removeAdContainer();
            }
            CuCircularProgressController.to.showDialog(isShowRedBag: false);
          },
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
        // 如果有缓存，则添加
        if (NativeTool.to.isViewCreated.value) {
          Utils.logError("给广告赋值：${NativeTool.to.isViewCreated.value}");
          content = await getNativeView();
          _autoMessageTimer?.cancel();
          _autoMessageTimer = null;
          // 去掉 await，用 then 回调实现“10秒后异步执行”，不阻塞当前函数
          Future.delayed(const Duration(seconds: 20), () {
            removeAdContainer();
            Utils.logError("又开始启动啦定时器1");

            _startAutoMessageTimer();
          });
        }
        isAddNative = false;
        isHasNative = true;
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
        if (Get.isRegistered<HomeController>()) {
          HomeController homeController = Get.find<HomeController>();
          homeController.scrollToBottom();
        }
      }
    }
  }

  void removeAdContainer() {
    /// 如果有信息流广告了，那么就删除他
    indexNative = messages.indexWhere((message) => message.isHasNative);
    if (indexNative != -1) {
      Utils.logError("删除广告位置：$indexNative");
      // 2. 从原位置移除（临时移除，用于调整位置）
      messages.removeAt(indexNative);
    }
    NativeTool.to.removeNativeAd();
    cachedAdWidget = Container(
      width: Get.width,
      height: NativeTool.to.adHeight,
      color: Colors.yellow,
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

  // 改为可重新赋值的控制器（去掉 final）
}
