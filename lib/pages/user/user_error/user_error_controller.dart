import 'package:base_object/core/components/dialogs/interAdDialog/interAdDialog.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/store/user_info.dart';
import 'package:get/get.dart';

class UserErrorController extends GetxController {
  RxString appbarTitle = "设备检查不通过".obs;
  final RxString errorMsg = "".obs; // 存储消息的响应式变量
  @override
  void onInit() {
    super.onInit();
    // 接收命名路由传递的参数（同样是 Get.arguments）
    if (Get.arguments != null) {
      errorMsg.value = Get.arguments as String; // 强转为 String
    }
    UserInfo.instance.loginOutNoGo();
    BannerTool.to.removeBannerAd();
    NativeTool.to.removeNativeAd();
    InterAdDialog.to.cancelTimer();
  }
}
