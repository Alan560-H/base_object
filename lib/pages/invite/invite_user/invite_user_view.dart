import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'invite_user_controller.dart';

class InviteUserView extends GetView<InviteUserController> {
  const InviteUserView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            color: TextConfig.fensePageColor,
            image: DecorationImage(image: 
            CachedNetworkImageProvider(ImageConfig.commonBg)
            )
          ),
          child: Column(
            children: [
              CuAppBar(title: controller.appbarTitle.value,showBackArrow: false,),
            ],
          ),
        )
      ),
      // bottomNavigationBar: CuNavBarView(),
    );
  }
}
