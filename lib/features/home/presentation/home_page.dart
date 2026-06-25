import 'package:base_object/app/providers.dart';
import 'package:base_object/features/home/presentation/home_ad_controls.dart';
import 'package:base_object/features/home/presentation/home_native_feed_slot.dart';
import 'package:base_object/services/device/oaid_dialog.dart';
import 'package:base_object/shared/config/text_config.dart';
import 'package:base_object/shared/widgets/cu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: TextConfig.comPageGrey,
        child: Column(
          spacing: 5.h,
          children: [
            const _HomeTopSection(),
            const HomeNativeFeedSlot(),
            const Expanded(child: _HomeActionSection()),
          ],
        ),
      ),
    );
  }
}

class _HomeTopSection extends ConsumerWidget {
  const _HomeTopSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final double topPad = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: topPad + 8.h,
        bottom: 4.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  home.currentIp,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed:
                    home.ipRefreshing
                        ? null
                        : () => homeNotifier.fetchCurrentIp(showLoading: true),
                icon:
                    home.ipRefreshing
                        ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black87,
                          ),
                        )
                        : Icon(
                          Icons.refresh,
                          size: 24.sp,
                          color: Colors.black87,
                        ),
                tooltip: '刷新 IP',
              ),
              if (home.appDisplayName.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 140.w),
                    child: Text(
                      home.appDisplayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(width: 8.w),
            ],
          ),
          Text(
            home.ipRefreshedAt.isEmpty
                ? '尚未刷新'
                : '刷新时间：${home.ipRefreshedAt}',
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CuButton(
                text: 'OAID',
                width: 70.w,
                height: 32.h,
                textColor: Colors.black87,
                bgColor: const Color(0xFFE8E8E8),
                radius: 6.r,
                onPressed: () => showOaidDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeActionSection extends ConsumerWidget {
  const _HomeActionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      children: [
        Spacer(),
        HomeAdControls(),
      ],
    );
  }
}
