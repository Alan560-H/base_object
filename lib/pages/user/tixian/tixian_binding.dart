import 'package:get/get.dart';

import 'tixian_controller.dart';


class TixianBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TixianController());
  }
}
