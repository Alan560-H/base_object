import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/store/store.dart';
import 'package:get/get.dart';

import 'user_info.dart';

/// 统一注入
class DependencyInjection {
  /// 依赖注入
    static void init() {
      // 注册 UserInfo 依赖
      Get.put<UserInfo>(UserInfo());
      // 注入 appConfig 依赖
      Get.put<AppConfig>(AppConfig());
      // 注册广告配置
      Get.put<AppAdConfig>(AppAdConfig());
      // 注入
      Get.put<Store>(Store());
    }
}