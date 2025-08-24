
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:get/get.dart';

import 'dj_video_controller.dart';

class DjVideoView extends StatefulWidget {
  const DjVideoView({super.key});

  @override
  State<DjVideoView> createState() => _DjVideoViewState();
}

class _DjVideoViewState extends State<DjVideoView> {
  get controler => Get.find<DjVideoController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(elevation: 0, toolbarHeight: 0, backgroundColor: Colors.black),
        body: Builder(
          builder: (context) {
            print("context.height: ${context.height}");
            print("context.width: ${context.width}");
            return PangrowthVideo.drawHomeView(viewWidth: context.height, viewHeight: context.width);
          },
        ),
      ),
    );
  }
}
