import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'user_invite_controller.dart';

class UserInviteBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());
    Get.lazyPut(() => UserInviteController());
  }
}
