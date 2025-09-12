import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/FormModel/LoginForm/LoginForm.dart';
import 'package:base_object/models/FormModel/withdrawal/WithdrawalForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:base_object/pages/user/user_pay_list/user_pay_list_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditPayAccountDialog extends StatefulWidget {
  final UserPayLModel userPayLModel;

  /// 编辑或者新增支付方式
  const EditPayAccountDialog({super.key, required this.userPayLModel});

  @override
  State<EditPayAccountDialog> createState() => _EditPayAccountDialogState();
}

class _EditPayAccountDialogState extends State<EditPayAccountDialog> {
  /// 姓名
  final TextEditingController payNameController = TextEditingController();

  /// 账号
  final TextEditingController payAccountController = TextEditingController();

  /// 表单载荷
  final Rx<WithdrawalForm> commitForm = WithdrawalForm().obs;
  @override
  initState() {
    super.initState();
    commitForm.value.payName = widget.userPayLModel.payName;
    commitForm.value.payAccount = widget.userPayLModel.payAccount;
    commitForm.value.id = widget.userPayLModel.id;
    commitForm.value.channelPackage =
        Store.instance.getAppUpLoadModel.channelPackage;
  }

  /// 提交表单
  Future<void> commitFormFn() async {
    try {
      if (commitForm.value.payName.isEmpty) {
        CuToast.error(msg: "请输入姓名");
        return;
      }
      if (commitForm.value.payAccount.isEmpty) {
        CuToast.error(msg: "请输入账号");
        return;
      }
      EasyLoading.show();
      BackModel backModel = BackModel();

      if (commitForm.value.id != 0) {
        backModel = await Api.to.getUpdateBindPay(commitForm.value);
      } else {
        backModel = await Api.to.getBindAlipay(commitForm.value);
      }
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: backModel.data);
        UserPayListController userPayListController =
            Get.find<UserPayListController>();
        userPayListController.getPayList();
        Get.back();
      }
    } catch (e) {
      Utils.logError("修改或者新增支付方式失败$e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    payNameController.dispose();
    payAccountController.dispose();
    super.dispose();
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
              Text("姓名"),
              Expanded(
                child: CustomInputField(
                  defaultValue: commitForm.value.payName,
                  controller: payNameController,
                  bgColor: TextConfig.inputBgcolor,
                  textSize: TextConfig.textSize_12,
                  height: 40.h,
                  hintText: '输入支付宝真实姓名',
                  onChanged: (value) async {
                    commitForm.value.payName = value;
                  },
                  validator: (value) {
                    return null;
                  },
                ),
              ),
            ],
          ),
          Row(
            spacing: 5.w,
            children: [
              Text("支付宝账号"),
              Expanded(
                child: CustomInputField(
                  defaultValue: commitForm.value.payAccount.toString(),
                  controller: payAccountController,
                  bgColor: TextConfig.inputBgcolor,
                  textSize: TextConfig.textSize_12,
                  height: 40.h,
                  hintText: '输入支付宝账号',
                  onChanged: (value) async {
                    commitForm.value.payAccount = value;
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
              commitFormFn();
            },
            bgColor: TextConfig.primary,
            radius: 10.r,
          ),
        ],
      ),
    );
  }
}
