import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/LoginForm/LoginForm.dart';
import 'package:base_object/models/FormModel/sendMobileCode/SendMobileCodeModel.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/loginModel/LoginModel.dart';
import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/models/backModel/userModel/UserTodayModel.dart';
import 'package:base_object/models/backModel/verifyCodeImgModel/VerifyCodeImgModel.dart';
import 'package:base_object/pages/home/home_binding.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Common {



  static String getUserIdKey(){
    return 'userId';
  }

  static String getExtraKey(){
    return 'extra';
  }


}
class LoginController extends GetxController {
  final CuNavBarController cuNavBarController = Get.find<CuNavBarController>();
  RxString appbarTitle = "登录页面标题".obs;
  /// ture 为账号登录，false为验证码登录
  RxBool isPasswordLogin = true.obs;
  /// 是否同意用户隐私协议
  RxBool isChecked = false.obs;
  /// 倒计时
  RxInt countdown = 0.obs;
  Rx<LoginModel> loginModel = LoginModel().obs;
  Rx<LoginForm> loginForm = LoginForm().obs;
  /// 倒计时
  Timer? timers;
  /// 图片验证
  late VerifyCodeImgModel verifyCodeImgModel = VerifyCodeImgModel();
  /// 手机号输入框控制器
  final phoneController = TextEditingController();
  /// 图片验证码控制器
  final verifyImgController = TextEditingController();
  /// 手机验证码输入控制器
  final codeController = TextEditingController();
  /// 密码控制器
  final passwordController = TextEditingController();
  /// 账号控制器
  final accountController = TextEditingController();

  /// 获取图片验证码
  Future<void> getVerifyCodeImg() async {
    try{
      VerifyCodeImgModel verifyCodeImgModel1 = await Api.to.postVerifyCodeImg();
      verifyCodeImgModel = verifyCodeImgModel1;
      Utils.logError("图片验证码${verifyCodeImgModel.toJson()}");
    }catch(e){
      Utils.logError("getVerifyCodeImg请求出错: $e");
    }
  }
  /// 倒计时
  void startCountdown() async {
    if (countdown.value > 0) return;
    SendMobileCodeModel sendMobileCodeModel = SendMobileCodeModel(
      mobile: phoneController.text,
      verifyId: verifyCodeImgModel.verifyId!,
      verifyCode: verifyImgController.text,
    );
    sendMobileCodeModel.type = 0;
    if(sendMobileCodeModel.mobile.isEmpty){
      Get.snackbar("提示", "请先输入手机号");
      return;
    }
    /// 发送手机验证码
    BackModel backModel = await Api.to.postSendMobileCode(sendMobileCodeModel);
    if(backModel.code == CuErrorConfig.success){
      countdown.value = 60;
      timers = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown.value == 0) {
          timers?.cancel();
          return;
        }
        countdown.value--;
      });
    }
  }
  /// 重置状态
  void swicthLoginType() {
    FocusManager.instance.primaryFocus?.unfocus();
      accountController.clear();
      phoneController.clear();
      codeController.clear();
      passwordController.clear();
      verifyImgController.clear();
      loginModel = LoginModel().obs;
      loginForm = LoginForm().obs;
  }
  /// 登录按钮
  void submitForm() async {
    try{

      if (!isChecked.value) {
        Get.snackbar("提示", "请先同意相关协议再登录");
        return;
      }
      EasyLoading.show(status: "登录中...");
      Utils.logError(loginForm.value.toJson());
      loginModel.value = await Api.to.login(loginForm.value);
      if (loginModel.value.tokenValue.isEmpty) return;
      UserInfo.instance.setToken(value: loginModel.value.tokenValue,key: loginModel.value.tokenValue);
      UserModel userModel = await Api.to.getUserInfo();
      if (userModel.id != 0) {
        CuToast.success(msg: "登录成功");
        UserInfo.instance.updateUserModel(userModel);
        UserTodayModel userTodayModel = await Api.to.getTodayAmount();
        UserInfo.instance.updateUserTodayModel(userTodayModel);
        Utils.logError("用户今日收益：${userTodayModel.toJson()}");
        DateTime now = DateTime.now();
        int timestampMs  = now.millisecondsSinceEpoch;
        Get.delete<InitTool>();
        Get.delete<RewarderTool>();
        // 等待当前帧结束（约16ms），让GetX完成实际销毁
        await Future.delayed(const Duration(milliseconds: 20));
        // 此时检查，返回 false（旧实例已被移除）
        Utils.logError("是否注册：${Get.isRegistered<InitTool>()}");
        Get.put<InitTool>(InitTool());
        Get.put<RewarderTool>(RewarderTool());
        await Future.delayed(const Duration(milliseconds: 20));
        if(!Get.isRegistered<InitTool>()){
          Get.put<InitTool>(InitTool());
        }
        bool isInitAd = await InitTool.to.initTopon();
        InitTool.to.setCustomDataDic({
          "user_id":"${UserInfo.instance.userModel.id}",
          "extra": "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_$timestampMs",
        });
        RewarderTool.to.loadRewardedVideo(
            userID: UserInfo.instance.userModel.id,
            extra: "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_$timestampMs");
        swicthLoginType();
        isChecked.value =false;
        Get.offNamed(AppRoutes.home);
        Utils.logError("是否显示弹窗：${UserInfo.instance.userModel.inviteUserId==null||UserInfo.instance.userModel.inviteUserId==0}");
        if(UserInfo.instance.userModel.inviteUserId==null||UserInfo.instance.userModel.inviteUserId==0){
          Dialogs.showCommonDialog(dialogType: "BindViteCodeDialog",dialogTitle: "绑定上级邀请人");
        }
      }
    }catch(e){
      Utils.logError("登录出错: $e");
    }finally{
      EasyLoading.dismiss();
  }
  }
}
