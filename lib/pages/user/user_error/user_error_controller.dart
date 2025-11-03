import 'package:base_object/core/components/dialogs/interAdDialog/interAdDialog.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/store/user_info.dart';
import 'package:get/get.dart';

class UserErrorController extends GetxController {
  RxString appbarTitle = "设备检查不通过".obs;

  @override
  void onInit() {
    super.onInit();
    UserInfo.instance.loginOutNoGo();
    BannerTool.to.removeBannerAd();
    NativeTool.to.removeNativeAd();
    InterAdDialog.to.cancelTimer();
  }
}
