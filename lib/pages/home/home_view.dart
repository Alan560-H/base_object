import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_view.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/components/dialogs/KgxjqDialog.dart';
import 'package:base_object/core/components/dialogs/PbkyyDialog.dart';
import 'package:base_object/core/components/dialogs/newUserDialog/NewUserDialog.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.getAppUpdata();
    });

    return Scaffold(
      body: Obx(
        () => Container(
          color: TextConfig.comPageGrey,
          child: Column(
            children: [
              CuAppBar(
                alignment: Alignment.centerLeft,
                showBackArrow: false,
                title: controller.appbarTitle.value,
                backgroundColor: Colors.transparent,
                actions: [
                  if (controller.isShowNew.value && UserInfo.instance.isLoginIn)
                    Tada(
                      infinite: true,
                      duration: const Duration(milliseconds: 1000),
                      child: CuButton(
                        bgColor: TextConfig.primary,
                        radius: 10.r,
                        text: "新人福利",
                        width: 80.w,
                        onPressed: () {
                          Get.dialog(NewUserDialog());
                        },
                      ),
                    ),
                  SizedBox(width: 40.w),
                  CuButton(
                    bgColor: TextConfig.primary,
                    radius: 15.r,
                    text:
                        UserInfo.instance.isLoginIn
                            ? "${UserInfo.instance.userModel.currentAmount} 提现"
                            : "登录",
                    width: 130.w,
                    onPressed: () {
                      Get.toNamed(AppRoutes.userTixian);
                    },
                  ),
                ],
              ),
              // 聊天列表
              Expanded(
                child: Stack(
                  children: [
                    _buildChatList(),
                    // 新人福利
                    // controller.isShowNew.value?Positioned(
                    //   top: Get.height/2,
                    //   left: 0,
                    //   child: InkWell(
                    //     onTap: ()=>Get.dialog(NewUserDialog()),
                    //     child: Tada(
                    //       infinite: true,
                    //       duration: const Duration(milliseconds: 1000),
                    //       child:CachedNetworkImage(imageUrl: ImageConfig.newUser1,height: 60.h,),
                    //     ),
                    //   ),
                    //  ):Center(),
                    // 存钱罐
                    Positioned(
                      top: Get.height / 2 - 100.h,
                      left: 0,
                      child: CuCircularProgressView(
                        imagePath: ImageConfig.progressBg,
                        size: 60.h, // 自定义进度条大小
                        strokeWidth: 5.h, // 自定义进度条宽度
                        progressColor: TextConfig.primary, // 自定义进度色（橙色）
                        backgroundColor: TextConfig.black333, // 自定义背景色
                      ),
                    ),
                    // 看广小技巧
                    Positioned(
                      top: Get.height / 2 - 100.h,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          Get.dialog(KgxjqDialog());
                        },
                        child: Container(
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),

                          child: CachedNetworkImage(
                            imageUrl: ImageConfig.kgxjq,
                          ),
                        ),
                      ),
                    ),
                    // 屏蔽快应用
                    Positioned(
                      top: Get.height / 2 - 210.h,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          Get.dialog(PbkyyDialog());
                        },
                        child: Container(
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: ImageConfig.pbkyy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
