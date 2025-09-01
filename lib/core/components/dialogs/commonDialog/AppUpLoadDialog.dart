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
    try{
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

        Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();
        Utils.logError('权限请求状态: $statuses');
        if (statuses.values.any((status) => status != PermissionStatus.granted)) {
          throw Exception('权限不足，无法下载或安装应用');
        }
      }
    }catch(e){
      Utils.logError(e);
    }
  }
  /// 服务协议和隐私协议
  Widget checkedUpApp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
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
          child: Text("一天内不在弹出"),
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
      if (result.type == ResultType.done) {
        Utils.logError('APK installation started');
      } else {
        Utils.logError('Failed to start APK installation: ${result.message}');
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

    return '${directory?.path}/cjbao.apk';
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
              Store.instance.getAppUpLoadModel.must=="1"?Text("您必须更新才可以继续使用该 app"):Text("app有更新，你可以更新应用以获得更好得体验"),
              checkedUpApp()
            ],
          ),
        ),
        if (isDownloading)
          LinearProgressIndicator(value: progress / 100)
        else if (progress > 0)
          Text('Download Progress: ${progress.toStringAsFixed(2)}%'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.w,
          children: [
            Store.instance.getAppUpLoadModel.must!="1"? CuButton(
              height: 40.h,
              width: 100.w,
              text: "取消",
              onPressed: () async {
                // 在这里设置时间戳。
               if(isChecked){
                 await LocalStorage.setString("isUpApp",Jiffy.now().format());
               }
                Get.back();
              },
              radius: 20.r,
              bgColor: TextConfig.grey,
            ):Container(),
            CuButton(
              height: 40.h,
              width: 100.w,
              text: "下载",
              radius: 20.r,
              onPressed: isDownloading ? null : downloadAPK,
              bgColor: TextConfig.primary,
            ),
          ],
        )
      ],
    );
  }
}