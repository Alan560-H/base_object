import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/pages/splash_page/splash_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CachedNetworkImage(imageUrl: ImageConfig.firstTitle),
            CachedNetworkImage(imageUrl: ImageConfig.firstBotton),
          ],
        ),
      ),
    );
  }
}
