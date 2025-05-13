import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/pages/user/user_controller.dart';
import 'package:get/get.dart';

import 'index_controller.dart';

class IndexBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IndexController());
    Get.lazyPut(()=> HomeController());
    Get.lazyPut(()=> UserController());
  }
}