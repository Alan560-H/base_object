import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'user_bag_controller.dart';

class UserBagBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());
    Get.lazyPut(() => UserBagController());
  }
}
