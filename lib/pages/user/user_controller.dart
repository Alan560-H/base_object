import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/models/localModels/MenuModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  RxString appbarTitle = "我的页面标题".obs;
  final UserInfo userInfo = Get.find<UserInfo>();
  List<MenuModel> menuList = [
    MenuModel(
      id: 0,
      menuName: "收支明细",
      path: AppRoutes.userTransaction,
      icon: Icons.format_list_numbered,
    ),
    MenuModel(
      id: 1,
      path: AppRoutes.home,
      menuName: "邀请好友",
      icon: Icons.share,
    ),
    MenuModel(
      id: 2,
      menuName: "团长招募",
      path: AppRoutes.userLeader,
      icon: Icons.supervisor_account,
    ),
    MenuModel(
      id: 3,
      path: AppRoutes.home,
      menuName: "联系客服",
      icon: Icons.support_agent,
    ),
    MenuModel(
      id: 4,
      menuName: "用户协议",
      icon: Icons.description,
    ),
    MenuModel(
      id: 5,
      menuName: "隐私政策",
      icon: Icons.description,
    ),
    MenuModel(
      id: 6,
      path: AppRoutes.userSystem,
      menuName: "我的设置",
      icon: Icons.settings_outlined,
    ),
    MenuModel(
      id: 7,
      path: AppRoutes.home,
      menuName: "清除缓存",
      icon: Icons.delete,
    ),


  ];

}