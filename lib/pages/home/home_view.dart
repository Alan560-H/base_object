import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_view.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/components/dialogs/KgxjqDialog.dart';
import 'package:base_object/core/components/dialogs/PbkyyDialog.dart';
import 'package:base_object/core/components/dialogs/newUserDialog/NewUserDialog.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/user_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller =
        Get.isRegistered<HomeController>()
            ? Get.find<HomeController>()
            : Get.put(HomeController());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.getAppUpdata();
    });
    return Scaffold(
      body: Obx(
        () => Container(
          color: TextConfig.comPageGrey,
          child: Column(
            spacing: 5.h,
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
                        // text:
                        //     "${controller.isShowNew.value},${UserInfo.instance.isLoginIn}",
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
                      if (!UserInfo.instance.isLoginIn) {
                        HomeGroupChat.to.removeAdContainer();
                      }
                      Get.toNamed(AppRoutes.userTixian);
                    },
                  ),
                ],
              ),

              // 聊天列表
              Expanded(
                child: Stack(
                  children: [
                    controller.buildChatList(),
                    if (CuCircularProgressController.to.timeEnd.value)
                      Positioned(
                        top: Get.height / 2 - 140.h,
                        left: 0,
                        child: CachedNetworkImage(
                          imageUrl: ImageConfig.re,
                          width: 60.w,
                          height: 40.h,
                        ),
                      ),
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
