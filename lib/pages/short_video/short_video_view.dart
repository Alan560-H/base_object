import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_video_controller.dart';

class ShortVideoView extends GetView<ShortVideoController> {
  const ShortVideoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
            () => Container(
          width: Get.width,
          height: Get.height,
          decoration: BoxDecoration(
            color: TextConfig.fensePageColor,
            image: DecorationImage(
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              image: CachedNetworkImageProvider(ImageConfig.userInviteBg),
            ),
          ),
          child: Column(
            children: [
              CuAppBar(
                title: controller.appbarTitle.value,
                showBackArrow: true,
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
              ),
              // 顶部小容器
              Container(
                height: 115.h,
                width: Get.width,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "邀请好友赚现金",
                      style: TextStyle(
                        fontSize: TextConfig.textSize_30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "最高 99元",
                          style: TextStyle(
                            fontSize: TextConfig.textSize_24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Tada(
                          infinite: true,
                          duration: const Duration(milliseconds: 1000),
                          child: CuButton(
                            text: "",
                            bgImage: ImageConfig.inviteBtn,
                            width: 120.w,
                            height: 50.h,
                            onPressed: () {},
                          ),
                        ),
                      ],
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
