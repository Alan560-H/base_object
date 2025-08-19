import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'details_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final params = Get.parameters;
    final args = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("详情"),
        backgroundColor: TextConfig.black333,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.root),
            child: Text('增加', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
