import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/pages/splash_page/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<InitTool>(InitTool());
    Get.put(SplashController());
  }
}
