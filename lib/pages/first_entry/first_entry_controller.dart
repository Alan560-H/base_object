import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:get/get.dart';

class FirstEntryController extends GetxController {
  RxString appbarTitle = "模板页面标题".obs;
  void goHome() async {
    await LocalStorage.setString("isFirst", false);
    Get.offNamed(AppRoutes.home);
  }
}
