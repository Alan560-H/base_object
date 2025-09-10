import 'dart:developer';

import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:flutter/material.dart';
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
              child: ListView.builder(
                itemCount: controller.userPayLModelList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(controller.userPayLModelList[index].payName),
                  );
                },
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
