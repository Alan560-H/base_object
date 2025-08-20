import 'package:base_object/pages/user/user_binding.dart';
import 'package:get/get.dart';

import 'user_system_controller.dart';

class UserSystemBinding implements Bindings {
  @override
  void dependencies() {
    UserBinding().dependencies();
    Get.lazyPut(() => UserSystemController());
  }
}
