import 'package:get/get.dart';

import 'user_edit_info_controller.dart';

class UserEditInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserEditInfoController());
  }
}
