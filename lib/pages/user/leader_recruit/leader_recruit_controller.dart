import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class LeaderRecruitController extends GetxController {
  RxString appbarTitle = "团长招募".obs;

  @override
  void onReady() {
    // TODO: implement onReady‘
    Utils.logError("团长招募界面onReady");
    super.onReady();
  }

  @override
  void onClose() {
    BannerTool.to.afreshShowBannerAd();
    // TODO: implement onClose
    Utils.logError("团长招募界面onClose");
    super.onClose();
  }

  @override
  void onInit() {
    Utils.logError("团长招募界面初始化");

    BannerTool.to.hideBannerAd();
    super.onInit();
  }
}
