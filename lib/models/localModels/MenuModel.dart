import 'package:flutter/material.dart';

//
class MenuModel {
  int id; //id
  String? path; //路由地址
  IconData icon; //图标
  String menuName; //名称
  dynamic page; //包含页面
  String? activeIcon; //自定义主动激活按钮
  String? defaultIcon; //自定义默认按钮
  bool? isMock; //是否是试玩站专有
  GlobalKey? menuKey;//引导key
  MenuModel({
    required this.id,
    this.path,
    this.icon = Icons.menu,
    required this.menuName,
    this.page,
    this.activeIcon,
    this.defaultIcon,
    this.isMock,
    this.menuKey,
  });

}
