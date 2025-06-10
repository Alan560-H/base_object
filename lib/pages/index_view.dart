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
      // 使用GetPageView来管理页面切换
      body:  Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: controller.pages,
      )),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _bottomNavigationBar() => Obx(
        () => BottomNavigationBar(
      onTap: (i) {
        controller.currentIndex.value = i;
        // 切换GetPageView的索引
        Utils.logError("切换到页面: $i");
      },
      currentIndex: controller.currentIndex.value,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
      ],
    ),
  );
}
