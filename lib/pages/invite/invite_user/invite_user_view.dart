import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/localModels/BannerVo.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'invite_user_controller.dart';

class InviteUserView extends GetView<InviteUserController> {
  const InviteUserView({super.key});

  /// 轮播图
  Widget get swiperWidget {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.7),
      margin: EdgeInsets.only(top: Get.mediaQuery.padding.top + 30.h),
      child: FlutterCarousel(
        options: FlutterCarouselOptions(
          height: double.infinity,
          viewportFraction: 1.0,
          enableInfiniteScroll: true,
          autoPlay: true,
          showIndicator: true,
          slideIndicator: CircularSlideIndicator(),
          onPageChanged: controller.onPageChanged,
        ),
        items:
            controller.swipers.asMap().entries.map((banner) {
              BannerVo item = banner.value;
              int index = banner.key;
              return RepaintBoundary(
                key: controller.bannerKeys.length > index ? controller.bannerKeys[index] : null,
                child: Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: Get.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Stack(
                        children: [
                          // 背景
                          CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            errorWidget:
                                (context, url, error) => Icon(Icons.error),
                          ),
                          // 海报
                          Positioned(
                            top: 150.h,
                            left: 70.w,
                            child: Container(
                              padding: EdgeInsets.all(10.sp),
                              width: 210.w,
                              height: 250.h,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: QrImageView(
                                        data:
                                            "https://www.pgyer.com/chuanjiabao-android",
                                        version: QrVersions.auto,
                                        size: 140.r,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    spacing: 10.w,
                                    children: [
                                      Avatar(
                                        headImage:
                                            controller
                                                .userInfo
                                                .userModel
                                                .headImage,
                                        size: 20.r,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller
                                                .userInfo
                                                .userModel
                                                .username,
                                          ),
                                          Text(
                                            "邀请码：${controller.userInfo.userModel.inviteCode}",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
        // controller.swipers.map((item) {

        // }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            color: TextConfig.fensePageColor,
            image: DecorationImage(
              image: CachedNetworkImageProvider(ImageConfig.commonBg),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              swiperWidget,
              Container(
                height: 170.h,
                width: Get.width,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 可选择选项，包括复制链接，以及微信邀请
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              bool success = await Utils.copyText(
                                "https://www.pgyer.com/chuanjiabao-android",
                              );
                              if (success) {
                                CuToast.success(msg: "复制成功");
                              } else {
                                CuToast.error(msg: "复制失败");
                              }
                            },
                            child: Column(
                              children: [
                                Icon(Icons.link, size: TextConfig.textSize_30),
                                Text(
                                  "复制链接",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: controller.saveImage,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.download_outlined,
                                  size: TextConfig.textSize_30,
                                ),
                                Text(
                                  "保存图片",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    CuButton(
                      text: "取消",
                      width: Get.width,
                      fontSize: TextConfig.textSize_20,
                      textColor: TextConfig.primary,
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CuNavBarView(),
    );
  }
}
