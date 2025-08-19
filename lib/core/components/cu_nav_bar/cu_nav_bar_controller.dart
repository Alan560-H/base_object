import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/models/localModels/MenuModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CuNavBarController extends GetxController {
  var selectedIndex = 0.obs;
  // 创建一个菜单对象
  MenuModel _createMenuModel(
      int id,
      String menuName,
      bool isMock,
      String defaultIcon,
      String activeIcon,
      ) {
    return MenuModel(
      id: id,
      menuName: menuName,
      isMock: isMock,
      defaultIcon: defaultIcon,
      activeIcon: activeIcon,
    );
  }
  /// 一级页面索引
  RxInt currentPageIndex = 0.obs;
  RxDouble height = 60.h.obs;
  void onTabChange(int index) {
    currentPageIndex.value = index;
  }
  List<MenuModel> menuModels = [];
  // 定义一个方法来生成 BottomNavigationBarItem 列表
  List<BottomNavigationBarItem> getNavigationItems() {
    menuModels = [
      _createMenuModel(
        0,
        "红包群",
        false,
        ImageConfig.redBagDefatult,
        ImageConfig.redBagActive,

      ),
      _createMenuModel(
        1,
        "短视频",
        true,
        ImageConfig.videoDefault,
        ImageConfig.videoActive,

      ),
      _createMenuModel(
        2,
        "短剧",
        true,
        ImageConfig.shortVideoDefault,
        ImageConfig.shortVideoActive,

      ),
      _createMenuModel(
        3,
        "邀请",
        false,
        ImageConfig.inviteDefault,
        ImageConfig.inviteActive,

      ),
      _createMenuModel(
        4,
        "我的",
        false,
        ImageConfig.myDefatult,
        ImageConfig.myActive,
      ),
    ];
    return menuModels.map((menu) {
      return BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: CachedNetworkImage(
          width: 24.w,
          imageUrl: menu.defaultIcon!,
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        activeIcon: CachedNetworkImage(
          width: 24.w,
          imageUrl: menu.activeIcon!,
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        label: menu.menuName,
      );
    }).toList();
  }
}
