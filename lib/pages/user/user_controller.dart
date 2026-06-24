import 'package:base_object/models/localModels/MenuModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  RxString appbarTitle = "我的".obs;
  final UserInfo userInfo = Get.find<UserInfo>();
  List<MenuModel> menuList = [
    MenuModel(id: 8, menuName: "设备 OAID", icon: Icons.phone_android),
    MenuModel(id: 7, menuName: "清除缓存", icon: Icons.delete),
  ];
}
