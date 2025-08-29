import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'user_bag_controller.dart';

class UserBagView extends GetView<UserBagController> {
  const UserBagView({super.key});
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
              CuAppBar(textColor: Colors.white, title: controller.appbarTitle.value,backgroundColor: Colors.transparent,actions: [CuButton(text: "提现记录",padding:EdgeInsets.zero,width:80.w,height: 30.h,onPressed:()=>Get.toNamed(AppRoutes.userWithdrawalHistory))],),
              Container(
                width: Get.width,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                height: 220.h,
                child: Column(
                  spacing: 15.h,
                  children: [
                    CachedNetworkImage(imageUrl: ImageConfig.icon,height: 60.h,),
                    Text("可提现金额(元)",style: TextStyle(fontSize: TextConfig.textSize_20,color: Colors.white,fontWeight: FontWeight.bold),),
                    Text("${Utils.floorToTwoDecimal(controller.userInfo.userModel.currentAmount/10000)} 元",style: TextStyle(fontSize: TextConfig.textSize_20,color: Colors.white,fontWeight: FontWeight.bold),),
                    Row(
                      children: [
                        Expanded(child: getCom(value: controller.userBayModel.value.yesterdayAmount.toString(),title: "昨日收益")),
                        Expanded(child: getCom(value: controller.userBayModel.value.todayAmount.toString(),title: "今日收益")),
                        Expanded(child: getCom(value: controller.userBayModel.value.amount.toString(),title: "累计收益")),
                      ],
                    ),

                  ],
                ),
              ),
              Expanded(child: Center(
                child: Tada(
                    infinite: true,
                    duration: const Duration(milliseconds: 1000),
                    child: CuButton(text: "立即提现",bgColor: TextConfig.primary,radius: 20.r,width: 180.w,height: 40.h,fontSize: TextConfig.textSize_24, onPressed: ()=>Get.toNamed(AppRoutes.userTixian))),
              ))
            ],
          ),
        )
      ),
    );
  }
}
