import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/pages/user/leader_recruit/leader_recruit_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LeaderRecruitView extends GetView<LeaderRecruitController> {
  const LeaderRecruitView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(ImageConfig.leaderRecruit),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              CuAppBar(
                title: controller.appbarTitle.value,
                showBackArrow: true,
                backgroundColor: Colors.transparent,
              ),
              Positioned(
                left: 45.w,
                top: 300.h,
                child: SizedBox(
                  height: 190.h,
                  width: 270.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl:
                              Store.instance.getQCode?.image ??
                              ImageConfig.inviteDefault,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CuButton(
                            radius: 10.r,
                            width: 100.w,
                            height: 40.h,
                            text: "团长招募",
                            bgColor: TextConfig.primary,
                            textColor: Colors.white,
                            onPressed: () {
                              Get.snackbar("提示", "招募团长未开放");
                            },
                          ),
                          CuButton(
                            radius: 10.r,
                            width: 100.w,
                            height: 40.h,
                            text: "成为团长",
                            bgColor: TextConfig.primary,
                            textColor: Colors.white,
                            onPressed: () {
                              Get.snackbar("提示", "成为团长请联系客服");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
