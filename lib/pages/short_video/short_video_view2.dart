import 'package:base_object/pages/short_video/short_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:get/get.dart';

class ShortVideoView2 extends StatelessWidget {
  const ShortVideoView2({super.key});

  get controller => Get.find<ShortVideoController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0, backgroundColor: Colors.black),
      body: Builder(
        builder: (context) {
          print("context.height: ${context.height}");
          print("context.width: ${context.width}");
          return PangrowthVideo.videoSingleCardView(viewWidth: context.height, viewHeight: context.width);
        },
      ),
    );
  }
}
