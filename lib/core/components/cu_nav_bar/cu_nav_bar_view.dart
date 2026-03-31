import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cu_nav_bar_controller.dart';

class CuNavBarView extends GetView<CuNavBarController> {
  const CuNavBarView({super.key});

  @override
  Widget build(BuildContext context) {
    CuNavBarController controller =
        Get.isRegistered<CuNavBarController>()
            ? Get.find<CuNavBarController>()
            : Get.put(CuNavBarController());
    return Obx(
      () => Material(
        color: Colors.white,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: controller.getNavigationItems(),
          currentIndex: controller.currentPageIndex.value,
          onTap: controller.onTabChange,
        ),
      ),
    );
  }
}
