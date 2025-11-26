import 'dart:math';

import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/pages/splash_page/splash_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (_, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "加载中",
              style: TextStyle(
                color: Colors.white70,
                fontSize: TextConfig.textSize_20,
              ),
            ),
            // 三个点的动画效果
            ...List.generate(3, (index) {
              // 计算每个点的动画值，使它们依次显示
              final animationValue = sin(
                controller.animationController.value * 2 * pi +
                    index * 2 * pi / 3,
              );
              // 根据动画值计算透明度（-1到1之间映射到0到1）
              final opacity = (animationValue + 1) / 2;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.0.w),
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    ".",
                    style: TextStyle(
                      fontSize: TextConfig.textSize_20,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Stack(
          alignment: Alignment.center,

          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // CachedNetworkImage(imageUrl: ImageConfig.firstTitle),
            // CachedNetworkImage(imageUrl: ImageConfig.firstBotton),
            CachedNetworkImage(
              height: Get.height,
              width: Get.width,
              imageUrl: ImageConfig.mddSplach,
              fit: BoxFit.cover,
            ),
            Positioned(
              child: SizedBox(
                height: 100.h,
                width: 100.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.w,
                      width: 50.w,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ), // 进度条颜色
                        strokeWidth: 5.sp, // 进度条粗细
                      ),
                    ),
                    SizedBox(height: 16.sp),
                    _buildLoadingText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
