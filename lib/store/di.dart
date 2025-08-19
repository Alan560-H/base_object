import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/api/api_binding.dart';
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
    static Future<void> init() async {
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
      // 注入banner工具
      Get.put<BannerTool>(BannerTool());
      // 注入广告工具
      Get.put<InitTool>(InitTool());
      // 注入开屏广告工具
      Get.put<SplashTool>(SplashTool());
      // 注入激励视频工具
      Get.put<RewarderTool>(RewarderTool());
      // 注入监听工具
      Get.put<InterstitialTool>(InterstitialTool());
      // 注入信息流工具
      Get.put<NativeTool>(NativeTool());
      // 异步注入 ListenerTool（执行其 init() 方法）
      await Get.putAsync<ListenerTool>(() => ListenerTool().init());
      Utils.logError("用户：${Get.isRegistered<UserInfo>()}");
      Utils.logError("配置：${Get.isRegistered<AppConfig>()}");
      Utils.logError("广告配置：${Get.isRegistered<AppAdConfig>()}");
      Utils.logError("APi：${Get.isRegistered<Api>()}");
      Utils.logError("Store：${Get.isRegistered<Store>()}");
      Utils.logError("banner：${Get.isRegistered<BannerTool>()}");
      Utils.logError("注入广告工具：${Get.isRegistered<InitTool>()}");
      Utils.logError("注入开屏广告工具：${Get.isRegistered<SplashTool>()}");
      Utils.logError("注入激励广告工具：${Get.isRegistered<RewarderTool>()}");
      Utils.logError("注入插屏广告工具：${Get.isRegistered<InterstitialTool>()}");
      Utils.logError("注入信息流广告工具：${Get.isRegistered<NativeTool>()}");
      Utils.logError("注入广告监听工具：${Get.isRegistered<ListenerTool>()}");
    }
}