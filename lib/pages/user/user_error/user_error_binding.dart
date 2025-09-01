import 'package:get/get.dart';

import 'user_error_controller.dart';

class UserErrorBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserErrorController());
  }
}
