import 'package:get/get.dart';

import 'user_service_controller.dart';

class UserServiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserServiceController());
  }
}
