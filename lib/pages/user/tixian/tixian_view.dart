import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:base_object/models/backModel/userModel/WithdrawalModel.dart';
import 'package:base_object/pages/user/tixian/tixian_controller.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TixianView extends GetView<TixianController> {
  const TixianView({super.key});

  /// 组件
  Widget getCom({String value = "", String title = ""}) {
    return Column(
      spacing: 10.h,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: TextConfig.textSize_20,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: TextConfig.textSize_14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget get userCurrentAmount {
    return Container(
      color: Colors.white,
      // height: Get.height,
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: CachedNetworkImageProvider(ImageConfig.currentAmount),
              ),
            ),
            padding: EdgeInsets.all(20.w),
            width: Get.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "当前余额",
                  style: TextStyle(
                    fontSize: TextConfig.textSize_20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "${Utils.floorToTwoDecimal(controller.userInfo.userModel.currentAmount / 10000)} 元",
                  style: TextStyle(
                    fontSize: TextConfig.textSize_20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get enterForm {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: TextConfig.commonYellowPageColor,
      ),
      // height: Get.height,
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.h,
        children: [
          Text(
            "提现到指定账户",
            style: TextStyle(
              fontSize: TextConfig.textSize_16,
              color: TextConfig.primary,
            ),
          ),
          controller.userPayLModelList.isNotEmpty
              ? DropdownButton<UserPayLModel>(
                style: TextStyle(color: TextConfig.primary),
                borderRadius: BorderRadius.circular(10.r),
                isExpanded: true,
                alignment: AlignmentDirectional.centerEnd,
                value: controller.selectPay.value,
                hint: const Text('请选择一个选项'),
                onChanged: (UserPayLModel? newValue) {
                  controller.selectPay.value = newValue!;
                  controller.withdrawalForm.value.userPayAccountId =
                      newValue.id;
                },
                // 正确返回 DropdownMenuItem 列表
                items:
                    controller.userPayLModelList
                        .map<DropdownMenuItem<UserPayLModel>>((
                          UserPayLModel value,
                        ) {
                          return DropdownMenuItem<UserPayLModel>(
                            value: value,
                            child: Text(
                              "${value.payName}(${value.payAccount})",
                              style: TextStyle(
                                color:
                                    controller.selectPay.value == value
                                        ? TextConfig
                                            .primary // 选中项在下拉列表中的颜色
                                        : TextConfig.black333, // 未选中项的颜色
                              ),
                            ), // 直接显示选项文本
                          );
                        })
                        .toList(),
              )
              : CuButton(
                radius: 10.r,
                text: "去绑定支付宝账号",
                width: Get.width,
                bgColor: TextConfig.primary,
                onPressed: () {
                  Get.toNamed(AppRoutes.userPayList);
                },
              ),
        ],
      ),
    );
    // return Container(
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(10.r),
    //     color: TextConfig.commonYellowPageColor,
    //   ),
    //   // height: Get.height,
    //   width: Get.width,
    //   padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    //   child: Column(
    //     spacing: 10.h,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Row(
    //         children: [
    //           Text("支付宝账号："),
    //
    //           /// 账号登录
    //           Expanded(
    //             child: CustomInputField(
    //               key: GlobalKey(),
    //               height: 30.h,
    //               textColor: TextConfig.black333,
    //               textSize: TextConfig.textSize_12,
    //               bgColor: Colors.white,
    //               hintText: "请输入账号",
    //               onChanged: (value) {
    //                 controller.withdrawalForm.value.payAccount = value;
    //               },
    //               controller: controller.accountController,
    //             ),
    //           ),
    //         ],
    //       ),
    //       Row(
    //         children: [
    //           Text("姓名："),
    //
    //           /// 实名
    //           Expanded(
    //             child: CustomInputField(
    //               textColor: TextConfig.black333,
    //               textSize: TextConfig.textSize_12,
    //               key: GlobalKey(),
    //               height: 30.h,
    //               bgColor: Colors.white,
    //               hintText: "请输入姓名",
    //               onChanged: (value) {
    //                 controller.withdrawalForm.value.payName = value;
    //               },
    //               controller: controller.nameController,
    //             ),
    //           ),
    //         ],
    //       ),
    //       Text(
    //         "输入的账号和姓名仅用作于提现，不做保存",
    //         style: TextStyle(
    //           color: TextConfig.primary,
    //           fontSize: TextConfig.textSize_12,
    //         ),
    //       ),
    //       Text(
    //         "名下多个支付账号，请填支付宝账号，不要填手机号，否则无法到账。",
    //         style: TextStyle(
    //           color: TextConfig.primary,
    //           fontSize: TextConfig.textSize_12,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget get tixianLiebiao {
    /// 提现列表
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width),
      child: Column(
        spacing: 10.h,
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5.w,
              crossAxisSpacing: 5.h,
              childAspectRatio: 1,
            ),
            itemCount: controller.withdrawalList.length,
            itemBuilder: (_, index) {
              WithdrawalModel item = controller.withdrawalList[index];
              return Obx(
                () => InkWell(
                  onTap: () {
                    controller.selectedWithdrawalModel.value = item;
                    controller.withdrawalForm.value.amountId = item.id;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          controller.selectedWithdrawalModel.value.id == item.id
                              ? TextConfig.primary
                              : TextConfig.commonYellowPageColor,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.money.toString(),
                                style: TextStyle(
                                  fontSize: TextConfig.textSize_20,
                                  color:
                                      controller
                                                  .selectedWithdrawalModel
                                                  .value
                                                  .id ==
                                              item.id
                                          ? Utils.fromHex("#FCEEE5")
                                          : TextConfig.primary,
                                ),
                              ),
                              Text(
                                "立刻提现",
                                style: TextStyle(
                                  fontSize: TextConfig.textSize_14,
                                  color:
                                      controller
                                                  .selectedWithdrawalModel
                                                  .value
                                                  .id ==
                                              item.id
                                          ? Utils.fromHex("#FCEEE5")
                                          : TextConfig.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.only(left: 20.w, right: 10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: CachedNetworkImageProvider(
                                  ImageConfig.tiJiaobiao,
                                ),
                              ),
                            ),
                            child: Text(
                              item.remark,
                              style: TextStyle(
                                fontSize: TextConfig.textSize_12,
                                color: TextConfig.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          CuButton(
            height: 40.h,
            radius: 10.r,
            fontSize: TextConfig.textSize_20,
            text: "立即提现",
            width: Get.width,
            bgColor: TextConfig.primary,
            textColor: Colors.white,
            onPressed: controller.submitForm,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: Get.width,
          height: Get.height,
          constraints: BoxConstraints(maxHeight: Get.height),
          decoration: BoxDecoration(color: TextConfig.commonYellowPageColor),
          child: Column(
            spacing: 10.h,
            children: [
              CuAppBar(
                title: controller.appbarTitle.value,
                showBackArrow: true,
                backgroundColor: Colors.transparent,
                actions: [
                  CuButton(
                    width: 40.w,
                    fontSize: TextConfig.textSize_24,
                    onPressed: () {
                      Get.toNamed(AppRoutes.userTransaction);
                    },
                    text: '刷新',
                    icons: Icons.list_outlined,
                  ),
                ],
                // textColor: Colors.white,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      spacing: 10.h,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 20.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: Colors.white,
                          ),
                          child: Column(
                            spacing: 10.h,
                            children: [
                              userCurrentAmount,
                              enterForm,
                              tixianLiebiao,
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 20.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: Colors.white,
                          ),
                          child: Column(
                            spacing: 10.h,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "温馨提示",
                                style: TextStyle(
                                  fontSize: TextConfig.textSize_20,
                                  color: TextConfig.primary,
                                ),
                              ),
                              Text(
                                "1、提现金额一般24小时内到账，如遇节假日和特殊情况会适当延迟到账。",
                                style: TextStyle(color: TextConfig.black333),
                              ),
                              Text(
                                "2、支付宝未实名认证会导致提现无法到账，请确认支付宝已完成实名认证。",
                                style: TextStyle(color: TextConfig.black333),
                              ),
                              Text(
                                "3、由于支付宝提现机制原因，每日提现有次数限制，如有余额，可次日申请。",
                                style: TextStyle(color: TextConfig.black333),
                              ),
                              Text(
                                "4、如果提现遇到问题，请即使联系客服解决。",
                                style: TextStyle(color: TextConfig.black333),
                              ),
                              Text(
                                "5、绑定的支付宝账号仅用作于提现使用，本App不做留存。",
                                style: TextStyle(color: TextConfig.black333),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 60.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
