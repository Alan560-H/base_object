import 'dart:io';

import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';

/// 与 [FlutterAndroidOaidPlugin.getOAID] 官方 API 一致，增加超时与无效值过滤。
class OaidHelper {
  static const Duration readTimeout = Duration(seconds: 5);

  /// 厂商/插件可能返回的占位或无效串
  static bool looksLikeValidOaid(String s) {
    final String t = s.trim();
    if (t.isEmpty) return false;
    final lower = t.toLowerCase();
    if (lower == 'null' || lower == 'undefined' || lower == 'unknown') {
      return false;
    }
    // 常见空 OAID 占位
    if (t == '00000000-0000-0000-0000-000000000000') return false;
    final String digits = t.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (digits.isNotEmpty && RegExp(r'^0+$').hasMatch(digits)) return false;
    // 正常 OAID 多为 16～64 位十六进制或带连字符，过短视为异常
    if (t.length < 8) return false;
    return true;
  }

  /// 读取 OAID；失败、超时或无效则返回 null。
  static Future<String?> readOaidOnce() async {
    if (!Platform.isAndroid) return null;
    final String raw =
        await FlutterAndroidOaidPlugin.getOAID().timeout(readTimeout);
    final String trimmed = raw.trim();
    if (!looksLikeValidOaid(trimmed)) return null;
    return trimmed;
  }

  /// 首次读取；若无效则在短暂延迟后重试一次（部分机型 MSA 初始化略晚）。
  static Future<String> readOaidForDisplay() async {
    if (!Platform.isAndroid) return 'iOS 无 OAID';
    try {
      String? first = await readOaidOnce();
      if (first != null) return first;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      String? second = await readOaidOnce();
      if (second != null) return second;
      return '未获取到 OAID';
    } catch (_) {
      return 'OAID 获取失败';
    }
  }
}
