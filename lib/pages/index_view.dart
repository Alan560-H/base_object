import 'package:base_object/pages/index_controller.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IndexView extends GetView<IndexController> {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("主状态栏")),
      body: controller.pages[controller.currentIndex.value],
      bottomNavigationBar: _bottomNavIgationBar(),
    );
  }

  Widget _bottomNavIgationBar() => Obx(
    () => BottomNavigationBar(
      onTap: (i){
        controller.currentIndex.value = i;
        Utils.logError("i");
      },
      currentIndex: controller.currentIndex.value,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
      ],
    ),
  );
}
