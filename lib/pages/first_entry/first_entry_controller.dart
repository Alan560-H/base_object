import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:get/get.dart';

class FirstEntryController extends GetxController {
  RxString appbarTitle = "模板页面标题".obs;
  RxBool loading = true.obs;
  void goHome() async {
    await LocalStorage.setString("isFirst", false);
    Get.offAllNamed(AppRoutes.splashPage);
  }
  @override
  void onInit()async {
    // TODO: implement onInit
    String? isFirst = await LocalStorage.getString("isFirst");
    Utils.logError("执行跳转首页$isFirst");
    if (isFirst != null) {
      Get.offAllNamed(AppRoutes.splashPage);
      loading.value = true;
    }else{
      loading.value = false;
    }
    super.onInit();
  }
}
