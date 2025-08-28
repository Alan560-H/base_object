import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  /// 生成 MD5(base64(用户id+req_id+adsource_id)) 的加密结果
  /// [userId] 用户ID
  /// [reqId] 请求ID
  /// [adsourceId] 广告源ID
  static String generateEncryptedString({
    required String userId,
    required String reqId,
    required String adsourceId,
  }) {
    // 1. 拼接字符串：用户id + req_id + adsource_id
    final String rawString = '$userId$reqId$adsourceId';

    // 2. 对拼接后的字符串进行 Base64 编码
    final String base64Encoded = base64.encode(utf8.encode(rawString));

    // 3. 对 Base64 结果进行 MD5 加密
    final Digest md5Digest = md5.convert(utf8.encode(base64Encoded));

    // 4. 将 MD5 结果转换为 32 位小写十六进制字符串
    return md5Digest.toString();
  }
  // 想下取整
  static double floorToTwoDecimal(double value) {
    // 先乘以100放大，向下取整，再除以100还原，得到保留两位小数的结果
    return (value * 100).floorToDouble() / 100;
  }
  // 初始化 Logger 实例，使用 PrettyPrinter 进行日志格式化
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // 显示调用栈的方法数量
      errorMethodCount: 8, // 显示错误调用栈的方法数量
      lineLength: 120, // 每行日志的最大长度
      colors: true, // 是否使用颜色输出
      printEmojis: true, // 是否打印表情符号
    ),
  );
  /// 静态方法用于校验手机号，true即代表通过，false代表不通过
  static bool isValidPhoneNumber(String phoneNumber) {
    // 定义正则表达式模式，用于匹配中国手机号格式
    final RegExp phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phoneNumber);
  }
  static void openUrl(Uri url) async {
    launchUrl(url);
  }
  // 将十六进制字符串转换为 Color 对象
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // 打印详细日志
  static void logDebug(dynamic message) {
    _logger.d(message);
  }

  // 打印信息日志
  static void logInfo(dynamic message) {
    _logger.i(message);
  }

  // 打印警告日志
  static void logWarning(dynamic message) {
    _logger.w(message);
  }

  // 打印错误日志
  static void logError(
      dynamic message, {
        DateTime? time,
        Object? error,
        StackTrace? stackTrace,
      }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
// 获取屏幕宽度
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // 获取屏幕高度
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 复制文本到剪切板，返回是否成功
  static Future<bool> copyText(String? str) async {
    try {
      // 执行复制操作
      await Clipboard.setData(ClipboardData(text: str ?? ""));
      // 复制成功返回true
      return true;
    } catch (e) {
      // 复制失败返回false
      Utils.logError("复制失败: $e");
      return false;
    }
  }
  static Timer? _debounceTimer;
  /// 防抖函数
  static void debounce(
      VoidCallback action, {
        Duration duration = const Duration(milliseconds: 500),
      }) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(duration, action);
  }
  ///生成色相旋转的颜色矩阵
  static List<double> hueRotationMatrix(double degrees) {
    final double rad = degrees * (3.14159265358979323846 / 180.0);
    final double cosR = cos(rad);
    final double sinR = sin(rad);

    return [
      0.213 + cosR * 0.787 - sinR * 0.213,
      0.715 - cosR * 0.715 - sinR * 0.715,
      0.072 - cosR * 0.072 + sinR * 0.928,
      0,
      0,
      0.213 - cosR * 0.213 + sinR * 0.143,
      0.715 + cosR * 0.285 + sinR * 0.140,
      0.072 - cosR * 0.072 - sinR * 0.283,
      0,
      0,
      0.213 - cosR * 0.213 - sinR * 0.787,
      0.715 - cosR * 0.715 + sinR * 0.715,
      0.072 + cosR * 0.928 + sinR * 0.072,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

