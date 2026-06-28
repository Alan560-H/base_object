import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页横幅广告收益：今日实时汇总 + 累计总收益（展示口径，随 [adStatsProvider] 更新）。
class HomeBannerRevenueSection extends ConsumerWidget {
  const HomeBannerRevenueSection({super.key});

  static String _formatCny(double value) =>
      value.toStringAsFixed(AdInfo.displayRevenueFractionDigits);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);
    final String todayRevenue = _formatCny(stats.bannerRevenueTodayDisplayCny);
    final String totalRevenue = _formatCny(stats.bannerRevenueTotalDisplayCny);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _RevenueColumn(
                title: '横幅实时收益',
                subtitle: '今日 ${stats.bannerCountToday} 次',
                value: '$todayRevenue 元',
              ),
            ),
            Container(
              width: 1,
              height: 44.h,
              color: Colors.black12,
            ),
            Expanded(
              child: _RevenueColumn(
                title: '横幅总收益',
                subtitle: '累计 ${stats.bannerAdCount} 次',
                value: '$totalRevenue 元',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueColumn extends StatelessWidget {
  const _RevenueColumn({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.black45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
