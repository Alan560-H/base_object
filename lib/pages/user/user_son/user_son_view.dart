import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_son_controller.dart';

class UserSonView extends GetView<UserSonController> {
  const UserSonView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Column(
          children: [
            CuAppBar(title: controller.appbarTitle.value,showBackArrow: false,),
          ],
        )
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
