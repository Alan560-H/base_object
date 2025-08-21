import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:get/get.dart';

import 'user_controller.dart';

class UserBinding implements Bindings {
  @override
  void dependencies() {
    // 个人中心不需要独立控制器
    Get.lazyPut(()=>CuNavBarController());
    Get.lazyPut(()=>UserController());
  }
}