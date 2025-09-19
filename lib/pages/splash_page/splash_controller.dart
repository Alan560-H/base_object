import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/models/localModels/LocationData.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/DeviceChecker.dart';
import 'package:base_object/utils/LocationUtil.dart';
import 'package:base_object/utils/OpenInstallUtils.dart';
import 'package:base_object/utils/PermissionManager.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';

class SplashController extends GetxController {
  /// 初始化广告
  Future<void> initAd() async {
    InitTool.to.setCustomDataDic({
      "user_id": 0,
      "extra": "userid_0_type_1_amount_0_time_0",
    });
    // 初始化广告
    bool isInitAd = await InitTool.to.initTopon();
    Utils.logError("广告初始化完成 $isInitAd ");
  }

  @override
  void onInit() async {
    EasyLoading.show(status: "检测设备中..");
    // await initDeepLinks();
    OpenInstallUtils.initUtils();

    /// 初始化广告
    initAd();
    SplashTool.to.loadSplash();

    /// 初始化开屏广告
    SplashTool.to.splashListen();
    bool isPermission = await PermissionManager.requestAllPermissions();
    Utils.logError(isPermission);
    bool isAllCheck = await DeviceChecker.isAllCheckr();
    if (isAllCheck) {
      await LocationUtil().getCurrentLocation((Map result) async {
        Utils.logError("定位结果：$result");
        LocationData locationData = LocationData(
          address: result["address"],
          latitude: result["latitude"],
          longitude: result["longitude"],
        );
        Store.instance.setLocationData(locationData);
      });
      Store.instance.getVer().then((value) async {
        Utils.logError("返回的数值：$value");
        // 如果被封了，就去错误页面
        if (value) {
          Get.offAllNamed(AppRoutes.userError);
        } else {
          /// 上传地址
          await Store.instance.upAddress();

          /// 获取风控配置
          Store.instance.getFkConfigFn();

          /// 获取今日领取了多少个红包
          Store.instance.initCurrentCount();
          if (await SplashTool.to.splashReady()) {
            SplashTool.to.showSplash();
          }
        }
      });
    }
    super.onInit();
  }

  // /// 优化后的深度链接初始化
  // Future<void> initDeepLinks() async {
  //   try {
  //     _appLinks = AppLinks();
  //
  //     // 1. 处理冷启动时的初始链接（用 await 确保同步处理，避免遗漏）
  //     final Uri? initialUri = await _appLinks.getInitialLink();
  //     Utils.logError("链接开始");
  //     if (initialUri != null) {
  //       Utils.logError("啊啊啊冷启动初始链接：$initialUri");
  //       _parseInviteCode(initialUri); // 解析邀请码
  //     }
  //
  //     // 2. 监听应用运行时的链接（热启动/后台唤起）
  //     _linkSubscription = _appLinks.uriLinkStream.listen(
  //       (Uri uri) {
  //         Utils.logError("啊啊啊运行时收到链接：$uri");
  //         _parseInviteCode(uri); // 解析邀请码
  //       },
  //       onError: (error) {
  //         Utils.logError("啊啊啊深度链接监听错误：$error");
  //       },
  //     );
  //   } catch (e) {
  //     Utils.logError("啊啊啊深度链接初始化失败：$e");
  //   }
  // }

  // /// 核心：解析链接中的邀请码（invite 参数）
  // void _parseInviteCode(Uri uri) {
  //   // 从链接中提取 "invite" 参数（如 myapp://?invite=aa1234 → 提取 aa1234）
  //   final String? inviteCode = uri.queryParameters['invite'];
  //   if (inviteCode != null && inviteCode.isNotEmpty) {
  //     Utils.logError("成功解析邀请码：$inviteCode");
  //     Store.instance.setInviteCode(inviteCode);
  //     // 存储邀请码（示例：用 GetStorage）
  //     // GetStorage().write('invite_code', inviteCode);
  //     // 可在这里直接处理邀请码逻辑（如绑定、跳转等）
  //     // _handleInviteCode(inviteCode);
  //   } else {
  //     Utils.logError("链接中未包含邀请码");
  //   }
  // }

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
}
