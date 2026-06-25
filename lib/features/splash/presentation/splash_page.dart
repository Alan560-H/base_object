import 'dart:async';
import 'dart:math';

import 'package:base_object/app/routes.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:base_object/services/ads/Init_tool.dart';
import 'package:base_object/services/ads/rewarder_tool.dart';
import 'package:base_object/services/device/DeviceChecker.dart';
import 'package:base_object/services/device/PermissionManager.dart';
import 'package:base_object/shared/config/text_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    unawaited(_allInit());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _allInit() async {
    EasyLoading.show(status: '检测设备中..');
    try {
      final bool isPermission = await PermissionManager.requestAllPermissions();
      Utils.logError(isPermission);
      await DeviceChecker.isAllCheckr();
      await _initAd();
      BannerTool.to.bannerListen();
      // initTopon 后注册；未注册则发奖回调无法记收益
      RewarderTool.to.rewardedAdListen();
    } finally {
      EasyLoading.dismiss();
    }
    if (!mounted) return;
    context.go(AppPaths.home);
  }

  Future<void> _initAd() async {
    try {
      await InitTool.to
          .setCustomDataDic({
            'user_id': 0,
            'extra': 'userid_0_type_1_amount_0_time_0',
          })
          .timeout(const Duration(seconds: 5));
    } catch (e, st) {
      Utils.logError(
        'setCustomDataMap 超时或失败（继续尝试 initTopon）: $e',
        error: e,
        stackTrace: st,
      );
    }

    try {
      final bool isInitAd = await InitTool.to.initTopon().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          Utils.logError('initTopon 超过 5s 未返回，先进入首页');
          return false;
        },
      );
      Utils.logError('广告初始化完成 $isInitAd');
    } catch (e, st) {
      Utils.logError('initTopon 异常: $e', error: e, stackTrace: st);
    }

    unawaited(_safeSetSdkDebugLog(true));
  }

  Future<void> _safeSetSdkDebugLog(bool enabled) async {
    try {
      await InitTool.to
          .setSdkDebugLog(enabled)
          .timeout(const Duration(seconds: 5));
    } catch (e, st) {
      Utils.logError('setSdkDebugLog 超时或失败（可忽略）: $e', error: e, stackTrace: st);
    }
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '加载中',
              style: TextStyle(
                color: Colors.black,
                fontSize: TextConfig.textSize_20,
              ),
            ),
            ...List.generate(3, (index) {
              final animationValue = sin(
                _animationController.value * 2 * pi + index * 2 * pi / 3,
              );
              final opacity = (animationValue + 1) / 2;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.0.w),
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    '.',
                    style: TextStyle(
                      fontSize: TextConfig.textSize_20,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SizedBox(
        width: screen.width,
        height: screen.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50.w,
                  width: 50.w,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 5.sp,
                  ),
                ),
                SizedBox(height: 16.sp),
                _buildLoadingText(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
