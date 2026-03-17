import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/store/store.dart';
import 'package:get/get.dart';
import 'user_info.dart';

/// 统一注入
class DependencyInjection {
  /// 依赖注入
  static Future<void> mainInit() async {
    Get.put<UserInfo>(UserInfo());
    Get.put<AppConfig>(AppConfig());
    Get.put<AppAdConfig>(AppAdConfig());
    Get.put<Api>(Api());
    Get.put<Store>(Store());
  }
}
