import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/userModel/UserSonModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'user_son_controller.dart';

class UserSonView extends GetView<UserSonController> {
  const UserSonView({super.key});
  // 我的徒弟列表
  Widget get mySonList {
    if (controller.userSonModel.value.userList.isEmpty) return CuEmpty();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: controller.userSonModel.value.userList.length,
      itemBuilder: (context, i) {
        SonModel item = controller.userSonModel.value.userList[i];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
          margin: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
          decoration: BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5.w,
                children: [
                  Avatar(headImage: item.headImage,size: 25.r,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.username,),
                      Text("会员ID:${item.id}"),
                    ],
                  ),
                ],
              ),
              Text("+${item.amount} 金币" ,style: TextStyle(fontSize: TextConfig.textSize_16,color:TextConfig.primary),)
            ],
          ),
        );
      },
    );
  }
  /// 组件
  Widget getCom({String value="",String title=""}){
    return Column(
      spacing: 10.h,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,style: TextStyle(fontSize: TextConfig.textSize_20,color: Colors.white),),

        Text(value,style: TextStyle(color: Colors.white),),

      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Container(
          color: Utils.fromHex("#ff624b"),
          child: Column(
            spacing: 10.h,
            children: [
              CuAppBar(title: controller.appbarTitle.value,backgroundColor: Colors.transparent,textColor: Colors.white,),
              Container(
                height: 110.h,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                          image: CachedNetworkImageProvider(ImageConfig.userSon))
                  ),
                child:  Row(
                  children: [
                    Expanded(child: getCom(value: "${controller.userSonModel.value.inviteNum}人",title:"我的徒弟")),
                    Expanded(child: getCom(value:"${controller.userSonModel.value.inviteAmount}",title:"已赚金额")),
                  ],
                ),
              ),
              Text("有效徒弟（已提现用户）才会显示头像及金额",style: TextStyle(color: Colors.white,fontSize: TextConfig.textSize_12),),
              Expanded(child: mySonList)
            ],
          ),
        )
      ),
    );
  }
}
