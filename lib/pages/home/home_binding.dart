import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // 注入进度条控制器
    Get.put<CuCircularProgressController>(CuCircularProgressController());
    CuNavBarBinding().dependencies();
    Get.lazyPut(() => HomeController());
    // 可以在这里注入首页需要的其他服务
  }
}
