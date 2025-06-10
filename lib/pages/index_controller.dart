import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/global.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/pages/home/home_view.dart';
import 'package:base_object/pages/user/user_view.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtads/gtads.dart';

class IndexController extends GetxController {
  // 底部菜单索引
  RxInt currentIndex = 0.obs;
  // 模块页面
  // final List<Widget> pages = [
  //   // Navigator(
  //   //   onGenerateRoute: (settings)=>MaterialPageRoute(builder: (_)=>HomeView()),
  //   // ),
  //   // Navigator(
  //   //   onGenerateRoute: (settings)=>MaterialPageRoute(builder: (_)=>UserView()),
  //   // ),
  //   HomeView(),
  //   UserView(),
  // ];
  final List<Widget> pages = [
    // GetPage(name: AppRoutes.home, page: ()=>HomeView()),
    // GetPage(name: AppRoutes.user, page: ()=>UserView()),
      HomeView(),
      UserView(),
  ];
  void _init() async {
    //isDebug 是否开启debug日志
    GTAds.addProviders(AppAdConfig.providers);
    await GTAds.init(isDebug: true);
  }
  @override
  void onInit() {
    // TODO: implement onInit
    Utils.logError("initPage");
    _init();
    super.onInit();
  }

}