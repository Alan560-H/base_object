import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/shared/config/app_config.dart';
import 'package:base_object/store/store.dart';
import 'package:get/get.dart';
import 'user_info.dart';

/// 全局依赖注入
class DependencyInjection {
  static Future<void> mainInit() async {
    Get.put<UserInfo>(UserInfo());
    Get.put<AppConfig>(AppConfig());
    Get.put<AppAdConfig>(AppAdConfig());
    Get.put<Store>(Store());
  }
}
