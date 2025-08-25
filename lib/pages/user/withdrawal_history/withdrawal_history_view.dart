import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/userModel/UserWithdrawalModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'withdrawal_history_controller.dart';

class WithdrawalHistoryView extends GetView<WithdrawalHistoryController> {
  const WithdrawalHistoryView({super.key});
  // 收入表
  Widget get userWithdrawalList {
    if (controller.userWithdrawalModelList.isEmpty) return CuEmpty();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: controller.userWithdrawalModelList.length,
      itemBuilder: (context, i) {
        UserWithdrawalModel item = controller.userWithdrawalModelList[i];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
          decoration: BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(
            title: Text("传家宝"),
            subtitle: Text(item.payTime),
            trailing: Text("${item.payMoney}￥",style: TextStyle(color: TextConfig.primary, fontSize: TextConfig.textSize_16,fontWeight: FontWeight.bold),),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Column(
          spacing: 10.h,
          children: [
            CuAppBar(title: controller.appbarTitle.value),
            // 累计提现
            Container(
              height:40.h,
              width: Get.width,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: TextConfig.commonYellowPageColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Text("累计成功提现:"),
                  Spacer(),
                  Text("¥ ${controller.userBagController.userBayModel.value.amount}",style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w500),),
                ],
              ),
            ),
            Expanded(child: userWithdrawalList)
          ],
        )
      ),
    );
  }
}
