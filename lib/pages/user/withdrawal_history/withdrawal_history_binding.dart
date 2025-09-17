import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/pages/user/user_bag/user_bag_binding.dart';
import 'package:get/get.dart';

import 'withdrawal_history_controller.dart';

class WithdrawalHistoryBinding implements Bindings {
  @override
  void dependencies() {
    UserBagBinding().dependencies();
    Get.lazyPut(() => WithdrawalHistoryController());
  }
}
