import 'package:get/get.dart';

import 'user_invite_controller.dart';

class UserInviteBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserInviteController());
  }
}
