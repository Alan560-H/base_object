import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ShortVideoController extends GetxController {
  RxString appbarTitle = "短视频页面标题".obs;
  Future _pangrowthInit() async {
    final status = await Permission.phone.request();
    print("phone 权限状态 $status");
    // 这里的appid  和logappid 填写穿山甲的sdkjson文件李的值
    await PangrowthVideo.registerVideo(
      appName: "",
      andoridAppId: "5670418",
      appLogAppId :"751081",
      iosAppId: "",
      debug: true,
    );
  }

  @override
  void onReady() {
    // TODO: implement onReady‘
    Utils.logError("短视频页面onReady");
    super.onReady();
  }
  @override
  void onClose() {
    // TODO: implement onClose
    Utils.logError("短视频页面onClose");
    super.onClose();
  }
  @override
  void onInit() async {
    Utils.logError("短视频页面初始化");
    ///同意隐私政策之后调用
    await _pangrowthInit();
    super.onInit();
  }
}
