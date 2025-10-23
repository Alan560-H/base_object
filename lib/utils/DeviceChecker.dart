import 'dart:io';

import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:emulator_checker/emulator_checker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:flutter/services.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:vpn_connection_detector/vpn_connection_detector.dart';

class DeviceChecker {
  /// 检查是否插卡 true:插卡了，false：没有插卡
  static Future<bool> hasSimCard() async {
    try {
      List<SimInfo>? simCards = await SimCardInfo().getSimInfo();
      bool hasSim = simCards?.isNotEmpty ?? false;
      Utils.logError("是否插卡：$hasSim");
      EasyLoading.show(status: "是否插卡：$hasSim");
      print("是否插卡：$hasSim");

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
        // 需要通过MethodChannel调用原生方法获取开发者模式状态
        const platform = MethodChannel('com.example.riskcontrol');
        bool isDeveloperMode = await platform.invokeMethod(
          'isDeveloperModeEnabled',
        );
        Utils.logError("是否开启开发者模式：$isDeveloperMode");
        print("是否开启开发者模式：$isDeveloperMode");

        EasyLoading.show(status: "是否开启开发者模式：$isDeveloperMode");

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
      bool isEmu = await EmulatorChecker.isEmulator();
      await Future.delayed(const Duration(milliseconds: 500));
      Utils.logError("是否为模拟器：$isEmu");
      print("是否为模拟器：$isEmu");

      EasyLoading.show(status: "是否为模拟器：$isEmu");
      if (isEmu) {
        CuToast.error(msg: "不允许在模拟器上运行");
        await Future.delayed(const Duration(seconds: 2));
        SystemNavigator.pop();
      }
      return isEmu;
    }
    return false;
  }

  /// 检查无障碍模式是否开启（需要原生支持）
  static Future<bool> isAccessibilityModeEnabled() async {
    try {
      const platform = MethodChannel('com.example.riskcontrol');
      bool isAccess = await platform.invokeMethod('isAccessibilityModeEnabled');
      await Future.delayed(const Duration(milliseconds: 500));
      Utils.logError("是否开启无障碍模式：$isAccess");
      print("是否开启无障碍模式：$isAccess");
      EasyLoading.show(status: "是否开启无障碍模式：$isAccess");
      if (isAccess) {
        CuToast.error(msg: "请关闭无障碍模式后再重新打开本程序");
        await Future.delayed(const Duration(seconds: 2));
        SystemNavigator.pop();
      }
      return isAccess;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否有开启的无障碍软件
  static Future<List<String>> getEnabledAccessibilityServices() async {
    try {
      const platform = MethodChannel('com.example.riskcontrol');
      List<dynamic> services = await platform.invokeMethod(
        'getEnabledAccessibilityServices',
      );
      List<String> enabledServices = services.cast<String>();
      await Future.delayed(const Duration(milliseconds: 500));
      Utils.logError("是否开启无障碍软件：${enabledServices.isEmpty}");
      print("是否开启无障碍软件：${enabledServices.isEmpty}");
      EasyLoading.show(status: "是否开启无障碍软件：${enabledServices.isEmpty}");
      if (enabledServices.isNotEmpty) {
        CuToast.error(msg: "请关闭无障碍软件后再重新打开本程序");
        await Future.delayed(const Duration(seconds: 2));
        SystemNavigator.pop();
      }
      return enabledServices;
    } catch (e) {
      return [];
    }
  }

  /// 检查所有设备相关的权限和特征 true:所有权限和特征都满足，false：有一个不满足
  static Future<bool> isAllCheckr() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      bool isVpn = await VpnConnectionDetector.isVpnActive();
      await Future.delayed(const Duration(milliseconds: 100));

      bool hasSim = await hasSimCard();
      await Future.delayed(const Duration(milliseconds: 100));

      bool isDev = await isDeveloperModeEnabled();
      await Future.delayed(const Duration(milliseconds: 100));

      bool isEmu = await isEmulator();
      await Future.delayed(const Duration(milliseconds: 100));

      // bool isAccess = await isAccessibilityModeEnabled();
      // await Future.delayed(const Duration(milliseconds: 100));
      //
      // List<String> enabledServices = await getEnabledAccessibilityServices();
      // await Future.delayed(const Duration(milliseconds: 100));

      bool res = !isVpn && hasSim && !isDev && !isEmu;
      // bool res = true;
      if (res) {
        EasyLoading.showSuccess("检测通过");
      } else {
        if (isVpn) {
          CuToast.error(msg: "请关闭VPN后再重新打开本程序");
        } else if (!hasSim) {
          CuToast.error(msg: "请插入SIM卡后再重新打开本程序");
        } else if (isDev) {
          CuToast.error(msg: "不允许在开发者模式下运行");
        } else if (isEmu) {
          CuToast.error(msg: "不允许在模拟器上运行");
        }
        // 去掉 await，用 then 回调实现“10秒后异步执行”，不阻塞当前函数
        Future.delayed(const Duration(seconds: 2), () {
          SystemNavigator.pop();
        });
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
