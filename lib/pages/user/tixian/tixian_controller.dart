import 'package:base_object/core/api/api.dart';
import 'package:base_object/models/backModel/userModel/UserInviteCountModel.dart';
import 'package:base_object/models/backModel/userModel/UserInviteModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class TixianController extends GetxController {
  RxString appbarTitle = "提现界面".obs;

  @override
  void onReady() {
    // TODO: implement onReady‘
    Utils.logError("提现界面onReady");
    super.onReady();
  }
  @override
  void onClose() {
    // TODO: implement onClose
    Utils.logError("提现界面onClose");
    super.onClose();
  }
  @override
  void onInit() {
    Utils.logError("提现界面初始化");
    // TODO: implement onInit
    super.onInit();
  }
}
