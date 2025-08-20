import 'dart:async';

import 'package:base_object/models/backModel/verifyCodeImgModel/VerifyCodeImgModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  RxString appbarTitle = "登录页面标题".obs;
  /// ture 为账号登录，false为验证码登录
  RxBool isPasswordLogin = true.obs;
  /// 是否同意用户隐私协议
  RxBool isChecked = false.obs;
  /// 倒计时
  RxInt countdown = 0.obs;
  /// 倒计时
  Timer? timer;
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

}
