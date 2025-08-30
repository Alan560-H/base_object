import 'package:get/get.dart';

import '../../core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'dj_video_controller.dart';

class DjVideoBinding implements Bindings {
  @override
  void dependencies() {
    CuNavBarBinding().dependencies();
    Get.lazyPut(() => DjVideoController());
  }
}
