import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'user_error_controller.dart';

class UserErrorView extends GetView<UserErrorController> {
  const UserErrorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Container(
          color: TextConfig.commonYellowPageColor,
          child: Column(
            spacing: 10.h,
            children: [
              CuAppBar(title: controller.appbarTitle.value,showBackArrow: false,backgroundColor: Colors.transparent,),
              CachedNetworkImage(imageUrl: ImageConfig.userService,height: 300.h,),

              Text("服务时间：9:00~21:00",style: TextStyle(color: TextConfig.primary,fontSize: TextConfig.textSize_24),),
              Text("当前设备已被封禁，请联系客服解封",style: TextStyle(fontSize: TextConfig.textSize_16),),
              Text("手机号：18942693171",style: TextStyle(fontSize: TextConfig.textSize_16),),
              Text("微信号：18942693171",style: TextStyle(fontSize: TextConfig.textSize_16),),
            ],
          ),
        )
      ),
    );
  }
}
