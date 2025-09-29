import 'package:get/get.dart';

import 'invite_user_controller.dart';

class InviteUserBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InviteUserController());
  }
}
