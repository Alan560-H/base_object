import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/store/store.dart';
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
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   controller.getAppUpdata();
    // });
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
                  Text("总计数：${Store.instance.getAdInfos.length}"),
                  Text("总收益：${Store.instance.getAdInfosTotal}"),
                  // if (controller.isShowNew.value && UserInfo.instance.isLoginIn)
                  //   Tada(
                  //     infinite: true,
                  //     duration: const Duration(milliseconds: 1000),
                  //     child: CuButton(
                  //       bgColor: TextConfig.primary,
                  //       radius: 10.r,
                  //       text: "新人福利",
                  //       // text:
                  //       //     "${controller.isShowNew.value},${UserInfo.instance.isLoginIn}",
                  //       width: 80.w,
                  //       onPressed: () {
                  //         Get.dialog(NewUserDialog());
                  //       },
                  //     ),
                  //   ),
                  // SizedBox(width: 40.w),
                  // CuButton(
                  //   bgColor: TextConfig.primary,
                  //   radius: 15.r,
                  //   text:
                  //       UserInfo.instance.isLoginIn
                  //           ? "${UserInfo.instance.userModel.currentAmount} 提现"
                  //           : "登录",
                  //   width: 130.w,
                  //   onPressed: () {
                  //     if (!UserInfo.instance.isLoginIn) {
                  //       HomeGroupChat.to.removeAdContainer();
                  //     }
                  //     Get.toNamed(AppRoutes.userTixian);
                  //   },
                  // ),
                ],
              ),

              Expanded(
                child: controller.buildChatList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
