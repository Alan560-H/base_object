import 'package:base_object/pages/splash_page/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Obx(
          ()=>Center(
            child: Text(controller.appbarTitle.value),
          )
      )
     ,
    );
  }


}
