import 'package:base_object/pages/short_video/short_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/components/cu_nav_bar/cu_nav_bar_view.dart';

class ShortVideoView2 extends StatelessWidget {
  const ShortVideoView2({super.key});

  get controller => Get.find<ShortVideoController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      bottomNavigationBar: CuNavBarView(),
      body: Text("小视频"),
    );
  }
}
