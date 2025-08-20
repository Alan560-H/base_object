import 'package:base_object/pages/user/leader_recruit/leader_recruit_controller.dart';
import 'package:base_object/pages/user/user_binding.dart';
import 'package:get/get.dart';

import 'transaction_details_controller.dart';


class TransactionDetailsBinding implements Bindings {
  @override
  void dependencies() {
    UserBinding().dependencies();
    Get.lazyPut(() => TransactionDetailsController());
  }
}
