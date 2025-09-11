import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'user_pay_list_controller.dart';

class UserPayListBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserPayListController());
  }
}
