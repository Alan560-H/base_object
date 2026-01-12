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

  /// 新增：获取对象数组（适配NoticeModel列表）
  /// [fromJson] 是将单个Map转换为对象的方法，例如 `NoticeModel.fromJson`
  static Future<List<T>?> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      String? jsonString = await getString(key);
      if (jsonString == null) {
        return null;
      }
      // 数组解码后是List<dynamic>，而非Map
      List<dynamic> jsonList = jsonDecode(jsonString);
      // 遍历数组，逐个转换为NoticeModel对象
      return jsonList.map((json) => fromJson(json)).toList();
    } catch (e) {
      print('Error retrieving object list: $e');
      return null;
    }
  }

  /// 新增：获取对象
  /// [fromJson] 是一个工厂构造函数或静态方法，用于将 Map 转换回对象，例如 `User.fromJson`
  static Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      // 获取存储的 JSON 字符串
      String? jsonString = await getString(key);
      if (jsonString == null) {
        return null;
      }
      // 将 JSON 字符串解码为 Map
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      // 使用传入的 fromJson 方法将 Map 转换为目标对象
      return fromJson(jsonMap);
    } catch (e) {
      print('Error retrieving object: $e');
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

  /// 清除一天的数据
  static Future<void> clearOneDayData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> keys = prefs.getKeys();
    for (final String key in keys) {
      if (key.contains(oneDayClear)) {
        await prefs.remove(key);
      }
    }
  }
}
