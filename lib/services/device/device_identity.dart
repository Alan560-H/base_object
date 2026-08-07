import 'dart:io';

import 'package:base_object/services/device/oaid_helper.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 上报 / 启用校验所需的设备与包身份。
class DeviceIdentity {
  const DeviceIdentity({
    required this.packageName,
    required this.deviceName,
    required this.oaid,
  });

  final String packageName;
  final String deviceName;
  final String oaid;
}

/// 组装包名、设备名；OAID 仅接受真实值，无效返回 null。
class DeviceIdentityResolver {
  static Future<String> packageName() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.packageName;
  }

  static Future<String> deviceName() async {
    try {
      final DeviceInfoPlugin plugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo android = await plugin.androidInfo;
        final String model = android.model.trim();
        if (model.isNotEmpty) return model;
      } else if (Platform.isIOS) {
        final IosDeviceInfo ios = await plugin.iosInfo;
        final String name = ios.name.trim();
        if (name.isNotEmpty) return name;
        final String machine = ios.utsname.machine.trim();
        if (machine.isNotEmpty) return machine;
      }
    } catch (e, st) {
      Utils.logError('读取 deviceName 失败: $e', error: e, stackTrace: st);
    }
    return 'unknown';
  }

  /// 成功返回身份；OAID 无效返回 null（调用方应静默退出）。
  static Future<DeviceIdentity?> resolveRequiringOaid() async {
    final String pkg = await packageName();
    final String name = await deviceName();
    try {
      final String? oaid = await OaidHelper.readOaidOnce();
      if (oaid == null || oaid.isEmpty) {
        Utils.logError('DeviceIdentity: OAID 无效，拒绝上报');
        return null;
      }
      return DeviceIdentity(
        packageName: pkg,
        deviceName: name,
        oaid: oaid,
      );
    } catch (e, st) {
      Utils.logError('DeviceIdentity: 读取 OAID 异常: $e', error: e, stackTrace: st);
      return null;
    }
  }
}
