import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dj_video_controller.dart';

class DjVideoView extends GetView<DjVideoController> {
  const DjVideoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Column(
          children: [
            CuAppBar(title: controller.appbarTitle.value,showBackArrow: false,),
          ],
        )
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
