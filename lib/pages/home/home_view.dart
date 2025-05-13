import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/store/user_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController>{
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Text('计数器: ${controller.count}')),
        ElevatedButton(
          onPressed: controller.increment,
          child: Text('增加',style: TextStyle(color: Colors.black),),
        ),
        ElevatedButton(
          onPressed: controller.changeSteamName,
          child: Text('改变用户名字22',style: TextStyle(color: Colors.black),),
        ),
        ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.homeDetails, arguments: {'id': 123}),
          child: Text('查看详情',style: TextStyle(color: Colors.black),),
        ),
        Obx(()=>Text(
          '用户名: ${UserInfo.instance.userModel.steamName}', // 直接获取最新数据
          style: TextStyle(fontSize: 18),
        )),
      ],
    );
  }
  
}