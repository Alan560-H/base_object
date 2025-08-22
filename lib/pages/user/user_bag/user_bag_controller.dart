import 'package:base_object/core/api/api.dart';
import 'package:base_object/models/backModel/userModel/UserBayModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class UserBagController extends GetxController {
  UserInfo userInfo = Get.find<UserInfo>();
  RxString appbarTitle = "我的钱包".obs;
  Rx<UserBayModel> userBayModel = UserBayModel().obs;
  void getInviteMyBag()async {
    try{
      if(userInfo.isLoginIn){
        EasyLoading.show();
        userBayModel.value = await Api().getInviteMyBag();
        Utils.logError("我的钱包数据 ${userBayModel.toJson()}");
      }
    }catch(e){
      Utils.logError("getInviteMyBag 我的钱包界面报错：$e");
    }finally{
      EasyLoading.dismiss();
    }
  }
  @override
  void onInit() {
    Utils.logError("我的钱包页面初始化");
    // TODO: implement onInit
    getInviteMyBag();
    super.onInit();
  }
}
