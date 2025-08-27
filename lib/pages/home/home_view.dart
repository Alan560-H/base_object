import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_view.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // 构建聊天列表（支持滚动）
  Widget _buildChatList() {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // 可添加滚动监听逻辑（如加载更多历史消息）
        return true;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(10.sp),
        itemCount: controller.messages.length,
        reverse: false, // 最新消息在底部（需向下滚动查看）
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return _buildMessageItem(message);
        },
      ),
    );
  }

  // 构建单条消息项（优先级：广告 > 红包 > 普通消息）
  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      padding: EdgeInsets.all(10.h),
      margin: EdgeInsets.only(bottom: 8.r), // 消息间距
      decoration: BoxDecoration(
        color: Colors.grey[50], // 消息背景色
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 2.r,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 用户头像
          _buildAvatar(message.user.avatarUrl),
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
                    fontSize: TextConfig.textSize_14.sp,
                    fontWeight: FontWeight.w500,
                    color: TextConfig.grey,
                  ),
                ),
                SizedBox(height: 5.h), // 用户名与内容间距

                // 2.2 核心内容（按优先级显示）
                if (message.hasPlaceholder)
                  _buildAdPlaceholder() // 广告消息
                else if (message.content == null)
                  _buildRedPacketItem() // 红包消息
                else
                  _buildNormalMessageItem(message.content!) // 普通消息
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建用户头像
  Widget _buildAvatar(String avatarUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.sp), // 圆形头像
      child: CachedNetworkImage(
        imageUrl: avatarUrl,
        width: 50.sp,
        height: 50.sp,
        fit: BoxFit.cover,

      ),
    );
  }

  // 构建广告占位容器（承载原生广告）
  Widget _buildAdPlaceholder() {
    final double adHeight = 340.h; // 广告固定高度（与原生广告配置一致）
    return Container(
      width: double.infinity,
      height: adHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      // 监听广告加载状态，显示加载中/广告
      child: Obx(() {
        if (!controller.isNativeAdReady.value) {
          // 广告未就绪：显示加载中
          return  Center(
            child: CircularProgressIndicator(
              color: TextConfig.primary,
              strokeWidth: 2,
            ),
          );
        } else {
          // 广告就绪：显示原生广告
          return PlatformNativeWidget(
            AppAdConfig.nativePlacementID, // 广告位ID（需在AppAdConfig中配置）
            _getAdConfig(adHeight), // 广告控件配置
            isAdaptiveHeight: true, // Android自适应高度（避免内容溢出）
          );
        }
      }),
    );
  }

  // 构建红包消息项
  Widget _buildRedPacketItem() {
    return InkWell(
      onTap: controller.showRewarder, // 点击触发激励广告
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 60.h, // 红包固定高度
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF4444)], // 红包渐变色
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            // 红包图标
            Icon(Icons.card_giftcard, color: Colors.white, size: 24.sp),
            SizedBox(width: 10.w),
            // 红包文案
            Text(
              "点击领取红包！",
              style: TextStyle(
                fontSize: TextConfig.textSize_16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建普通消息项
  Widget _buildNormalMessageItem(String content) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      height: 60.h, // 普通消息固定高度（避免布局跳动）
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: TextConfig.textSize_16.sp,
          color: TextConfig.grey,
        ),
        maxLines: 2, // 限制2行，超出显示省略号
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // 原生广告控件配置（与AnyThink SDK要求匹配）
  Map<String, dynamic> _getAdConfig(double adHeight) {
    return {
      // 广告父容器（整体尺寸）
      ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 20.w, // 宽度=屏幕宽-20（适配左右边距）
        adHeight, // 高度与外层容器一致
        backgroundColorStr: '#FFFFFF',
      ),
      // App图标
      ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
        50.sp, 50.sp,
        x: 10.w, y: 40.h,
        backgroundColorStr: 'clearColor',
      ),
      // 广告标题
      ATNativeManager.mainTitle(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 190.w, 20.h,
        x: 70.w, y: 40.h,
        textSize: 15.sp,
        textColorStr: '#333333',
      ),
      // 广告描述
      ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 190.w, 20.h,
        x: 70.w, y: 70.h,
        textSize: 13.sp,
        textColorStr: '#666666',
      ),
      // 行动按钮（立即下载）
      ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
        100.w, 35.h,
        x: Get.width - 110.w, y: 40.h,
        textSize: 14.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#FF6700',
        cornerRadius: 4, // 按钮圆角
      ),
      // 广告主图
      ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 40.w, 180.h,
        x: 20.w, y: 100.h,
        backgroundColorStr: '#F5F5F5',
        cornerRadius: 4,
      ),
      // 广告标签（广告二字）
      ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
        40.w, 18.h,
        x: 10.w, y: 10.h,
        textSize: 12.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#FF4444',
        cornerRadius: 2,
      ),
      // 关闭按钮
      ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
        20.sp, 20.sp,
        x: Get.width - 30.w, y: 10.h,
        backgroundColorStr: 'clearColor',
      ),
      // 广告合规六要素（Android中国区必需）
      ATNativeManager.elementsView(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 20.w, 25.h,
        x: 10.w, y: adHeight - 25.h, // 贴底部
        textSize: 10.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#7F000000',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    // 页面渲染完成后检查App升级
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.getAppUpdata();
    });

    return Scaffold(
      backgroundColor: Colors.grey[100], // 页面背景色
      // 主体内容（聊天列表 + 加载进度条）
      body: Obx(() => Column(
        children: [
          CuAppBar(
            showBackArrow: false,
            title: controller.appbarTitle.value,
            backgroundColor: Colors.white,
          ),
          Expanded(
            child: Stack(
              children: [
                _buildChatList(), // 聊天列表（可滚动）
                // 初始加载进度条（可根据需求控制显示/隐藏）
                // if (controller.messages.isEmpty)
                //   Positioned(
                //     top: Get.height / 2 - 30.h,
                //     left: 0,
                //     right: 0,
                //     child: CuCircularProgressView(
                //       imagePath: ImageConfig.progressBg,
                //       size: 60.h,
                //       strokeWidth: 5.h,
                //       progressColor: TextConfig.primary,
                //       backgroundColor: TextConfig.black333,
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      )),
      // 底部导航栏
      bottomNavigationBar: const CuNavBarView(),
    );
  }
}