import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/pages/user/leader_recruit/leader_recruit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaderRecruitView extends GetView<LeaderRecruitController> {
  const LeaderRecruitView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
          Column(
            children: [
              CuAppBar(title: controller.appbarTitle.value,showBackArrow: true,),
            ],
          )
      ),
    );
  }
}
