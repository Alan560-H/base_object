import 'package:get/get.dart';

import 'first_entry_controller.dart';

class FirstEntryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FirstEntryController());
  }
}
