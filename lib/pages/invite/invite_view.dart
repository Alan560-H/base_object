import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'invite_controller.dart';

class InviteView extends GetView<InviteController> {
  const InviteView({super.key});
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
            color:Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: TextConfig.textSize_20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Utils.logError("邀请界面显示");
      controller.getMyInviteInfo();
    });
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
              CuAppBar(title: controller.appbarTitle.value,showBackArrow: false,backgroundColor: Colors.transparent,textColor:Colors.white,),
              /// 我的推广信息
              Container(
                height: 335.h,
                width: Get.width,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Stack(
                  children: [
                    Column(
                      spacing: 5.h,
                      children: [
                        // 头像，以及会员id以及邀请码
                        Row(
                          spacing: 20.w,
                          children: [
                            Avatar(headImage: controller.userInfo.userModel.headImage,size: 30.r,),
                            Column(
                              spacing: 5.h,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(controller.userInfo.userModel.username,style: TextStyle(fontSize: TextConfig.textSize_20,fontWeight: FontWeight.bold),),
                                Text("会员ID:${controller.userInfo.userModel.id} | 邀请码：${controller.userInfo.userModel.inviteCode}",),
                              ],
                            )
                          ],
                        ),
                        Expanded(child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: CachedNetworkImageProvider(ImageConfig.inviteBg),
                            ),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          padding: EdgeInsets.only(left: 10.w,right: 10.w,top: 25.h,bottom: 0.h),
                          child: Column(
                            spacing: 10.h,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Row(

                                  children: [
                                    getCom(value: controller.userInviteInfoModel.value.inviteNum.toString(),title: "总人数"),
                                    Spacer(),
                                    getCom(value: controller.userInviteInfoModel.value.todayAmount.toString(),title: "今日收益(元)"),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(child: getCom(value: controller.userInviteInfoModel.value.todayNum.toString(),title: "今日新增")),
                                  Expanded(child: getCom(value: controller.userInviteInfoModel.value.yesterdayNum.toString(),title: "昨日新增")),
                                  Expanded(child: getCom(value: controller.userInviteInfoModel.value.yesterdayNum.toString(),title: "我的粉丝")),
                                ],
                              ),
                              Tada(
                                infinite: true,
                                duration: const Duration(milliseconds: 1000),
                                child: CuButton(
                                  text: "",
                                  bgImage: ImageConfig.inviteBtn,
                                  width: 120.w,
                                  height: 50.h,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.inviteUser);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                    Positioned(
                      left: 10.w,
                      bottom: -17.w,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                alignment: Alignment.bottomCenter,
                                fit: BoxFit.fill,
                                image: CachedNetworkImageProvider(ImageConfig.inviteBanner))
                        ),
                        height: 60.h,
                        width: 320.w,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.h,left: 20.w,right: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: 5.h),
                                    child: Text("学习赚钱技巧，尽在用户交流群",style: TextStyle(fontSize: TextConfig.textSize_12,color: TextConfig.primary),)),
                                CuButton(
                                    radius: 10.r,
                                    text: "加入玩家群",width:100.w,height: 20.h,bgColor: TextConfig.primary, onPressed: (){
                                  Utils.openUrl(AppConfig.instance.qQUrl);
                                })
                              ],
                            ),
                          ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(child: ListView.builder(
                padding: EdgeInsets.only(left: 20.w,right: 20.h,top: 30.h,),
                itemCount: controller.menuList.length,
                itemBuilder: (context, i) {
                  final menu = controller.menuList[i];
                  return Container(
                    key: menu.menuKey ?? GlobalKey(),
                    margin: EdgeInsets.only(top:3.h),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10), // 设置圆角半径
                    ),
                    child: ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
                      leading: Icon(menu.icon, color:TextConfig.black333),
                      title: Text(
                        menu.menuName,
                        style: TextStyle(
                          color: TextConfig.black333,
                          fontSize: TextConfig.textSize_16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        color: TextConfig.black333,
                        Icons.arrow_forward_ios,
                        size: TextConfig.textSize_14,
                      ),
                      onTap: () async {
                        // 如果跳转二级页面，则优先跳转二级页面
                        if (menu.path != null) {
                          Get.toNamed(menu.path!);
                        }
                      },
                    ),
                  );
                },
              ))
            ],
          ),
        )
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
