import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(RewarderTool());
    Get.put(Api());
    Get.put(NativeTool());
    CuNavBarBinding().dependencies();
    Get.lazyPut(() => HomeController());
    // 可以在这里注入首页需要的其他服务
  }
}