import 'package:get/get.dart';

import '../cu_circular_progress/cu_circular_progress_controller.dart';
import 'cu_nav_bar_controller.dart';

class CuNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CuNavBarController());

  }
}
