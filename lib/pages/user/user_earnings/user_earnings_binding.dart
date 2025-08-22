import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/pages/invite/invite_binding.dart';
import 'package:base_object/pages/user/user_bag/user_bag_binding.dart';
import 'package:get/get.dart';

import 'user_earnings_controller.dart';

class UserEarningsBinding implements Bindings {
  @override
  void dependencies() {
    UserBagBinding().dependencies();
    InviteBinding().dependencies();
    Get.put(BannerTool());
    Get.put(Api());
    Get.lazyPut(() => UserEarningsController());
  }
}
