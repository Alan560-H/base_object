import 'dart:io';

import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:flutter/services.dart';
import 'package:sim_card_info/sim_info.dart';

class DeviceChecker {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// 检查是否开启调试模式 true:开启了调试模式，false：没开
  static Future<bool> isDebugMode() async {
    bool isDebug = false;
    assert(isDebug = true);
    Utils.logError("是否开启调试模式：$isDebug");
    EasyLoading.show(status: "是否开启调试模式：$isDebug");
    if (!isDebug) {
      CuToast.error(msg: "请关闭调试模式后再重新打开本程序");
      EasyLoading.dismiss();
      throw Exception("开启了调试模式");
    }
    return isDebug;
  }

  /// 检查是否使用VPN true:使用了vpn，false：没有使用vpn
  static Future<bool> isVpnActive() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    bool isVpn = connectivityResult == ConnectivityResult.vpn;
    Utils.logError("是否使用VPN：$isVpn");
    EasyLoading.show(status: "是否使用VPN：$isVpn");
    if (isVpn) {
      CuToast.error(msg: "请关闭VPN再重新打开本程序");
      throw Exception("使用了VPN");
    }

    return isVpn;
  }

  /// 检查是否插卡 true:插卡了，false：没有插卡
  static Future<bool> hasSimCard() async {
    try {
      List<SimInfo>? simCards = await SimCardInfo().getSimInfo();
      bool hasSim = simCards?.isNotEmpty ?? false;
      Utils.logError("是否插卡：$hasSim");
      EasyLoading.show(status: "是否插卡：$hasSim");
      if (!hasSim) {
        CuToast.error(msg: "请插卡后再重新打开本程序");
        throw Exception("没有插卡");
      }

      return hasSim;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否开启开发者模式（仅Android）
  /// 检查是否开启开发者模式（仅Android） true:开启了开发者模式，false：没开
  static Future<bool> isDeveloperModeEnabled() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        // 需要通过MethodChannel调用原生方法获取开发者模式状态
        const platform = MethodChannel('com.example/riskcontrol');
        bool isDeveloperMode = await platform.invokeMethod(
          'isDeveloperModeEnabled',
        );
        Utils.logError("是否开启开发者模式：$isDeveloperMode");
        EasyLoading.show(status: "是否开启开发者模式：$isDeveloperMode");
        if (isDeveloperMode) {
          CuToast.error(msg: "请关闭开发者模式后再重新打开本程序");
          throw Exception("开启了开发者模式");
        }
        return isDeveloperMode;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否为模拟器 true:是模拟器，false：不是模拟器
  static Future<bool> isEmulator() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
      bool isEmu = androidInfo.isPhysicalDevice != true;

      await Future.delayed(const Duration(milliseconds: 500));
      Utils.logError("是否为模拟器：$isEmu");
      EasyLoading.show(status: "是否为模拟器：$isEmu");
      if (isEmu) {
        CuToast.error(msg: "不允许在模拟器上运行");
        throw Exception("是模拟器");
      }
      return isEmu;
    }
    return false;
  }

  /// 检查是否为云机（需要根据特定特征判断）
  /// 检查是否为云机（需要根据特定特征判断） true:是云机，false：不是云机
  static Future<bool> isCloudDevice() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
      // 根据设备型号、制造商等信息判断
      List<String> cloudDeviceManufacturers = [
        'Google',
        'Amazon',
        'Genymotion',
      ];
      bool isCloud = cloudDeviceManufacturers.contains(
        androidInfo.manufacturer,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Utils.logError("是否为云机：$isCloud");
      EasyLoading.show(status: "是否为云机：$isCloud");
      if (isCloud) {
        CuToast.error(msg: "不允许在云机上运行");
        throw Exception("是云机");
      }
      return isCloud;
    }
    return false;
  }

  /// 检查无障碍模式是否开启（需要原生支持）
  static Future<bool> isAccessibilityModeEnabled() async {
    try {
      const platform = MethodChannel('com.example/riskcontrol');
      bool isAccess = await platform.invokeMethod('isAccessibilityModeEnabled');
      await Future.delayed(const Duration(milliseconds: 500));
      Utils.logError("是否开启无障碍模式：$isAccess");
      EasyLoading.show(status: "是否开启无障碍模式：$isAccess");
      if (isAccess) {
        CuToast.error(msg: "请关闭无障碍模式后再重新打开本程序");
        throw Exception("开启了无障碍模式");
      }
      return isAccess;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否有开启的无障碍软件
  static Future<List<String>> getEnabledAccessibilityServices() async {
    try {
      const platform = MethodChannel('com.example/riskcontrol');
      List<dynamic> services = await platform.invokeMethod(
        'getEnabledAccessibilityServices',
      );
      List<String> enabledServices = services.cast<String>();
      await Future.delayed(const Duration(milliseconds: 500));
      Utils.logError("是否开启无障碍软件：${enabledServices.isEmpty}");
      EasyLoading.show(status: "是否开启无障碍软件：${enabledServices.isEmpty}");
      if (enabledServices.isNotEmpty) {
        CuToast.error(msg: "请关闭无障碍软件后再重新打开本程序");
        throw Exception("开启了无障碍软件");
      }
      return enabledServices;
    } catch (e) {
      return [];
    }
  }

  /// 检查所有设备相关的权限和特征 true:所有权限和特征都满足，false：有一个不满足
  static Future<bool> isAllCheckr() async {
    try {
      bool isDebug = await isDebugMode();
      await Future.delayed(const Duration(milliseconds: 100));
      bool isVpn = await isVpnActive();
      await Future.delayed(const Duration(milliseconds: 100));

      bool hasSim = await hasSimCard();
      await Future.delayed(const Duration(milliseconds: 100));

      bool isDev = await isDeveloperModeEnabled();
      await Future.delayed(const Duration(milliseconds: 100));

      bool isEmu = await isEmulator();
      await Future.delayed(const Duration(milliseconds: 100));

      bool isCloud = await isCloudDevice();
      await Future.delayed(const Duration(milliseconds: 100));

      bool isAccess = await isAccessibilityModeEnabled();
      await Future.delayed(const Duration(milliseconds: 100));

      List<String> enabledServices = await getEnabledAccessibilityServices();
      await Future.delayed(const Duration(milliseconds: 100));

      bool res =
          isDebug &&
          !isVpn &&
          hasSim &&
          !isDev &&
          !isEmu &&
          !isCloud &&
          !isAccess &&
          enabledServices.isEmpty;
      if (res) {
        EasyLoading.showSuccess("检测通过");
      } else {
        EasyLoading.showError("检测不通过");
      }

      return res;
    } catch (e) {
      Utils.logError("检测设备不通过：$e");
      EasyLoading.dismiss();
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
