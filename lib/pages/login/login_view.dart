import 'dart:convert';

import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  get logoAndBanner {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
      constraints: BoxConstraints(maxHeight: 380.h, maxWidth: Get.width),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.topCenter,
          fit: BoxFit.contain,
          image: CachedNetworkImageProvider(ImageConfig.loginBg2),
        ),
      ),
      child: CachedNetworkImage(imageUrl: ImageConfig.logo, height: 160.h),
    );
  }

  /// 登录类型切换
  Widget _buildTypeToggle() {
    return Obx(
      () => Container(
        constraints: BoxConstraints(maxHeight: 40.h, maxWidth: Get.width),
        child: Row(
          spacing: 20.w,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                // 设置下边框，宽度为 2，颜色为蓝色
                border:
                    controller.isPasswordLogin.value
                        ? Border(
                          bottom: BorderSide(
                            color: TextConfig.primary,
                            width: 2.sp,
                          ),
                        )
                        : null,
              ),
              child: CuButton(
                width: 120.w,
                textColor:
                    controller.isPasswordLogin.value
                        ? Colors.white
                        : Utils.fromHex("#6d6d6d"),
                fontSize: TextConfig.textSize_16,
                text: "账号登录",
                onPressed: () {
                  controller.swicthLoginType();
                  controller.isPasswordLogin.value = true;
                },
                // iconImg:
                // controller.isPasswordLogin.value
                //     ? ImageConfig.login_pwd_active
                //     : ImageConfig.login_pwd_default,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                // 设置下边框，宽度为 2，颜色为蓝色
                border:
                    !controller.isPasswordLogin.value
                        ? Border(
                          bottom: BorderSide(
                            color: TextConfig.primary,
                            width: 2,
                          ),
                        )
                        : null,
              ),
              child: CuButton(
                width: 130.w,
                textColor:
                    !controller.isPasswordLogin.value
                        ? Colors.white
                        : Utils.fromHex("#6d6d6d"),
                fontSize: TextConfig.textSize_16,
                text: "验证码登录",
                onPressed: () async {
                  await controller.getVerifyCodeImg();
                  controller.swicthLoginType();
                  controller.loginForm.value.loginType = 2;
                  controller.isPasswordLogin.value = false;
                },
                // iconImg:
                // !_isPasswordLogin
                //     ? ImageConfig.login_code_active
                //     : ImageConfig.login_code_default,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 服务协议和隐私协议
  Widget checkedXieyi() {
    return Row(
      children: [
        Checkbox(
          activeColor: TextConfig.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: controller.isChecked.value,
          onChanged: (bool? value) {
            controller.isChecked.value = value ?? false;
          },
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              controller.isChecked.value = !controller.isChecked.value;
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '我已年满18岁，登录即同意',
                    style: TextStyle(color: TextConfig.black333),
                  ),
                  TextSpan(
                    text: '用户协议',
                    style: TextStyle(color: TextConfig.primary),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Utils.openUrl(AppConfig.instance.protocolUri);
                          },
                  ),
                  TextSpan(
                    text: ' 和 ',
                    style: TextStyle(color: TextConfig.black333),
                  ),
                  TextSpan(
                    text: '隐私协议',
                    style: TextStyle(color: TextConfig.primary),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Utils.openUrl(AppConfig.instance.policyUri);
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 账号登录
  List<Widget> _buildPasswordForm() {
    return [
      /// 账号登录
      CustomInputField(
        key: GlobalKey(),
        height: 50.h,
        bgColor: TextConfig.inputBgcolor,
        hintText: "请输入账号",
        onChanged: (value) {
          controller.loginForm.value.account = value;
        },
        controller: controller.accountController,
      ),
      CustomInputField(
        key: GlobalKey(),
        height: 50.h,
        inputFieldType: InputFieldType.password,
        bgColor: TextConfig.inputBgcolor,
        hintText: "请输入密码",
        onChanged: (value) {
          controller.loginForm.value.password = value;
        },
        controller: controller.passwordController,
      ),
    ];
  }

  /// 验证码登录
  List<Widget> _buildCodeLoginForm() {
    return [
      CustomInputField(
        key: GlobalKey(),
        height: 50.h,
        onChanged: (value) {
          controller.loginForm.value.mobile = value;
        },
        bgColor: TextConfig.inputBgcolor,
        hintText: "请输入手机号",
        controller: controller.phoneController,
      ),

      controller.verifyCodeImgModel.value.verifyId != '0'
          ? SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                CustomInputField(
                  height: 50.h,
                  bgColor: TextConfig.inputBgcolor,
                  hintText: "请输入图片验证码",
                  onChanged: (value) {},
                  controller: controller.verifyImgController,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => controller.getVerifyCodeImg(),
                    child: SizedBox(
                      width: 60.w,
                      height: 50.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        // 设置圆角半径，这里假设使用了 flutter_screenutil 的 r 单位
                        child: SizedBox(
                          width: 60.w,
                          height: 50.h,
                          child:
                              controller.verifyCodeImgModel.value.img != null
                                  ? Obx(
                                    () => Image.memory(
                                      base64.decode(
                                        controller.verifyCodeImgModel.value.img!
                                            .split(',')
                                            .last,
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                  : Text('点击刷新'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          : Container(),
      SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            CustomInputField(
              height: 50.h,
              bgColor: TextConfig.inputBgcolor,
              hintText: "请输入验证码",
              onChanged: (value) {
                controller.loginForm.value.mobileCode = value;
              },
              controller: controller.codeController,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: CuButton(
                width: 120.w,
                height: 50.h,
                text:
                    controller.countdown.value > 0
                        ? '${controller.countdown.value}秒后重发'
                        : '发送验证码',
                onPressed:
                    controller.countdown.value == 0
                        ? controller.startCountdown
                        : null,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  /// 登录按钮 立即登录
  Widget _buildSubmitButton() {
    return CuButton(
      height: 40.h,
      width: 200.w,
      text: "",
      bgImage: ImageConfig.loginBtn,
      onPressed: controller.submitForm,
    );
  }

  Widget _loginWithWechat() {
    return Obx(
      () => Container(
        constraints: BoxConstraints(maxWidth: Get.width),
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          spacing: 20.h,
          children: [
            CuButton(
              text: "",
              width: 250.w,
              height: 50.h,
              bgImage: ImageConfig.loginBg1,
              fontSize: TextConfig.textSize_20,
              onPressed: controller.wxLogin,
            ),
            checkedXieyi(),
            CuButton(
              width: 150.w,
              text: "切换到账号登录",
              textColor: Colors.blue,
              onPressed: () {
                controller.isWechatLogin.value = false;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 动态表单
  Widget _buildDynamicForm() {
    return Obx(
      () => Container(
        constraints: BoxConstraints(maxWidth: Get.width),
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          spacing: 20.h,
          children: [
            ...(controller.isPasswordLogin.value
                ? _buildPasswordForm()
                : _buildCodeLoginForm()),
            checkedXieyi(),
            _buildSubmitButton(),
            CuButton(
              width: 150.w,
              text: "切换到微信登录",
              textColor: Colors.blue,
              onPressed: () {
                controller.isWechatLogin.value = true;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          logoAndBanner,
          Obx(
            () =>
                !controller.isWechatLogin.value
                    ? Positioned(top: 260.h, child: _buildTypeToggle())
                    : Container(),
          ),
          Obx(
            () =>
                controller.isWechatLogin.value
                    ? Positioned(top: 450.h, child: _loginWithWechat())
                    : Positioned(top: 310.h, child: _buildDynamicForm()),
          ),
        ],
      ),
    );
  }
}
