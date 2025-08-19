import 'package:get/get.dart';

import 'dj_video_controller.dart';

class DjVideoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DjVideoController());
  }
}
