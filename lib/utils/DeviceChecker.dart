import 'dart:io';

import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:emulator_checker/emulator_checker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_device/safe_device.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:flutter/services.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:vpn_connection_detector/vpn_connection_detector.dart';

class DeviceChecker {
  static _cuMsg(String msg) async {
    CuToast.error(msg: msg);
    await Future.delayed(const Duration(seconds: 2));
    SystemNavigator.pop();
  }

  /// 检查是否插卡 true:插卡了，false：没有插卡
  static Future<bool> hasSimCard() async {
    try {
      List<SimInfo>? simCards = await SimCardInfo().getSimInfo();
      bool hasSim = simCards?.isNotEmpty ?? false;
      Utils.logError("是否插卡：$hasSim");
      EasyLoading.show(status: "是否插卡：$hasSim");
      if (!hasSim) {
        await _cuMsg("请插入SIM卡");
      }
      return hasSim;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否开启蓝牙 true:开启了蓝牙，false：没有开启蓝牙
  static Future<bool> isBluetoothActive() async {
    try {
      bool isBluetoothOpen = await Permission.bluetooth.isGranted;
      Utils.logError("是否开启蓝牙：$isBluetoothOpen");
      EasyLoading.show(status: "是否开启蓝牙：$isBluetoothOpen");
      if (isBluetoothOpen) {
        await _cuMsg("请关闭蓝牙后再重新打开本程序");
      }
      return isBluetoothOpen;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否开启开发者模式（仅Android） true:开启了开发者模式，false：没开
  static Future<bool> isDeveloperModeEnabled() async {
    try {
      if (Platform.isAndroid) {
        bool isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;
        Utils.logError("是否开启开发者模式：$isDevelopmentModeEnable");

        EasyLoading.show(status: "是否开启开发者模式：$isDevelopmentModeEnable");
        if (isDevelopmentModeEnable) {
          await _cuMsg("请关闭开发者模式后再重新打开本程序");
        }
        return isDevelopmentModeEnable;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否为为越狱设备 true:是模拟器，false：不是模拟器
  static Future<bool> isJailBrokenFN() async {
    if (Platform.isAndroid) {
      bool isJailBroken = await SafeDevice.isJailBroken;
      Utils.logError("是否越狱：$isJailBroken");
      EasyLoading.show(status: "是否越狱：$isJailBroken");
      if (isJailBroken) {
        await _cuMsg("不允许在越狱设备上运行");
      }
      return isJailBroken;
    }
    return false;
  }

  /// 检查是否为为越狱设备 true:是模拟器，false：不是模拟器
  static Future<bool> isVpnActive() async {
    if (Platform.isAndroid) {
      bool isVpn = await VpnConnectionDetector.isVpnActive();
      Utils.logError("是否开启vpn：$isVpn");
      if (isVpn) {
        await _cuMsg("请关闭vpn后再重新打开本程序");
      }
      return isVpn;
    }
    return false;
  }

  /// 检查是否为模拟器 true:是真实设备，false：是模拟器
  static Future<bool> isEmulator() async {
    if (Platform.isAndroid) {
      bool isRealDevice = await EmulatorChecker.isEmulator();
      Utils.logError("是否为模拟器设备：$isRealDevice");
      if (isRealDevice) {
        await _cuMsg("不允许在模拟器上运行");
      }
      return isRealDevice;
    }
    return false;
  }

  /// 检查无障碍模式是否开启（需要原生支持）
  static Future<bool> isAccessibilityModeEnabled() async {
    try {
      const platform = MethodChannel('com.example.riskcontrol');
      bool isAccess = await platform.invokeMethod('isAccessibilityModeEnabled');
      Utils.logError("是否开启无障碍模式：$isAccess");
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
      Utils.logError("是否开启无障碍软件：${enabledServices.isEmpty}");
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
  static Future<void> isAllCheckr() async {
    try {
      // await isBluetoothActive();
      // await isJailBrokenFN();
      // await hasSimCard();
      // await isVpnActive();
      // await isDeveloperModeEnabled();
      // await isEmulator();
      EasyLoading.showSuccess("设备检测完成");
      // bool isAccess = await isAccessibilityModeEnabled();
      // await Future.delayed(const Duration(milliseconds: 100));
      //
      // List<String> enabledServices = await getEnabledAccessibilityServices();
      // await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      Utils.logError("检测设备不通过：$e");
      EasyLoading.dismiss();
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
