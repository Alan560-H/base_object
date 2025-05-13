import 'package:base_object/core/config/global.dart';
import 'package:base_object/pages/home/home_view.dart';
import 'package:base_object/pages/user/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IndexController extends GetxController {
  // 底部菜单索引
  final currentIndex = 0.obs;
  // 模块页面
  final List<Navigator> pages = [
    Navigator(
      onGenerateRoute: (settings)=>MaterialPageRoute(builder: (_)=>HomeView()),
    ),
    Navigator(
      onGenerateRoute: (settings)=>MaterialPageRoute(builder: (_)=>UserView()),
    ),
  ];

}