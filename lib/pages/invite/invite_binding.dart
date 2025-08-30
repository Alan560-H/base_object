import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import '../../core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'invite_controller.dart';

class InviteBinding implements Bindings {
  @override
  void dependencies() {
    CuNavBarBinding().dependencies();
    Get.put(Api());
    Get.lazyPut(() => InviteController());
  }
}
