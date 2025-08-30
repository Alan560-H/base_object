import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/pages/invite/invite_binding.dart';
import 'package:get/get.dart';

import 'user_controller.dart';

class UserBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());
    InviteBinding().dependencies();
    // 个人中心不需要独立控制器
    Get.lazyPut(()=>UserController());
  }
}