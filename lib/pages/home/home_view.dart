import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/ad_log_collector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static void _showLogDialog() {
    Get.dialog(
      barrierDismissible: true,
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.6,
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("广告日志", style: TextStyle(fontSize: 18.sp)),
                  CuButton(
                    text: "清空",
                    width: 60.w,
                    height: 32.h,
                    onPressed: () {
                      AdLogCollector.clear();
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Obx(
                  () {
                    final lines = AdLogCollector.observable;
                    if (lines.isEmpty) {
                      return Center(child: Text("暂无日志"));
                    }
                    return ListView.builder(
                      itemCount: lines.length,
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Text(
                          lines[i],
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller =
        Get.isRegistered<HomeController>()
            ? Get.find<HomeController>()
            : Get.put(HomeController());
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
                title: controller.currentIp.value,
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
              Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "激励视频观看次数：${Store.instance.getAdInfos.length}",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      CuButton(
                        text: "日志",
                        width: 70.w,
                        height: 32.h,
                        onPressed: HomeView._showLogDialog,
                      ),
                    ],
                  ),
                ),
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
