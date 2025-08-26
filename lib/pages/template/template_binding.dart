import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'template_controller.dart';

class TemplateBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());

    Get.lazyPut(() => TemplateController());
  }
}
