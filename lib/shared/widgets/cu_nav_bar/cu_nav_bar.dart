import 'package:base_object/data/models/localModels/MenuModel.dart';
import 'package:base_object/shared/config/image_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 底部 Tab 栏（配合 go_router [StatefulNavigationShell] 使用）。
class CuNavBar extends StatelessWidget {
  const CuNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static MenuModel _createMenuModel(
    int id,
    String menuName,
    String defaultIcon,
    String activeIcon,
  ) {
    return MenuModel(
      id: id,
      menuName: menuName,
      isMock: false,
      defaultIcon: defaultIcon,
      activeIcon: activeIcon,
    );
  }

  static List<BottomNavigationBarItem> _navigationItems() {
    final menuModels = [
      _createMenuModel(
        0,
        '首页',
        ImageConfig.redBagDefatult,
        ImageConfig.redBagActive,
      ),
      _createMenuModel(
        1,
        '我的',
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
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        activeIcon: CachedNetworkImage(
          width: 24.w,
          imageUrl: menu.activeIcon!,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        label: menu.menuName,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: _navigationItems(),
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
