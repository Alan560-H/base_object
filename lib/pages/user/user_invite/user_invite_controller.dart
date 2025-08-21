import 'package:base_object/core/api/api.dart';
import 'package:base_object/models/backModel/userModel/UserInviteCountModel.dart';
import 'package:base_object/models/backModel/userModel/UserInviteModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class UserInviteController extends GetxController {
  RxString appbarTitle = "邀请好友".obs;

  /// 邀请信息
  Rx<UserInviteCountModel> userInviteCountModel = UserInviteCountModel().obs;
  /// 用户邀请任务
  RxList<UserInviteModel> userInviteModelList = <UserInviteModel>[].obs;
  /// 用户邀请任务
  Future<void> getInviteList() async {
    try{
      EasyLoading.show(status: "加载中...");
      userInviteModelList.value = await Api.to.getInviteList();
      Utils.logError("任务列表${userInviteModelList.length}");
    }catch(e){
      Utils.logError("获取邀请任务失败$e");
    }finally{
      EasyLoading.dismiss();
    }
  }
  /// 用户邀请信息
  Future<void> getInviteInfo() async {
    try{
      EasyLoading.show(status: "加载中...");
      userInviteCountModel.value = await Api.to.getInviteInfo();
      Utils.logError("信息${userInviteCountModel.toJson()}");
    }catch(e){
      Utils.logError("获取邀请信息失败$e");
    }finally{
      EasyLoading.dismiss();
    }
  }
  @override
  void onReady() {
    // TODO: implement onReady‘
    Utils.logError("邀请好友界面onReady");
    super.onReady();
  }
  @override
  void onClose() {
    // TODO: implement onClose
    Utils.logError("邀请好友界面onClose");
    super.onClose();
  }
  @override
  void onInit() {
    getInviteList();
    getInviteInfo();
    Utils.logError("邀请好友界面初始化");
    // TODO: implement onInit
    super.onInit();
  }
}
