import 'package:get/get.dart';

import 'withdrawal_history_controller.dart';

class WithdrawalHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WithdrawalHistoryController());
  }
}
