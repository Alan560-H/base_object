import 'dart:io';

import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:flutter/services.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DeviceChecker {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// 检查是否开启调试模式 true:开启了调试模式，false：没开
  static Future<bool> isDebugMode() async {
    bool isDebug = false;
    Utils.logError("是否开启调试模式：$isDebug");
    print("是否开启调试模式：$isDebug");
    EasyLoading.show(status: "是否开启调试模式：$isDebug");
    if (isDebug) {
      CuToast.error(msg: "请关闭调试模式后再重新打开本程序");
      await Future.delayed(const Duration(seconds: 2));
      SystemNavigator.pop();
    }
    return isDebug;
  }

  /// 检查是否使用VPN true:使用了vpn，false：没有使用vpn
  static Future<bool> isVpnActive() async {
    // 1. 先用connectivity_plus检测系统级VPN（兼容旧逻辑）
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return true;
    }

    // 2. 检测网络接口（VPN通常会创建虚拟接口，如tun0、ppp0、ipsec等）
    final networkInfo = NetworkInfo();
    try {
      // 获取所有网络接口（需要设备权限）
      final interfaces = await NetworkInterface.list(includeLoopback: false);
      for (var interface in interfaces) {
        // 常见VPN虚拟接口名称关键字
        final isVpnInterface =
            interface.name.contains('tun') ||
            interface.name.contains('ppp') ||
            interface.name.contains('ipsec') ||
            interface.name.contains('vpn');
        if (isVpnInterface) {
          return true;
        }
      }
    } catch (e) {
      print('检测网络接口失败：$e');
    }
    // 3. （可选）检测IP地址是否为VPN分配的私有IP（非本地局域网IP）
    // （需排除常见局域网IP段：192.168.x.x、10.x.x.x、172.16.x.x等）
    final ip = await networkInfo.getWifiIP();
    if (ip != null && !_isLocalIp(ip)) {
      return true;
    }

    return false;
  }

  // 辅助方法：判断是否为本地局域网IP
  static bool _isLocalIp(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    if (parts.length != 4) return false;
    // 10.x.x.x 或 192.168.x.x 或 172.16.x.x-172.31.x.x
    return (parts[0] == 10) ||
        (parts[0] == 192 && parts[1] == 168) ||
        (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31);
  }

  /// 检查是否插卡 true:插卡了，false：没有插卡
  static Future<bool> hasSimCard() async {
    try {
      List<SimInfo>? simCards = await SimCardInfo().getSimInfo();
      bool hasSim = simCards?.isNotEmpty ?? false;
      Utils.logError("是否插卡：$hasSim");
      EasyLoading.show(status: "是否插卡：$hasSim");
      print("是否插卡：$hasSim");

      if (!hasSim) {
        CuToast.error(msg: "请插卡后再重新打开本程序");
        await Future.delayed(const Duration(seconds: 2));
        SystemNavigator.pop();
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
        // 需要通过MethodChannel调用原生方法获取开发者模式状态
        const platform = MethodChannel('com.example/riskcontrol');
        bool isDeveloperMode = await platform.invokeMethod(
          'isDeveloperModeEnabled',
        );
        Utils.logError("是否开启开发者模式：$isDeveloperMode");
        print("是否开启开发者模式：$isDeveloperMode");

        EasyLoading.show(status: "是否开启开发者模式：$isDeveloperMode");
        if (isDeveloperMode) {
          CuToast.error(msg: "请关闭开发者模式后再重新打开本程序");
          await Future.delayed(const Duration(seconds: 2));
          SystemNavigator.pop();
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
      print("是否为云机：$isCloud");
      EasyLoading.show(status: "是否为云机：$isCloud");
      if (isCloud) {
        CuToast.error(msg: "不允许在云机上运行");
        await Future.delayed(const Duration(seconds: 2));
        SystemNavigator.pop();
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
      const platform = MethodChannel('com.example/riskcontrol');
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
          !isDebug &&
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
        if (isDebug) {
          CuToast.error(msg: "不允许在调试模式下运行");
        } else if (isVpn) {
          CuToast.error(msg: "请关闭VPN后再重新打开本程序");
        } else if (!hasSim) {
          CuToast.error(msg: "请插入SIM卡后再重新打开本程序");
        } else if (isDev) {
          CuToast.error(msg: "不允许在开发者模式下运行");
        } else if (isEmu) {
          CuToast.error(msg: "不允许在模拟器上运行");
        } else if (isCloud) {
          CuToast.error(msg: "不允许在云机上运行");
        } else if (isAccess) {
          CuToast.error(msg: "请关闭无障碍模式后再重新打开本程序");
        } else if (enabledServices.isNotEmpty) {
          CuToast.error(msg: "请关闭无障碍软件后再重新打开本程序");
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
