import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:get/get.dart';

import '../../core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'short_video_controller.dart';

class ShortVideoBinding implements Bindings {
  @override
  void dependencies() {
    CuNavBarBinding().dependencies();
    Get.put(Api());
    Get.put(NativeTool());
    Get.lazyPut(() => ShortVideoController());
  }
}
