import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/custom_input_field.dart';
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
            SizedBox(height: 30.h,),
            // 修改资料
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  spacing: 5.w,
                  children: [
                    SizedBox(width: 60.w,child: Text("密码：")),
                    /// 账号登录
                    Expanded(
                      child: CustomInputField(
                        key: GlobalKey(),
                        height: 30.h,
                        textColor:TextConfig.black333,
                        textSize: TextConfig.textSize_12,
                        bgColor: Colors.white,
                        hintText: "请输入密码",
                        onChanged: (value) {
                          controller.loginForm.value.password =
                              value;
                        },
                        controller: controller.passwordController,
                      ),
                    ),
                    CuButton(text: "保存",width: 60.w,radius:10.r,bgColor: TextConfig.primary, onPressed:controller.getSetUser)
                  ],
                ),
              ),
              SizedBox(height: 10.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  spacing: 5.w,
                  children: [
                    SizedBox(width: 60.w,child: Text("上级邀请码：")),
                    /// 修改邀请码
                    Expanded(
                      child: CustomInputField(
                        defaultValue: controller.userInfo.userModel.inviteUserId!=null?controller.userInfo.userModel.inviteUserId.toString():"",
                        key: GlobalKey(),
                        height: 30.h,
                        textColor:TextConfig.black333,
                        textSize: TextConfig.textSize_12,
                        bgColor: Colors.white,
                        hintText: "请输入邀请码",
                        onChanged: (value) {
                          controller.loginForm.value.inviteCode =
                              value;
                        },
                        controller: controller.inviteCodeController,
                      ),
                    ),
                    if(controller.userInfo.userModel.inviteUserId==null||controller.userInfo.userModel.inviteUserId==0)
                      CuButton(text: "保存",width: 60.w,radius:10.r,bgColor: TextConfig.primary, onPressed:controller.getBindInviteUser)
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
