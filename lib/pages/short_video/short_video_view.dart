import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_video_controller.dart';

class ShortVideoView extends GetView<ShortVideoController> {
  const ShortVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Placeholder(),

      // body: PangrowthVideo.videoSingleCardView(
      //   viewWidth: 10.sw,
      //   viewHeight: 1.sh - ScreenUtil().statusBarHeight,
      // ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
