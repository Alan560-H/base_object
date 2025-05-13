import 'package:get/get.dart';

import 'details_controller.dart';

class DetailBinding implements Bindings {
  @override
  void dependencies() {
    // 不需要再次绑定HomeController，因为已经存在
    Get.lazyPut(() => DetailController());
  }
}