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

/// 组装包名、设备名与 OAID；读不到 OAID 时按未知设备传 `unkown`。
class DeviceIdentityResolver {
  /// 无法获取真实 OAID 时的占位值（未知设备统计）。
  static const String unknownOaid = 'unkown';

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

  /// 始终返回身份；OAID 无效或异常时 [DeviceIdentity.oaid] 为 [unknownOaid]。
  static Future<DeviceIdentity> resolve() async {
    final String pkg = await packageName();
    final String name = await deviceName();
    try {
      final String? oaid = await OaidHelper.readOaidOnce();
      if (oaid == null || oaid.isEmpty) {
        Utils.logError('DeviceIdentity: OAID 无效，按未知设备上报');
        return DeviceIdentity(
          packageName: pkg,
          deviceName: name,
          oaid: unknownOaid,
        );
      }
      return DeviceIdentity(
        packageName: pkg,
        deviceName: name,
        oaid: oaid,
      );
    } catch (e, st) {
      Utils.logError('DeviceIdentity: 读取 OAID 异常: $e', error: e, stackTrace: st);
      return DeviceIdentity(
        packageName: pkg,
        deviceName: name,
        oaid: unknownOaid,
      );
    }
  }
}
