import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'withdrawal_history_controller.dart';

class WithdrawalHistoryView extends GetView<WithdrawalHistoryController> {
  const WithdrawalHistoryView({super.key});
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
