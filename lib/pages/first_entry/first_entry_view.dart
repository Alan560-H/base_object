import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'first_entry_controller.dart';

class FirstEntryView extends GetView<FirstEntryController> {
  const FirstEntryView({super.key});
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
