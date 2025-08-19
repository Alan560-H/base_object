import 'package:get/get.dart';

import 'invite_controller.dart';

class InviteBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InviteController());
  }
}
