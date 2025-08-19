import 'package:get/get.dart';

import 'short_video_controller.dart';

class ShortVideoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShortVideoController());
  }
}
