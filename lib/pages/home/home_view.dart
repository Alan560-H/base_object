import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/store/user_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController>{
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
          Column(
            children: [
              CuAppBar(
                showBackArrow: false,
                title: controller.appbarTitle.value,
                  backgroundColor: Colors.transparent,
              ),
            ],
          )
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
  
}