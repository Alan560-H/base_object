import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/components/cu_refresh_wrapper.dart';
import 'package:base_object/core/components/cu_tab_menu.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/userModel/UserAmountListModel.dart';
import 'package:base_object/models/backModel/userModel/UserWithdrawalModel.dart';
import 'package:base_object/pages/user/transaction_details/transaction_details_controller.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TransactionDetailsView extends GetView<TransactionDetailsController> {
  const TransactionDetailsView({super.key});
  // 收入表
  Widget get userAmountList {
    if (controller.userAmountListModelList.isEmpty) return CuEmpty();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: controller.userAmountListModelList.length,
      itemBuilder: (context, i) {
        UserAmountListModel item = controller.userAmountListModelList[i];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
          decoration: BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(
            title: Text("传家宝"),
            subtitle: Text(item.createTime),
            trailing: Text("${item.initAmount}金币",style: TextStyle(color: TextConfig.primary, fontSize: TextConfig.textSize_16,fontWeight: FontWeight.bold),),
          ),
        );
      },
    );
  }
// 提现表
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
      body: Obx(
        () => Column(
          children: [
            CuAppBar(
              title: controller.appbarTitle.value,
              showBackArrow: true,
              onBackPressed: controller.onBackPressed,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: CuTabMenu(
                bgColor: Colors.white,
                categoryList: controller.userBagNavs,
                tabChange: controller.tabChange,
                currentIndex: controller.currentIndex.value,
              ),
            ),
            Expanded(
              child:
                  controller.currentIndex.value == 0
                      ? userAmountList
                      : userWithdrawalList,
            ),
          ],
        ),
      ),
    );
  }
}
