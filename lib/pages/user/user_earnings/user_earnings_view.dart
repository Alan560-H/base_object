import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/components/cu_tab_menu.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/userModel/UserAmountListModel.dart';
import 'package:base_object/store/store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'user_earnings_controller.dart';

class UserEarningsView extends GetView<UserEarningsController> {
  const UserEarningsView({super.key});

  /// 组件
  Widget getCom({String value = "", String title = ""}) {
    return Column(
      spacing: 5.h,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: TextConfig.textSize_16,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: TextConfig.textSize_14,
            color:Colors.white,
          ),
        ),

      ],
    );
  }
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
            title: Text(Store.instance.getAppUpLoadModel.appName),
            subtitle: Text(item.createTime),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${item.initAmount}金币",style: TextStyle(color: TextConfig.primary, fontSize: TextConfig.textSize_16,fontWeight: FontWeight.bold),),
                Text("${controller.sourceFn[item.type]}",style: TextStyle(color: TextConfig.grey, fontSize: TextConfig.textSize_12,),)
              ],
            ),
          ),
        );
      },
    );
  }
  // 收入表
  Widget get _inviteAmountNewList {
    if (controller.inviteAmountNewList.isEmpty) return CuEmpty();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: controller.inviteAmountNewList.length,
      itemBuilder: (context, i) {
        UserAmountListModel item = controller.inviteAmountNewList[i];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
          decoration: BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(
            title: Text(Store.instance.getAppUpLoadModel.appName),
            subtitle: Text(item.createTime),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${item.initAmount}金币",style: TextStyle(color: TextConfig.primary, fontSize: TextConfig.textSize_16,fontWeight: FontWeight.bold),),
                Text("${controller.sourceFn[item.type]}",style: TextStyle(color: TextConfig.grey, fontSize: TextConfig.textSize_12,),)
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Container(
          decoration: BoxDecoration(
              color: TextConfig.commonYellowPageColor,
              image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: CachedNetworkImageProvider(ImageConfig.loginBg2))
          ),
          child: Column(
            children: [
              CuAppBar(title: controller.appbarTitle.value,backgroundColor: Colors.transparent,textColor: Colors.white,),
              Container(
                height: 215.h,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                width: Get.width,
                padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 20.h),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                        image: CachedNetworkImageProvider(ImageConfig.userIncome))
                ),
                child: Column(
                  spacing: 10.h,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("我的总收益:",style: TextStyle(fontSize: TextConfig.textSize_24,color: Colors.white,fontWeight: FontWeight.bold),),
                    Text(controller.userBagController.userBayModel.value.amount.toString(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(child: getCom(value: controller.inviteController.userInviteInfoModel.value.todayAmount.toString(),title: "推广奖励")),
                        Expanded(child: getCom(value: controller.userBagController.userBayModel.value.currentAmount.toString(),title: "待提现")),
                        Expanded(child: getCom(value: "${controller.inviteController.userInviteInfoModel.value.inviteAmount??0}",title: "邀新收益")),
                      ],
                    ),
                    SizedBox(height: 5.h,)
                  ],
                ),
              ),
            //   tab栏
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                child: CuTabMenu(
                  bgColor: Colors.white,
                  categoryList: controller.userBagNavs,
                  tabChange: controller.tabChange,
                  currentIndex: controller.currentIndex.value,
                ),
              ),
              Expanded(child: controller.currentIndex.value==0?userAmountList:_inviteAmountNewList)
            ],
          ),
        )
      ),
    );
  }
}
