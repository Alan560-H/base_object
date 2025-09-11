import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'user_system_controller.dart';

class UserSystemView extends GetView<UserSystemController> {
  const UserSystemView({super.key});
  Widget rowContainer({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(children: [Text(title), Spacer(), Text(value)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Column(
          children: [
            CuAppBar(title: controller.appbarTitle.value, showBackArrow: true),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        rowContainer(
                          title: "昵称",
                          value: controller.userInfo.userModel.username,
                        ),
                        rowContainer(
                          title: "会员ID",
                          value: controller.userInfo.userModel.id.toString(),
                        ),
                        rowContainer(
                          title: "当前版本",
                          value:
                              controller.packageInfo.value.version.toString(),
                        ),
                        if (Store.instance.getAppUpLoadModel.needUpdate == true)
                          InkWell(
                            onTap: () {
                              Dialogs.showCommonDialog(
                                barrierDismissible: false,
                                dialogType: "AppUpLoadDialog",
                                data: Store.instance.getAppUpLoadModel,
                                dialogTitle: "升级提示",
                              );
                            },
                            child: rowContainer(
                              title: "最新版本（点击进行更新）",
                              value: Store.instance.getAppUpLoadModel.version,
                            ),
                          ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(AppRoutes.userPayList);
                          },
                          child: rowContainer(title: "绑定支付宝", value: "点击绑定支付宝"),
                        ),
                      ],
                    ),
                  ),
                  CuButton(
                    width: Get.width - 20.w,
                    height: 40.h,
                    bgColor: Colors.white,
                    textColor: TextConfig.black333,
                    fontSize: TextConfig.textSize_16,
                    text: "退出账号",
                    radius: 10.r,
                    onPressed: controller.userInfo.loginOut,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
