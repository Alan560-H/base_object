import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/FormModel/withdrawal/WithdrawalForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'user_pay_list_controller.dart';

class UserPayListView extends GetView<UserPayListController> {
  const UserPayListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Column(
          children: [
            CuAppBar(title: controller.appbarTitle.value, showBackArrow: true),
            Expanded(
              child: Obx(
                () =>
                    controller.userPayLModelList.isNotEmpty
                        ? ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: controller.userPayLModelList.length,
                          itemBuilder: (context, index) {
                            final userPayLModel =
                                controller.userPayLModelList[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: ListTile(
                                title: Text(userPayLModel.payName),
                                subtitle: Text(
                                  userPayLModel.payAccount.toString(),
                                ),
                                trailing: SizedBox(
                                  width: 70.w,
                                  height: 40.h,
                                  child: Row(
                                    spacing: 10.w,
                                    children: [
                                      CuButton(
                                        text: "",
                                        width: 30.w,
                                        height: 30.h,
                                        textColor: TextConfig.black333,
                                        icons: Icons.edit,
                                        fontSize: TextConfig.textSize_24,
                                        onPressed: () {
                                          Dialogs.showCommonDialog(
                                            dialogTitle: "修改",
                                            dialogType: 'EditPayAccountDialog',
                                            data: userPayLModel,
                                          );
                                        },
                                      ),
                                      CuButton(
                                        text: "",
                                        width: 30.w,
                                        height: 30.h,
                                        textColor: TextConfig.black333,
                                        icons: Icons.delete,
                                        fontSize: TextConfig.textSize_24,
                                        onPressed:
                                            () => controller.getRemoveBindPay(
                                              userPayLModel,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                        : CuEmpty(),
              ),
            ),
            CuButton(
              radius: 10.r,
              text: "新增提现账号",
              width: Get.width * .8,
              height: 40.h,
              bgColor: TextConfig.primary,
              onPressed: () {
                UserPayLModel userPayLModel = UserPayLModel();
                Dialogs.showCommonDialog(
                  dialogTitle: "新增",
                  dialogType: 'EditPayAccountDialog',
                  data: userPayLModel,
                );
              },
            ),
            SizedBox(height: 110.h),
          ],
        ),
      ),
    );
  }
}
