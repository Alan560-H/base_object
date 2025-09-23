import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_video_controller.dart';

class ShortVideoView extends GetView<ShortVideoController> {
  const ShortVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // controller.initAd();
    });
    return Scaffold(
      body: Column(
        spacing: 10.h,
        children: [
          CuAppBar(
            title: controller.appbarTitle.value,
            showBackArrow: false,
            backgroundColor: Colors.transparent,
            textColor: Colors.white,
          ),
          CuButton(
            text: "增加",
            width: 200.w,
            bgColor: TextConfig.primary,
            onPressed: () {
              controller.startPeriodicAddAd();
            },
          ),

          Obx(
            () => Expanded(
              child: Container(
                width: Get.width,
                height: Get.height,
                color: Colors.red,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: controller.nativeList.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        controller.nativeList[index],
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: CuButton(
                            text: "关闭",
                            width: 80.w,
                            bgColor: TextConfig.primary,
                            onPressed: () {
                              try {
                                controller.nativeList.removeAt(index);
                              } catch (e) {
                                Utils.logError(e.toString());
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      // body: PangrowthVideo.videoSingleCardView(
      //   viewWidth: 10.sw,
      //   viewHeight: 1.sh - ScreenUtil().statusBarHeight,
      // ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
