import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class LeaderRecruitController extends GetxController {
  RxString appbarTitle = "团长招募".obs;
  BannerTool bannerTool = Get.find<BannerTool>();

  @override
  void onReady() {
    // TODO: implement onReady‘
    Utils.logError("团长招募界面onReady");
    super.onReady();
  }
  @override
  void onClose() {
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    Utils.logError("团长招募界面onClose");
    super.onClose();
  }
  @override
  void onInit() {
    Utils.logError("团长招募界面初始化");
    // TODO: implement onInit
    if(!Get.isRegistered<BannerTool>()){
      Get.put(BannerTool());
    }
    bannerTool.hideBannerAd();
    super.onInit();
  }
}
