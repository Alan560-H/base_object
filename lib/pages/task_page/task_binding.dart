import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'task_controller.dart';

class TaskBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());

    Get.lazyPut(() => TaskController());
  }
}
