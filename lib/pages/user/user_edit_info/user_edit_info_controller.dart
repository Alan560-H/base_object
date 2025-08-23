import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/FormModel/LoginForm/LoginForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class UserEditInfoController extends GetxController {
  RxString appbarTitle = "资料编辑".obs;
  UserInfo userInfo = Get.find<UserInfo>();
  BannerTool bannerTool = Get.find<BannerTool>();
  /// 密码控制器
  final passwordController = TextEditingController();
  final inviteCodeController = TextEditingController();
  Rx<LoginForm> loginForm = LoginForm().obs;
  void getSetUser() async {
    try{
      EasyLoading.show(status: "修改密码中...");
      LoginForm param = LoginForm();
      param.password = loginForm.value.password;
      BackModel backModel = await Api.to.getSetUser(param);
      if(backModel.code == CuErrorConfig.success){
        CuToast.success(msg: backModel.data);
      }
    }catch(e){
      Utils.logError("修改密码失败$e");
    }finally{
      EasyLoading.dismiss();
    }
  }
  void getBindInviteUser() async {
    try{
      EasyLoading.show(status: "绑定邀请码中...");
      LoginForm param = LoginForm();
      param.inviteCode = loginForm.value.inviteCode;
      BackModel backModel = await Api.to.getBindInviteUser(param);
      if(backModel.code == CuErrorConfig.success){
        CuToast.success(msg: backModel.data);
        await userInfo.getUserInfoFn();
      }
    }catch(e){
      Utils.logError("绑定邀请码失败$e");
    }finally{
      EasyLoading.dismiss();
    }
  }

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
