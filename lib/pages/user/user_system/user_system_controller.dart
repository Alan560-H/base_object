import 'package:base_object/store/user_info.dart';
import 'package:get/get.dart';

class UserSystemController extends GetxController {
  final UserInfo userInfo = Get.find<UserInfo>();

  RxString appbarTitle = "我的设置页面标题".obs;
}
