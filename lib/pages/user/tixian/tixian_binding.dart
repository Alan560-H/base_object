import 'package:base_object/core/api/api.dart';
import 'package:get/get.dart';

import 'tixian_controller.dart';


class TixianBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Api());
    Get.lazyPut(() => TixianController());
  }
}
