import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


/// 本地数据存储工具类
class LocalStorage {
  static const String userInfoKey = 'user_info'; // 用户信息存储键
  static const String oneDayClear = 'one_day_clear'; // 一天会清除的数据
  /// 存储字符串数据
  static Future<void> setString(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }
  /// 获取字符串数据
  static Future<String?> getString(String key) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      return null;
    }
  }
  /// 移除指定键的数据
  static Future<bool> removeString(String key) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }

}