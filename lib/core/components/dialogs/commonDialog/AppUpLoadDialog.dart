import 'dart:io';

import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

///指数盲盒下注确认框
class AppUpLoadDialog extends StatefulWidget {
  final AppUpLoadModel appUpLoadModel;

  /// 指数盲盒下注确认框
  const AppUpLoadDialog({super.key, required this.appUpLoadModel});

  @override
  State<AppUpLoadDialog> createState() => _AppUpLoadDialogState();
}

class _AppUpLoadDialogState extends State<AppUpLoadDialog> {
  double progress = 0.0;
  bool isDownloading = false;
  // 一天内不再弹出
  bool isChecked = false;

  Future<void> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        List<Permission> permissionsToRequest = [];
        if (sdkInt < 30) {
          permissionsToRequest.add(Permission.storage);
        } else {
          // 对于 Android 11 及以上版本，可根据需求添加其他分区存储权限
          // permissionsToRequest.add(Permission.accessMediaLocation);
          permissionsToRequest.add(Permission.manageExternalStorage);
        }
        permissionsToRequest.add(Permission.requestInstallPackages);

        Map<Permission, PermissionStatus> statuses =
            await permissionsToRequest.request();
        Utils.logError('权限请求状态: $statuses');
        if (statuses.values.any(
          (status) => status != PermissionStatus.granted,
        )) {
          throw Exception('权限不足，无法下载或安装应用');
        }
      }
    } catch (e) {
      Utils.logError(e);
    }
  }

  /// 服务协议和隐私协议
  Widget checkedUpApp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          side: BorderSide(
            color: Colors.white, // 边框颜色
            width: 1.w, // 边框粗细（用 ScreenUtil 适配）
            style: BorderStyle.solid,
          ),
          checkColor: Colors.white,
          activeColor: TextConfig.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
        ),
        InkWell(
          onTap: () {
            setState(() {
              isChecked = !isChecked;
            });
          },
          child: Text("一天内不在弹出", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> downloadAPK() async {
    try {
      await requestPermissions();

      String url = widget.appUpLoadModel.downUrl;
      String savePath = await getSavePath();
      Utils.logError("保存地址：$savePath");
      File oldApkFile = File(savePath);
      // 1. 检查旧文件是否存在
      if (oldApkFile.existsSync()) {
        Utils.logError('发现旧APK文件，开始清理');
        try {
          // 2. 尝试删除旧文件
          await oldApkFile.delete();
          Utils.logError('旧APK文件清理成功');
        } catch (deleteE) {
          // 3. 若删除失败（如文件被占用），抛出异常终止下载（避免新文件覆盖失败）
          Utils.logError('旧APK文件清理失败：$deleteE');
          throw Exception('旧安装包删除失败，请关闭占用该文件的程序后重试');
        }
      }
      // 检查文件是否已存在
      File file = File(savePath);
      if (file.existsSync()) {
        Utils.logError('文件已存在，跳过下载');
        await installAPK(savePath);
        return;
      }

      setState(() {
        isDownloading = true;
      });
      Dio dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = (received / total) * 100;
            });
          }
        },
      );
      Utils.logError('APK downloaded successfully to $savePath');
      await installAPK(savePath);
    } catch (e) {
      Utils.logError('Error downloading APK: $e');
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> installAPK(String filePath) async {
    if (Platform.isAndroid) {
      // 打开 APK 文件进行安装
      OpenResult result = await OpenFile.open(filePath);
      // 安装完成后删除文件
      if (result.type == ResultType.done) {
        // 延迟30秒删除APK（时间可根据测试调整，建议20-60秒）
        Future.delayed(const Duration(seconds: 30), () async {
          try {
            File apkFile = File(filePath);
            if (apkFile.existsSync()) {
              // 先判断文件是否还存在
              await apkFile.delete();
              Get.snackbar(
                '清理完成',
                '安装包已自动删除',
                duration: const Duration(seconds: 2),
              );
            }
          } catch (e) {
            Get.snackbar(
              '清理失败',
              '请手动删除安装包',
              duration: const Duration(seconds: 2),
            );
            Utils.logError('删除APK失败：$e');
          }
        });
      } else {
        Get.snackbar('安装失败', '无法打开安装包', duration: const Duration(seconds: 2));
      }
    } else if (Platform.isIOS) {
      // 引导用户到 App Store 进行更新
      Utils.logError('请前往 App Store 更新应用');
    }
  }

  Future<String> getSavePath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    return '${directory?.path}/ruyimh.apk';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10.w,
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 100.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Store.instance.getAppUpLoadModel.must == "1"
                  ? Text(
                    "您必须更新才可以继续使用该 app",
                    style: TextStyle(color: Colors.white),
                  )
                  : Text(
                    "app有更新，你可以更新应用以获得更好得体验",
                    style: TextStyle(color: Colors.white),
                  ),
              checkedUpApp(),
            ],
          ),
        ),
        if (isDownloading)
          LinearProgressIndicator(
            value: progress / 100,
            // 设置进度条颜色
            valueColor: AlwaysStoppedAnimation<Color>(TextConfig.primary),
            // 可选：设置进度条背景颜色
            backgroundColor: Colors.grey[200],
          )
        else if (progress > 0)
          Text('下载进度: ${progress.toStringAsFixed(2)}%'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.w,
          children: [
            Store.instance.getAppUpLoadModel.must != "1"
                ? CuButton(
                  height: 40.h,
                  width: 100.w,
                  text: "取消",
                  onPressed: () async {
                    // 在这里设置时间戳。
                    if (isChecked) {
                      await LocalStorage.setString(
                        "isUpApp",
                        Jiffy.now().format(),
                      );
                    }
                    Get.back();
                  },
                  radius: 20.r,
                  textColor: TextConfig.black333,
                  bgColor: TextConfig.comPageGrey,
                )
                : Container(),
            CuButton(
              height: 40.h,
              width: 100.w,
              text: "下载",
              radius: 20.r,
              onPressed: isDownloading ? null : downloadAPK,
              bgColor: TextConfig.primary,
            ),
          ],
        ),
      ],
    );
  }
}
