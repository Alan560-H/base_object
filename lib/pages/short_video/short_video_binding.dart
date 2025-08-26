import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'short_video_controller.dart';

class ShortVideoBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());
    Get.lazyPut(() => ShortVideoController());
  }
}
