import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/userModel/UserInviteModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import 'user_invite_controller.dart';

class UserInviteView extends GetView<UserInviteController> {
  const UserInviteView({super.key});

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
            color:TextConfig.primary,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: TextConfig.textSize_20,
            color: TextConfig.black333,
          ),
        ),
      ],
    );
  }
// 邀请任务列表
  Widget get userInviteModelListView {
    if (controller.userInviteModelList.isEmpty) return CuEmpty();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: controller.userInviteModelList.length,
      itemBuilder: (context, i) {
        UserInviteModel item = controller.userInviteModelList[i];
        return Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(

            title: Text(item.title,style: TextStyle(fontSize: TextConfig.textSize_16,color: TextConfig.primary,fontWeight: FontWeight.bold),),
            subtitle: Text(item.remark),

            // trailing: Text("${item.withdrawal}￥",style: TextStyle(color: TextConfig.primary, fontSize: TextConfig.textSize_16,fontWeight: FontWeight.bold),),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: Get.width,
          height: Get.height,
          decoration: BoxDecoration(
            color: TextConfig.fensePageColor,
            image: DecorationImage(
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              image: CachedNetworkImageProvider(ImageConfig.userInviteBg),
            ),
          ),
          child: Column(
            children: [
              CuAppBar(
                title: controller.appbarTitle.value,
                showBackArrow: true,
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
              ),
              // 顶部小容器
              Container(
                height: 115.h,
                width: Get.width,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "邀请好友赚现金",
                      style: TextStyle(
                        fontSize: TextConfig.textSize_30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "最高 99元",
                          style: TextStyle(
                            fontSize: TextConfig.textSize_24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Tada(
                          infinite: true,
                          duration: const Duration(milliseconds: 1000),
                          child: CuButton(
                            text: "",
                            bgImage: ImageConfig.inviteBtn,
                            width: 120.w,
                            height: 50.h,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 10.h,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      width: Get.width,
                      margin: EdgeInsets.only(
                        left: 10.w,
                        right: 10.h,
                        top: 30.h,
                      ),
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: TextConfig.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Marquee(
                        text: '本平台不存在任何收费项目，请勿轻信广告内容，谨防诈骗。',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    // 邀请情况概览
                    Container(
                      height: 200.h,
                      width: Get.width,
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 10.h,
                      ),
                      margin: EdgeInsets.only(
                        left: 10.w,
                        right: 10.h,
                        top: 0.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        spacing: 15.h,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "邀请信息",
                            style: TextStyle(
                              fontSize: TextConfig.textSize_24,
                              color: TextConfig.black333,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(child: getCom(value: "${controller.userInviteCountModel.value.inviteNum}人",title:"已邀人数")),
                              Expanded(child: getCom(value:"${controller.userInviteCountModel.value.inviteAmount}元",title:"已赚金币")),
                              Expanded(child: getCom(value:"${controller.userInviteCountModel.value.currentAmount}元",title:"可提现金额")),
                            ],
                          ),
                          CuButton(text: "立即提现",width:Get.width,height:40.h,radius:10.r,fontSize:TextConfig.textSize_20,bgColor:TextConfig.primary,textColor: Colors.white, onPressed: (){})
                        ],
                      ),
                    ),
                    Container(
                      height: 240.h,
                      width: Get.width,
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 10.h,
                      ),
                      margin: EdgeInsets.only(
                        left: 10.w,
                        right: 10.h,
                        top: 0.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        spacing: 15.h,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "邀请信息",
                            style: TextStyle(
                              fontSize: TextConfig.textSize_24,
                              color: TextConfig.black333,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                         Expanded(child: userInviteModelListView)
                          // CuButton(text: "立即提现",width:Get.width,height:40.h,radius:10.r,fontSize:TextConfig.textSize_20,bgColor:TextConfig.primary,textColor: Colors.white, onPressed: (){})
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
