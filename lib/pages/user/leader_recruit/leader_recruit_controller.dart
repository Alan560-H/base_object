import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/FormModel/appUpLoadForm/AppUpLoadForm.dart';
import 'package:base_object/models/backModel/serviceModel/ServiceModel.dart';
import 'package:base_object/store/store.dart';
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

    // TODO: implement onInit
    if (!Get.isRegistered<BannerTool>()) {
      Get.put(BannerTool());
    }
    BannerTool.to.hideBannerAd();
    super.onInit();
  }
}
