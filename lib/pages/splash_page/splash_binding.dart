import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/pages/splash_page/splash_controller.dart';
import 'package:base_object/pages/user/user_controller.dart';
import 'package:get/get.dart';


class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}