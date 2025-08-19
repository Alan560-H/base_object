import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    CuNavBarBinding().dependencies();
    Get.lazyPut(() => HomeController());
    // 可以在这里注入首页需要的其他服务
  }
}