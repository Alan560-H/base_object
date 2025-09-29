import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'invite_controller.dart';

class InviteBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());
    Get.lazyPut(() => InviteController());
  }
}
