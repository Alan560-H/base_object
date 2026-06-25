import 'package:base_object/features/home/presentation/home_state.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void init() {
    Utils.logError('首页 Notifier init');
    fetchCurrentIp();
    _loadAppDisplayName();
  }

  Future<void> _loadAppDisplayName() async {
    try {
      final PackageInfo p = await PackageInfo.fromPlatform();
      state = state.copyWith(appDisplayName: p.appName);
    } catch (e, st) {
      Utils.logError('读取应用名称失败: $e $st');
    }
  }

  Future<void> pauseBanner() async {
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

  Future<void> startBanner() async {
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

  Future<void> fetchCurrentIp({bool showLoading = false}) async {
    if (showLoading) {
      if (state.ipRefreshing) return;
      state = state.copyWith(ipRefreshing: true);
      EasyLoading.show(status: '正在获取 IP…', maskType: EasyLoadingMaskType.clear);
    }
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ),
    );
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
            state = state.copyWith(currentIp: ip);
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
      state = state.copyWith(currentIp: '获取失败');
      if (showLoading) {
        CuToast.error(msg: 'IP 获取失败，请检查网络');
      }
    } finally {
      if (showLoading) {
        state = state.copyWith(ipRefreshing: false);
        EasyLoading.dismiss();
      }
      state = state.copyWith(
        ipRefreshedAt: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
      );
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
    final match = RegExp(r'\d{1,3}(?:\.\d{1,3}){3}').firstMatch(raw);
    final String? ip = match?.group(0);
    return ip != null && _isValidIpv4(ip) ? ip : null;
  }
}
