import 'package:base_object/store/user_info.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserSystemController extends GetxController {
  final UserInfo userInfo = Get.find<UserInfo>();
  /// 获取包信息
  Rx<PackageInfo> packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  ).obs;
  RxString appbarTitle = "设置".obs;
  @override
  void onInit() async {
    // TODO: implement onInit
    packageInfo.value = await PackageInfo.fromPlatform();
    super.onInit();
  }
}
