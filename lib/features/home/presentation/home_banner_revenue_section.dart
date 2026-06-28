import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页横幅广告收益：今日实时汇总（展示口径，随 [adStatsProvider] 更新）。
class HomeBannerRevenueSection extends ConsumerWidget {
  const HomeBannerRevenueSection({super.key});

  static String _formatCny(double value) =>
      value.toStringAsFixed(AdInfo.displayRevenueFractionDigits);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);
    final String todayRevenue = _formatCny(stats.bannerRevenueTodayDisplayCny);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Text(
              '横幅实时收益',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '今日 ${stats.bannerCountToday} 次',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black45,
              ),
            ),
            const Spacer(),
            Text(
              '$todayRevenue 元',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
