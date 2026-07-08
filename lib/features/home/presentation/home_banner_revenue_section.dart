import 'package:base_object/app/providers.dart';
import 'package:base_object/shared/config/home_ui_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页今日横幅 / 信息流展示次数汇总。
class HomeBannerRevenueSection extends ConsumerWidget {
  const HomeBannerRevenueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          HomeUiStrings.homeAdCountSummary(
            bannerCount: stats.bannerCountToday,
            nativeCount: stats.nativeCountToday,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
