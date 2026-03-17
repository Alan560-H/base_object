import 'package:base_object/utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // 请求所有必要权限
  static Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetooth,
        ].request();
    // 打印每个权限的状态
    statuses.forEach((permission, status) {
      Utils.logError("权限: $permission, 状态: $status");
    });
    // 检查是否所有权限都已授予
    return statuses.values.every((status) => status.isGranted);
  }

  // 检查单个权限
  static Future<bool> checkPermission(Permission permission) async {
    return await permission.isGranted;
  }
}
