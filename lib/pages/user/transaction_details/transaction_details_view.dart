import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/pages/user/transaction_details/transaction_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionDetailsView extends GetView<TransactionDetailsController> {
  const TransactionDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
          Column(
            children: [
              CuAppBar(title: controller.appbarTitle.value,showBackArrow: true,onBackPressed:controller.onBackPressed),
            ],
          )
      ),

    );
  }
}
