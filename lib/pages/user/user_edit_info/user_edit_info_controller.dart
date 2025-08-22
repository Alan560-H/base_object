import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class UserEditInfoController extends GetxController {
  RxString appbarTitle = "资料编辑".obs;
  UserInfo userInfo = Get.find<UserInfo>();
  BannerTool bannerTool = Get.find<BannerTool>();

  @override
  void onInit() {
    // TODO: implement onInit
    Utils.logError("资料编辑页面初始化");
    bannerTool.hideBannerAd();
    super.onInit();
  }
  @override
  void onClose() {
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    super.onClose();
  }
}
