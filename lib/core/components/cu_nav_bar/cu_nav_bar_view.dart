import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cu_nav_bar_controller.dart';

class CuNavBarView extends GetView<CuNavBarController> {
  const CuNavBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(()=>Container(
      height: controller.height.value,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          BottomNavigationBar(
            // key: Global.bottomNavigationBarState,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            items: controller.getNavigationItems(),
            currentIndex: controller.currentPageIndex.value,
            onTap: controller.onTabChange,
          ),
        ],
      ),
    ));
  }
}