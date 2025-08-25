import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/pages/dj_video/dj_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DjVideoView extends GetView<DjVideoController> {
  const DjVideoView({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      bottomNavigationBar: CuNavBarView(),
      body: PangrowthVideo.drawHomeView(
        viewWidth: 10.sw,
        viewHeight: 1.sh - ScreenUtil().statusBarHeight,
      ),
    );
  }
}
