import 'package:get/get.dart';

import 'cu_nav_bar_controller.dart';

class CuNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CuNavBarController());
  }
}
