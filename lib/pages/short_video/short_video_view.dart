import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_video_controller.dart';

class ShortVideoView extends GetView<ShortVideoController> {
  const ShortVideoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
            () =>PangrowthVideo.videoSingleCardView(
              viewWidth: 10.sw,
              viewHeight: 1.sh - ScreenUtil().statusBarHeight,
            ),
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }

}
