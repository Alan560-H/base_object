import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/store/user_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController>{
  const HomeView({super.key});

  // 构建聊天列表
  Widget _buildChatList() {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // 可以在这里添加滚动监听逻辑
        return true;
      },
      child: ListView.builder(
        padding:  EdgeInsets.all(10.sp),
        itemCount: controller.messages.length,
        // 反转列表，最新的消息在底部
        reverse: false,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return _buildMessageItem(message);
        },
      ),
    );
  }
  // 构建单条消息项
  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      margin:  EdgeInsets.only(bottom: 5.r),
      child: Row(
        spacing: 10.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          ClipRRect(
            borderRadius: BorderRadius.circular(25.sp),
            child: Image.network(
              message.user.avatarUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return  CircleAvatar(
                  radius: 25.r,
                  child: Icon(Icons.person),
                );
              },
            ),
          ),
          // 消息内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称
                Text(
                  message.user.name,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TextConfig.grey,
                  ),
                ),
                 SizedBox(height: 5.h),
                // 消息内容或红包
                message.content == null
                    ? CachedNetworkImage(imageUrl: ImageConfig.hongbao)
                    : Container(
                  padding:  EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    message.content!,
                    style:  TextStyle(fontSize: TextConfig.textSize_16.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
          Column(
            children: [
              CuAppBar(
                showBackArrow: false,
                title: controller.appbarTitle.value,
                  backgroundColor: Colors.white,
              ),
              // 聊天列表
              Expanded(child: _buildChatList()),
            ],
          )
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
  
}