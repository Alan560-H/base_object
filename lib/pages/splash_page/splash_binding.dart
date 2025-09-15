import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/pages/splash_page/splash_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:get/get.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<InitTool>(InitTool());
    Get.put(SplashController());
  }
}
