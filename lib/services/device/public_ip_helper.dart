import 'package:base_object/utils/Utils.dart';
import 'package:dio/dio.dart';

/// 获取公网 IPv4，供 ACE 收益上报等使用。
class PublicIpHelper {
  static const String unknownIp = 'unknown';

  static final List<String> _urls = <String>[
    'https://api-ipv4.ip.sb/ip',
    'https://api.ipify.org',
    'https://myip.ipip.net',
    'https://qifu-api.baidubce.com/ip/local/geo/v1/district?ip=',
    'https://httpbin.org/ip',
  ];

  /// 成功返回 IPv4；全部失败返回 [unknownIp]。
  static Future<String> resolve() async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: <String, dynamic>{'User-Agent': 'Mozilla/5.0'},
      ),
    );
    for (final String url in _urls) {
      try {
        final String? ip = await _fetchFromUrl(dio, url);
        if (ip != null) return ip;
      } catch (e, st) {
        Utils.logError('PublicIp 失败 [$url]: $e', error: e, stackTrace: st);
      }
    }
    return unknownIp;
  }

  static bool _isValidIpv4(String value) {
    final List<String> parts = value.split('.');
    if (parts.length != 4) return false;
    for (final String part in parts) {
      final int? n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  static Future<String?> _fetchFromUrl(Dio dio, String url) async {
    if (url.contains('httpbin')) {
      final Response<Map<String, dynamic>> res =
          await dio.get<Map<String, dynamic>>(url);
      final String? origin = res.data?['origin']?.toString().trim();
      if (origin == null || origin.isEmpty) return null;
      final String ip = origin.split(',').first.trim();
      return _isValidIpv4(ip) ? ip : null;
    }
    if (url.contains('baidubce')) {
      final Response<Map<String, dynamic>> res =
          await dio.get<Map<String, dynamic>>(url);
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
    final Response<String> res = await dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );
    final String? raw = res.data?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (_isValidIpv4(raw)) return raw;
    final Match? match = RegExp(r'\d{1,3}(?:\.\d{1,3}){3}').firstMatch(raw);
    final String? ip = match?.group(0);
    return ip != null && _isValidIpv4(ip) ? ip : null;
  }
}
