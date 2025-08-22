import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_bag_controller.dart';

class UserBagView extends GetView<UserBagController> {
  const UserBagView({super.key});
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
