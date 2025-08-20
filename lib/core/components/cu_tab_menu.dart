import 'package:animate_do/animate_do.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/localModels/BoxCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CuTabMenu extends StatefulWidget {
  /// tab列表
  final List<BoxCategory> categoryList;
  final Color bgColor;
  /// 传入得当前所处那个索引
   final int currentIndex;

  /// tabChange事件
  final void Function(int) tabChange;

   const CuTabMenu({
    super.key,
    required this.categoryList,
    this.currentIndex = 0,
    this.bgColor = Colors.transparent,
    required this.tabChange,
  });

  @override
  State<CuTabMenu> createState() => _CuTabMenuState();
}

class _CuTabMenuState extends State<CuTabMenu>
    with SingleTickerProviderStateMixin {
  /// 当前索引
  late int _currentIndex;

  /// tab源列表
  late List<BoxCategory> _categoryList;

  /// tab控制器
  late TabController _tabController;

  @override
  void initState() {
    _currentIndex = widget.currentIndex;
    _categoryList = widget.categoryList;
    // 验证 currentIndex 是否在有效范围内
    _currentIndex = widget.currentIndex.clamp(
      0,
      _categoryList.isEmpty ? 0 : _categoryList.length - 1,
    );
    _tabController = TabController(length: _categoryList.length, vsync: this,initialIndex: _currentIndex);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
 @override
  void didUpdateWidget(covariant CuTabMenu oldWidget) {
    _tabController.animateTo(widget.currentIndex);
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:widget.bgColor,
        borderRadius: BorderRadius.circular(5.sp),
      ),
      padding:  EdgeInsets.zero,

      constraints: BoxConstraints(
        maxWidth: Get.width,
        maxHeight: 60.h,
      ),
      child: TabBar(

        isScrollable: false, // 启用滚动
        indicatorColor:TextConfig.primary,
        labelPadding: EdgeInsets.symmetric(horizontal: 5.0.w), // 增加内边距
        padding: EdgeInsets.zero,
        controller: _tabController,
        dividerColor:Colors.transparent,
        labelColor:TextConfig.primary,
        unselectedLabelColor: TextConfig.black333,
        tabs:
        _categoryList.map((tab) {
          return BounceInDown(child: Tab(text: tab.categoryName,));
        }).toList(),
        onTap:(i){
          widget.tabChange.call(i);
        },
      ),
    );
  }
}
