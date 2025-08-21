import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class ShortVideoController extends GetxController {
  RxString appbarTitle = "短视频页面标题".obs;
  @override
  void onReady() {
    // TODO: implement onReady‘
    Utils.logError("短视频页面onReady");
    super.onReady();
  }
  @override
  void onClose() {
    // TODO: implement onClose
    Utils.logError("短视频页面onClose");
    super.onClose();
  }
  @override
  void onInit() {
    Utils.logError("短视频页面初始化");
    // TODO: implement onInit
    super.onInit();
  }
}
