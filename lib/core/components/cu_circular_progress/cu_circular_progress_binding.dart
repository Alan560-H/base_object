import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'cu_circular_progress_controller.dart';

class CuCircularProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Api());
    Get.lazyPut<CuCircularProgressController>(
      () => CuCircularProgressController(),
    );
  }
}
