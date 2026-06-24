import 'dart:async';

import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/banner_tool.dart';
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
  /// 首页收益记录列表最多展示条数（Store 仍保留全部，仅 UI 截取最新若干条）
  static const int _kHomeAdRecordDisplayMax = 10;

  final ScrollController scrollController = ScrollController();
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

  /// 构建广告记录列表（Obx 订阅 Store 列表变化）
  Widget buildChatList() {
    Utils.logError("构建聊天列表");
    return Obx(() {
      final raw = Store.instance.getAdInfos;
      final list =
          raw.length <= _kHomeAdRecordDisplayMax
              ? raw
              : raw.sublist(raw.length - _kHomeAdRecordDisplayMax);
      final bool bannerPaused = BannerTool.to.bannerPlaybackPaused.value;
      final HomeBannerSlotState bannerState =
          BannerTool.to.bannerSlotState.value;
      final bool bannerLoading =
          !bannerPaused && bannerState == HomeBannerSlotState.loading;
      final String bannerBtnText =
          bannerPaused
              ? '开始横幅广告'
              : bannerLoading
              ? '加载中…'
              : '停止广告';
      final bool bannerBtnDisabled = bannerLoading;
      return Column(
        spacing: 10.h,
        children: [
          Expanded(
            child: Container(
              width: Get.width,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final AdInfo currentItem = list[i];
                  final String typeLabel =
                      currentItem.adType == AdInfo.typeBanner ? '横幅' : '激励视频';
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.h,
                      vertical: 5.w,
                    ),
                    margin: EdgeInsets.only(bottom: 10.h),
                    width: 100.w,
                    color: Colors.white70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "类型：$typeLabel",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "预估收益（元）：${AdInfo.formatDisplayRevenue(currentItem.publisherRevenue)}",
                          style: TextStyle(color: Colors.red),
                        ),
                        Text("生成时间：${currentItem.createdTime}"),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Wrap(
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
            ],
          ),
        ],
      );
    });
  }

  void allInit() async {
    Store.instance.initAdInfos();
    await Store.instance.getFkConfigFn();
    fetchCurrentIp();
  }

  @override
  void onInit() {
    Utils.logError("首页页面onInit");
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
    Utils.logError("首页页面关闭");
    super.onClose();
  }

  @override
  void onReady() {
    Utils.logError("首页页面onReady");
    super.onReady();
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
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ),
    );
    // 国内优先；国外源作兜底（部分网络环境可能不可达）
    final urls = <String>[
      'https://myip.ipip.net',
      'https://api-ipv4.ip.sb/ip',
      'https://qifu-api.baidubce.com/ip/local/geo/v1/district?ip=',
      'https://api.ipify.org',
      'https://httpbin.org/ip',
    ];
    try {
      for (final url in urls) {
        try {
          final String? ip = await _fetchIpFromUrl(dio, url);
          if (ip != null) {
            currentIp.value = ip;
            if (showLoading) {
              CuToast.success(
                msg: 'IP 已更新',
                autoCloseDuration: const Duration(seconds: 2),
              );
            }
            return;
          }
        } catch (e, st) {
          Utils.logError('IP 请求失败 [$url]: $e', error: e, stackTrace: st);
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

  static bool _isValidIpv4(String value) {
    final parts = value.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final int? n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  Future<String?> _fetchIpFromUrl(Dio dio, String url) async {
    if (url.contains('httpbin')) {
      final res = await dio.get<Map<String, dynamic>>(url);
      final origin = res.data?['origin']?.toString().trim();
      if (origin != null && origin.isNotEmpty) {
        final ip = origin.split(',').first.trim();
        return _isValidIpv4(ip) ? ip : null;
      }
      return null;
    }
    if (url.contains('baidubce')) {
      final res = await dio.get<Map<String, dynamic>>(url);
      final Map<String, dynamic>? data = res.data;
      final dynamic nested = data?['data'];
      if (nested is Map) {
        final String? ip = nested['ip']?.toString().trim();
        if (ip != null && _isValidIpv4(ip)) return ip;
      }
      final String? direct = data?['ip']?.toString().trim();
      if (direct != null && _isValidIpv4(direct)) return direct;
      return null;
    }
    final res = await dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );
    final String? raw = res.data?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (_isValidIpv4(raw)) return raw;
    // 部分接口可能返回带换行或前后缀的纯文本
    final match = RegExp(r'\d{1,3}(?:\.\d{1,3}){3}').firstMatch(raw);
    final String? ip = match?.group(0);
    return ip != null && _isValidIpv4(ip) ? ip : null;
  }
}
