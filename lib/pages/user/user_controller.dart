import 'package:base_object/data/models/localModels/MenuModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  RxString appbarTitle = '我的'.obs;
  List<MenuModel> menuList = [
    MenuModel(id: 8, menuName: '设备 OAID', icon: Icons.phone_android),
    MenuModel(id: 7, menuName: '清除缓存', icon: Icons.delete),
  ];
}
