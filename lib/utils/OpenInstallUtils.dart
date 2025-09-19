import 'dart:convert';

import 'package:base_object/store/store.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';

import 'Utils.dart';

class OpenInstallUtils {
  static final _openinstallFlutterPlugin = OpeninstallFlutterPlugin();
  static Future wakeupHandler(Map<String, Object> data) async {
    Utils.logError("openInstall的初始化参数:$data");
  }

  /// 初始化
  static initUtils() {
    _openinstallFlutterPlugin.init(wakeupHandler);
  }

  /// 安装回调
  static Future installHandler(Map<String, Object> data) async {
    Utils.logError("openInstall的安装参数:${data["bindData"]}");
    // 1. 先获取bindData（注意类型转换，因为它是嵌套的Map）
    if (data.containsKey("bindData") && data["bindData"] is String) {
      // 1. 先获取bindData的JSON字符串
      String bindDataJson = data["bindData"] as String;

      try {
        // 2. 解析JSON字符串为Map（处理可能的JSON格式错误）
        Map<dynamic, dynamic>? bindData =
            jsonDecode(bindDataJson) as Map<dynamic, dynamic>?;

        if (bindData != null) {
          // 3. 从解析后的Map中获取invite
          if (bindData.containsKey("invite")) {
            String invite = bindData["invite"].toString(); // 转为String确保类型安全
            Utils.logError("invite的值是：$invite"); // 输出：invite的值是：aa123456
            Store.instance.setInviteCode(invite);
          } else {
            Utils.logError("bindData解析后没有invite键");
          }
        } else {
          Utils.logError("bindData解析后为空");
        }
      } catch (e) {
        // 捕获JSON解码异常（如格式错误、类型不匹配等）
        Utils.logError("bindData JSON解析失败：$e");
      }
    } else {
      Utils.logError("a中没有bindData键，或bindData不是String类型（非JSON字符串）");
    }
  }

  static initInstallHandler() {
    _openinstallFlutterPlugin.install(installHandler);
  }
}
