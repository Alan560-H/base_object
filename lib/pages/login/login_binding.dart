import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    CuNavBarBinding().dependencies();
    Get.put(Api());
    Get.lazyPut(() => LoginController());

  }
}
