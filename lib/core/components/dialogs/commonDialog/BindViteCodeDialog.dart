import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/FormModel/LoginForm/LoginForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BindViteCodeDialog extends StatefulWidget {
  /// 实名认证
  const BindViteCodeDialog({super.key});

  @override
  State<BindViteCodeDialog> createState() => _BindViteCodeDialogState();
}

class _BindViteCodeDialogState extends State<BindViteCodeDialog> {
  /// 邀请码控制器
  final TextEditingController inviteCodeController = TextEditingController();

  @override
  void dispose() {
    inviteCodeController.dispose();
    super.dispose();
  }

  Rx<LoginForm> loginForm = LoginForm().obs;
  void getBindInviteUser() async {
    try {
      EasyLoading.show(status: "绑定邀请码中...");
      if (!Get.isRegistered<Api>()) {
        Get.put(Api());
      }
      LoginForm param = LoginForm();
      param.inviteCode = loginForm.value.inviteCode;
      BackModel backModel = await Api.to.getBindInviteUser(param);
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: backModel.data);
        await UserInfo.instance.getUserInfoFn();
        Get.back();
      }
    } catch (e) {
      Utils.logError("绑定邀请码失败$e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: Get.height * 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        spacing: 10.h,
        children: [
          Row(
            spacing: 5.w,
            children: [
              // Text("上级邀请码"),
              Expanded(
                child: CustomInputField(
                  defaultValue:
                      "${UserInfo.instance.userModel.inviteUserId ?? ''}",
                  controller: inviteCodeController,
                  bgColor: TextConfig.inputBgcolor,
                  textSize: TextConfig.textSize_12,
                  height: 40.h,
                  hintText: '输入上级邀请码',
                  onChanged: (value) async {
                    loginForm.value.inviteCode = value;
                  },
                  validator: (value) {
                    return null;
                  },
                ),
              ),
            ],
          ),
          CuButton(
            text: "保存",
            width: 100.w,
            height: 40.h,
            fontSize: TextConfig.textSize_16,
            onPressed: () {
              getBindInviteUser();
            },
            bgColor: TextConfig.primary,
            radius: 10.r,
          ),
        ],
      ),
    );
  }
}
