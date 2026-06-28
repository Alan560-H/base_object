import 'package:base_object/app/providers.dart';
import 'package:base_object/app/routes.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/models/localModels/MenuModel.dart';
import 'package:base_object/shared/config/text_config.dart';
import 'package:base_object/shared/widgets/ad_stats_summary.dart';
import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/services/device/oaid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 暂时隐藏「我的」页顶部汇总卡片（广告数 / 总收益），恢复时改为 true。
const _kShowUserRevenueSummaryCard = false;

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  static final List<MenuModel> _menuList = [
    MenuModel(id: 9, menuName: '收益列表', icon: Icons.receipt_long),
    MenuModel(id: 8, menuName: '设备 OAID', icon: Icons.phone_android),
    MenuModel(id: 7, menuName: '清除缓存', icon: Icons.delete),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          left: 10.w,
          right: 10.w,
          top: topPadding + 10.h,
        ),
        color: TextConfig.commonYellowPageColor,
        child: Column(
          spacing: 10.h,
          children: [
            if (_kShowUserRevenueSummaryCard) const _UserRevenueSummaryCard(),
            const AdStatsSummary(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _menuList.length,
                itemBuilder: (context, i) {
                  final menu = _menuList[i];
                  return Container(
                    key: menu.menuKey ?? GlobalKey(),
                    margin: EdgeInsets.only(top: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10.w,
                      ),
                      leading: Icon(menu.icon, color: TextConfig.black333),
                      title: Text(
                        menu.menuName,
                        style: TextStyle(
                          color: TextConfig.black333,
                          fontSize: TextConfig.textSize_16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        color: TextConfig.black333,
                        Icons.arrow_forward_ios,
                        size: TextConfig.textSize_14,
                      ),
                      onTap: () async {
                        if (menu.id == 9) {
                          context.push(AppPaths.userAdRecords);
                          return;
                        }
                        if (menu.id == 8) {
                          await showOaidDialog(context);
                          return;
                        }
                        if (menu.id == 7) {
                          EasyLoading.show(status: '正在努力清除中...');
                          await Future.delayed(const Duration(seconds: 3));
                          CuToast.success(msg: '清除成功');
                          EasyLoading.dismiss();
                          if (context.mounted) {
                            context.go(AppPaths.home);
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRevenueSummaryCard extends ConsumerWidget {
  const _UserRevenueSummaryCard();

  Widget _statColumn({required String value, required String title}) {
    return Column(
      spacing: 10.h,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: TextConfig.textSize_20,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: TextConfig.textSize_14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final String totalDisplay = stats.adInfosTotalDisplayCny.toStringAsFixed(
      AdInfo.displayRevenueFractionDigits,
    );

    return Container(
      width: screenWidth,
      constraints: BoxConstraints(
        minHeight: 100.h,
        maxHeight: 130.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: TextConfig.primary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statColumn(
              value: '广告数：${stats.adInfos.length}',
              title: '累计观看',
            ),
          ),
          Expanded(
            child: _statColumn(
              value: totalDisplay,
              title: '总收益(展示)',
            ),
          ),
        ],
      ),
    );
  }
}
