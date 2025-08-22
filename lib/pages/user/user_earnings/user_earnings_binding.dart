import 'package:get/get.dart';

import 'user_earnings_controller.dart';

class UserEarningsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserEarningsController());
  }
}
