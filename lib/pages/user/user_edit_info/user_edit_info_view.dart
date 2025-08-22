import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'user_edit_info_controller.dart';

class UserEditInfoView extends GetView<UserEditInfoController> {
  const UserEditInfoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.topCenter,
                  fit: BoxFit.fill,
                  image: CachedNetworkImageProvider(ImageConfig.userEditInfo))
          ),
          child: Column(
            children: [
              CuAppBar(title: controller.appbarTitle.value,backgroundColor: Colors.transparent,textColor: Colors.white,),
              // 头像，以及会员id以及邀请码
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  spacing: 20.w,
                  children: [
                    Avatar(headImage: controller.userInfo.userModel.headImage,size: 30.r,),
                    Column(
                      spacing: 10.h,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.userInfo.userModel.username,style: TextStyle(fontSize: TextConfig.textSize_20,fontWeight: FontWeight.bold),),
                        Text("会员ID:${controller.userInfo.userModel.id} | 邀请码：${controller.userInfo.userModel.inviteCode}",),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
