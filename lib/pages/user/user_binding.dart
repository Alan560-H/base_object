import 'package:base_object/pages/user/user_controller.dart';
import 'package:get/get.dart';

class UserBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController());
  }
}
