import 'dart:async';
import 'dart:io' show Platform;

import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeController extends GetxController {
  /// 收益记录弹窗最多展示条数（Store 仍保留全部）
  static const int kHomeRevenueDialogMax = 50;

  final ScrollController scrollController = ScrollController();

  /// 进入首页后延迟自动「开始信息流」；离开页时取消。
  Timer? _nativeFeedAutoStartTimer;
  // 2. 封装“滚动到最底部”的方法（关键：等列表构建完成后再滚动）
  void scrollToBottom() {
    // 延迟到当前帧构建完成后执行，避免获取不到最新滚动位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 确保控制器已绑定到 ListView，且有可滚动空间
      if (scrollController.hasClients) {
        // 平滑滚动到最底部（也可用 controller.jumpTo 实现瞬时滚动）
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), // 滚动动画时长
          curve: Curves.easeInOut, // 滚动曲线
        );
      }
    });
  }

  Future<void> _onPauseBannerTap() async {
    try {
      await BannerTool.to.pauseBannerPlayback();
      CuToast.success(
        msg: '已停止横幅',
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e, st) {
      Utils.logError('停止横幅: $e $st');
      CuToast.error(msg: '停止横幅失败');
    }
  }

  Future<void> _onStartBannerTap() async {
    try {
      await BannerTool.to.startBannerPlayback();
      CuToast.success(
        msg: '已开始加载横幅',
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e, st) {
      Utils.logError('开始横幅: $e $st');
      CuToast.error(msg: '开始横幅失败');
    }
  }

  Future<void> _onPauseNativeTap() async {
    try {
      await NativeTool.to.pauseNativeFeedPlayback();
      CuToast.success(
        msg: '已停止信息流',
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e, st) {
      Utils.logError('停止信息流: $e $st');
      CuToast.error(msg: '停止信息流失败');
    }
  }

  Future<void> _onStartNativeTap() async {
    try {
      await NativeTool.to.startNativeFeedPlayback();
      CuToast.success(
        msg: '已开始加载信息流',
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e, st) {
      Utils.logError('开始信息流: $e $st');
      CuToast.error(msg: '开始信息流失败');
    }
  }

  String _adTypeLabel(String adType) {
    if (adType == AdInfo.typeBanner) return '横幅';
    if (adType == AdInfo.typeNativeFeed) return '信息流';
    return '激励视频';
  }

  void showRevenueRecordsDialog() {
    Get.dialog(
      barrierDismissible: true,
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.62,
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('收益记录', style: TextStyle(fontSize: 18.sp)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back<void>(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Obx(() {
                  final List<AdInfo> raw = Store.instance.getAdInfos;
                  final List<AdInfo> tail =
                      raw.length <= kHomeRevenueDialogMax
                          ? raw
                          : raw.sublist(raw.length - kHomeRevenueDialogMax);
                  final List<AdInfo> displayed = tail.reversed.toList();
                  if (displayed.isEmpty) {
                    return const Center(child: Text('暂无记录'));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: displayed.length,
                    itemBuilder: (BuildContext context, int i) {
                      final AdInfo currentItem = displayed[i];
                      final String typeLabel = _adTypeLabel(currentItem.adType);
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.h,
                          vertical: 5.w,
                        ),
                        margin: EdgeInsets.only(bottom: 10.h),
                        width: double.infinity,
                        color: Colors.white70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '类型：$typeLabel',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '预估收益（元）：${AdInfo.formatDisplayRevenue(currentItem.publisherRevenue)}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            Text('生成时间：${currentItem.createdTime}'),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 横幅 / 收益记录 / 信息流 操作按钮（信息流槽与收益统计由 [HomeView] 组合在其上方）
  Widget buildChatList() {
    Utils.logError('构建首页广告操作按钮');
    return Obx(() {
      final bool bannerPaused = BannerTool.to.bannerPlaybackPaused.value;
      final HomeBannerSlotState bannerState = BannerTool.to.bannerSlotState.value;
      final bool bannerLoading =
          !bannerPaused && bannerState == HomeBannerSlotState.loading;
      final String bannerBtnText =
          bannerPaused
              ? '开始横幅广告'
              : bannerLoading
              ? '加载中…'
              : '停止广告';
      final bool bannerBtnDisabled = bannerLoading;

      final bool nativePaused = NativeTool.to.nativeFeedPlaybackPaused.value;
      final HomeNativeSlotState nativeState =
          NativeTool.to.nativeSlotState.value;
      final bool nativeLoading =
          !nativePaused && nativeState == HomeNativeSlotState.loading;
      final int? reloadCd = NativeTool.to.nativeFeedAutoReloadCountdown.value;
      final String nativeBtnText =
          nativePaused
              ? '开始信息流'
              : nativeLoading
              ? '加载中…'
              : (reloadCd != null && reloadCd > 0)
              ? '停止信息流（$reloadCd）'
              : '停止信息流';
      final bool nativeBtnDisabled = nativeLoading;

      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          CuButton(
            bgColor: TextConfig.primary,
            text: bannerBtnText,
            width: 120.w,
            height: 40.h,
            disable: bannerBtnDisabled,
            onPressed: () {
              if (bannerPaused) {
                _onStartBannerTap();
              } else {
                _onPauseBannerTap();
              }
            },
          ),
          CuButton(
            bgColor: TextConfig.primary,
            text: '收益记录',
            width: 100.w,
            height: 40.h,
            onPressed: showRevenueRecordsDialog,
          ),
          CuButton(
            bgColor: TextConfig.primary,
            text: nativeBtnText,
            width: 148.w,
            height: 40.h,
            disable: nativeBtnDisabled,
            onPressed: () {
              if (nativePaused) {
                _onStartNativeTap();
              } else {
                _onPauseNativeTap();
              }
            },
          ),
        ],
      );
    });
    // return Center(
    //   child: CuButton(
    //     bgColor: TextConfig.primary,
    //     text: "观看激励视频",
    //     width: 150.w,
    //     height: 40.h,
    //     onPressed: () {
    //       RewarderTool.to.showRewardedVideoFlutter();
    //     },
    //   ),
    // );
    // return Obx(
    //   () => ListView.builder(
    //     controller: scrollController, // 绑定新控制器
    //     padding: EdgeInsets.all(10.sp),
    //     itemCount: HomeGroupChat.to.messages.length,
    //     reverse: false, // 最新消息在底部（需向下滚动查看）
    //     itemBuilder: (context, index) {
    //       final message = HomeGroupChat.to.messages[index];
    //       return _buildMessageItem(message);
    //     },
    //   ),
    // );
  }

  /// 是否显示新人福利（无后端，占位方法）
  Future<void> isShowNewUser() async {}

  void allInit() async {
    Store.instance.initAdInfos();
    await Store.instance.getFkConfigFn();
    fetchCurrentIp();

    /// 上传地址
    // if (UserInfo.instance.isLoginIn) {
    //   await LocationUtil().getCurrentLocation((Map result) async {
    //     Utils.logError("定位结果：$result");
    //     if (result["errorCode"] != null || result["address"] == null) {
    //       CuToast.error(msg: "定位失败，请打开定位");
    //       await Future.delayed(const Duration(seconds: 2));
    //       SystemNavigator.pop();
    //       return;
    //     }
    //     LocationData locationData = LocationData(
    //       address: result["address"],
    //       latitude: result["latitude"],
    //       longitude: result["longitude"],
    //     );
    //     Store.instance.setLocationData(locationData);
    //   });
    //
    //   await Store.instance.getVer(
    //     type: 3,
    //     msg:
    //         "地理位置${Store.instance.locationData?.address}，经度${Store.instance.locationData?.longitude}，纬度${Store.instance.locationData?.latitude}",
    //   );
    // }

    /// 获取风控配置
    // await Store.instance.getFkConfigFn();

    /// 获取今日领取了多少个红包
    // await Store.instance.initCurrentCount();
    // await getAppUpdata();
    // 初始化用户信息
    // UserInfo.instance.initialize();
    // 首页暂不加载激励视频（load / listen 已关闭；其它页如登录仍可加载）
    // RewarderTool.to.loadRewardedVideoFlutter(...);
    // RewarderTool.to.rewardedAdListen();

    BannerTool.to.bannerListen();

    unawaited(NativeTool.to.nativeLisListen());

    /// 是否显示新人邀请
    // isShowNewUser();

    /// 是否显示公告框
    // isShow();

    /// 检查低保任务
    // await Store.instance.postMinAdPrizeList();

    /// 如果任务状态是接取的，那么就跳转到任务大厅
    // if (Store.instance.isTaskStatus == 1) {
    //   CuNavBarController.to.onTabChange(1);
    // }
    // 初始化app升级信息
  }

  @override
  void onInit() {
    Utils.logError("首页页面onInit");

    // 开启广告监听器
    // InterstitialTool.to.interstitialListen();
    // NativeTool.to.nativeLisListen();

    // InterstitialTool.to.loadInterstitialAd();

    // NativeTool.to.loadNativeWith();
    // HomeGroupChat.to.homeGroupChatInit();
    allInit();
    _loadAppDisplayName();

    super.onInit();
  }

  Future<void> _loadAppDisplayName() async {
    try {
      final PackageInfo p = await PackageInfo.fromPlatform();
      appDisplayName.value = p.appName;
    } catch (e, st) {
      Utils.logError('读取应用名称失败: $e $st');
    }
  }

  @override
  void onClose() {
    _nativeFeedAutoStartTimer?.cancel();
    _nativeFeedAutoStartTimer = null;
    Utils.logError("首页页面关闭");
    super.onClose();
  }

  @override
  void onReady() {
    Utils.logError("首页页面onReady");
    _scheduleNativeFeedAutoStartAfterEnter();
    super.onReady();
  }

  /// 进入首页约 3 秒后自动触发与「开始信息流」相同的 [NativeTool.startNativeFeedPlayback]（仅 Android，与槽位一致）。
  void _scheduleNativeFeedAutoStartAfterEnter() {
    if (!Platform.isAndroid) return;
    _nativeFeedAutoStartTimer?.cancel();
    _nativeFeedAutoStartTimer = Timer(const Duration(seconds: 3), () {
      _nativeFeedAutoStartTimer = null;
      if (isClosed) return;
      unawaited(_autoStartNativeFeedAfterEnterHome());
    });
  }

  Future<void> _autoStartNativeFeedAfterEnterHome() async {
    try {
      if (!NativeTool.to.nativeFeedPlaybackPaused.value) return;
      await NativeTool.to.startNativeFeedPlayback();
    } catch (e, st) {
      Utils.logError('首页进入后自动开始信息流: $e $st');
    }
  }

  // ------------------- 响应式状态 -------------------
  final RxString appbarTitle = "首页".obs;

  /// 系统展示的应用名（Android label / iOS CFBundleDisplayName）
  final RxString appDisplayName = ''.obs;

  final RxString currentIp = "获取中...".obs;

  /// IP 请求结束后的本地时间（成功或失败均更新）
  final RxString ipRefreshedAt = ''.obs;

  /// 正在手动刷新 IP（用于按钮 loading）
  final RxBool ipRefreshing = false.obs;

  /// [showLoading] 为 true 时展示 EasyLoading（手动点刷新）
  Future<void> fetchCurrentIp({bool showLoading = false}) async {
    if (showLoading) {
      if (ipRefreshing.value) return;
      ipRefreshing.value = true;
      EasyLoading.show(status: '正在获取 IP…', maskType: EasyLoadingMaskType.clear);
    }
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
      ),
    );
    final urls = ["https://httpbin.org/ip", "https://api.ipify.org"];
    try {
      for (final url in urls) {
        try {
          if (url.contains("httpbin")) {
            final res = await dio.get<Map<String, dynamic>>(url);
            final origin = res.data?["origin"];
            if (origin != null) {
              currentIp.value = origin.toString().trim();
              if (showLoading) {
                CuToast.success(
                  msg: 'IP 已更新',
                  autoCloseDuration: const Duration(seconds: 2),
                );
              }
              return;
            }
          } else {
            final res = await dio.get<String>(url);
            if (res.data != null && res.data!.isNotEmpty) {
              currentIp.value = res.data!.trim();
              if (showLoading) {
                CuToast.success(
                  msg: 'IP 已更新',
                  autoCloseDuration: const Duration(seconds: 2),
                );
              }
              return;
            }
          }
        } catch (_) {
          continue;
        }
      }
      currentIp.value = "获取失败";
      if (showLoading) {
        CuToast.error(msg: 'IP 获取失败，请检查网络');
      }
    } finally {
      if (showLoading) {
        ipRefreshing.value = false;
        EasyLoading.dismiss();
      }
      ipRefreshedAt.value = Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss");
    }
  }
}
