import 'dart:async';
import 'dart:developer';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// 领取红包
class ClaimRedBag extends StatefulWidget {
  final RxDouble data;

  /// 回调
  final void Function(dynamic callBackData)? onClick;

  /// 领取红包
  const ClaimRedBag({super.key, required this.onClick, required this.data});

  @override
  State<ClaimRedBag> createState() => _ClaimRedBagState();
}

class _ClaimRedBagState extends State<ClaimRedBag> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.sp)),
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(ImageConfig.hongbaoCover),
              ),
            ),
            height: 350.h,
            width: 300.w,
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                    EasyLoading.show(status: "正在领取奖励中...");
                    RewarderTool.to.showRewardedVideoFlutter();
                  },
                  child: Container(
                    padding: EdgeInsets.all(30.sp),
                    width: Get.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 30.h),
                        Text(
                          "请完整观看完广告后，方可领取奖励。红包领取失败，请重新观看广告",
                          style: TextStyle(
                            fontSize: TextConfig.textSize_20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0.h,
                  right: 0.w,
                  child: CuButton(
                    text: "",
                    icons: Icons.close,
                    fontSize: TextConfig.textSize_24,
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
