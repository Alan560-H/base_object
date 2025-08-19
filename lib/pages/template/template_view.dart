import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'template_controller.dart';

class TemplateView extends GetView<TemplateController> {
  const TemplateView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>
        Column(
          children: [
            Text(controller.appbarTitle.value),
          ],
        )
      ),
      // bottomNavigationBar: ,
    );
  }
}
