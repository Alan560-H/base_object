import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/api/api_binding.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/dialogs/interAdDialog/interAdDialog.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

import 'user_info.dart';

/// 统一注入
class DependencyInjection {
  /// 依赖注入
  static Future<void> mainInit() async {
    // 注册 UserInfo 依赖
    Get.put<UserInfo>(UserInfo());
    // 注入 appConfig 依赖
    Get.put<AppConfig>(AppConfig());
    // 注册广告配置
    Get.put<AppAdConfig>(AppAdConfig());

    // 注入api
    ApiBinding().dependencies();
    // 注入
    Get.put<Store>(Store());
  }
}
