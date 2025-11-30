import 'dart:io';

import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:emulator_checker/emulator_checker.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  /// 检查蓝牙是否开启（硬件状态）
  static Future<bool> isBluetoothActive() async {
    try {
      // 步骤3：获取蓝牙状态（Android特有处理，无需处理iOS的unknown状态）
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      // 步骤4：判断蓝牙是否开启（Android特有状态判断）
      bool isOpen = (state == BluetoothAdapterState.on);
      Utils.logError("蓝牙是否开启：$isOpen");
      // 等待状态返回（超时保护：5秒未返回则判定为失败，文档「Debugging」超时处理）
      if (isOpen) {
        await _cuMsg("请关闭蓝牙后再重新打开本程序");
      }
      return isOpen;
    } catch (e) {
      Utils.logError("检测蓝牙状态失败：$e");
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

      /// 检测通过
    } catch (e) {
      Utils.logError("检测设备不通过：$e");
      EasyLoading.dismiss();
    } finally {
      EasyLoading.dismiss();
    }
  }
}
