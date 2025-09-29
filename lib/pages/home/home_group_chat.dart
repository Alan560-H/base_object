import 'dart:async';

import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
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
  void homeGroupChatInit() {
    Utils.logError("群聊初始化，消息长度${messages.length}");
    // 初始化消息（5条普通消息）
    if (messages.isEmpty) {
      for (int i = 0; i < 5; i++) {
        _addRandomChatMessage();
      }
    }
    _resetScrollController();
    // 启动定时器
    _startAutoMessageTimer();
    startPeriodicAddAd();
  }

  // 新增：重置控制器（销毁旧的，创建新的）
  void _resetScrollController() {
    // 先销毁旧控制器（避免内存泄漏）
    if (scrollController != null && scrollController!.hasClients) {
      scrollController!.dispose();
    }
    scrollController = ScrollController(); // 创建新控制器
  }

  // 构建聊天列表（支持滚动）
  Widget buildChatList() {
    Utils.logError("构建聊天列表");
    _resetScrollController(); // 每次构建 ListView 前，重置控制器
    return ListView.builder(
      controller: scrollController!, // 绑定新控制器
      padding: EdgeInsets.all(10.sp),
      itemCount: messages.length,
      reverse: false, // 最新消息在底部（需向下滚动查看）
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(message);
      },
    );
  }

  // 构建单条消息项（优先级：广告 > 红包 > 普通消息）
  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      margin: EdgeInsets.only(bottom: 8.r), // 消息间距
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 用户头像
          Avatar(
            headImage: message.user.avatarUrl,
            size: 20.h,
            isCircle: false,
          ),
          SizedBox(width: 10.w), // 头像与内容间距
          // 2. 消息内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2.1 用户名
                Text(
                  message.user.name,
                  style: TextStyle(
                    fontSize: TextConfig.textSize_14,
                    color: Utils.fromHex("#888888"),
                  ),
                ),
                SizedBox(height: 5.h), // 用户名与内容间距
                message.content,
              ],
            ),
          ),
        ],
      ),
    );
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
          content = await NativeTool.to.getNativeView();
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
        scrollToBottom();
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
    NativeTool.to.cachedAdWidget = Container(
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
  ScrollController? scrollController;
  // 2. 封装“滚动到最底部”的方法（关键：等列表构建完成后再滚动）
  void scrollToBottom() {
    // 延迟到当前帧构建完成后执行，避免获取不到最新滚动位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 确保控制器已绑定到 ListView，且有可滚动空间
      if (scrollController != null && scrollController!.hasClients) {
        // 平滑滚动到最底部（也可用 controller.jumpTo 实现瞬时滚动）
        scrollController!.animateTo(
          scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), // 滚动动画时长
          curve: Curves.easeInOut, // 滚动曲线
        );
      }
    });
  }
}
