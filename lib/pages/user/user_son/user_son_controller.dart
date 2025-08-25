import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/backModel/userModel/UserSonModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class UserSonController extends GetxController {
  RxString appbarTitle = "我的徒弟".obs;
  BannerTool bannerTool = Get.find<BannerTool>();
  Rx<UserSonModel> userSonModel = UserSonModel().obs;
  // 获取收入表
  Future<void> getInviteMyInvite() async {
    try{
      EasyLoading.show(status: "获取数据中...");
      userSonModel.value.userList.clear();
      userSonModel.value = await Api.to.getInviteMyInvite();
      Utils.logError("我的徒弟列表${userSonModel.value.userList}");
    }catch(e){
      Utils.logError("我的徒弟列表报错：$e");
    }finally{
      EasyLoading.dismiss();
    }
  }
  @override
  void onInit() {
    // TODO: implement onInit
    Utils.logError("我的徒弟页面初始话");
    bannerTool.hideBannerAd();
    getInviteMyInvite();
    super.onInit();
  }
  @override
  void onClose() {
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    super.onClose();
  }
}
