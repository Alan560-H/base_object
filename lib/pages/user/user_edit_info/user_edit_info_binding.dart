import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:get/get.dart';

import 'user_edit_info_controller.dart';

class UserEditInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(BannerTool());
    Get.put(Api());
    Get.lazyPut(() => UserEditInfoController());
  }
}
