import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/models/FormModel/withdrawal/WithdrawalForm.dart';
import 'package:base_object/models/backModel/userModel/UserInviteCountModel.dart';
import 'package:base_object/models/backModel/userModel/UserInviteModel.dart';
import 'package:base_object/models/backModel/userModel/WithdrawalModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class TixianController extends GetxController {
  RxString appbarTitle = "提现界面".obs;
  UserInfo userInfo = Get.find<UserInfo>();
  RxList<WithdrawalModel> withdrawalList = <WithdrawalModel>[].obs;
  Rx<WithdrawalModel> selectedWithdrawalModel = WithdrawalModel().obs;
  Rx<WithdrawalForm> withdrawalForm = WithdrawalForm().obs;
  /// 密码控制器
  final nameController = TextEditingController();
  /// 账号控制器
  final accountController = TextEditingController();
  Future<void> submitForm()async{
    if(withdrawalForm.value.payName.isEmpty){
     CuToast.error(msg: "请输入姓名");
      return;
    }
    if(withdrawalForm.value.payAccount.isEmpty){
      CuToast.error(msg: "请输入账号");
      return;
    }
    if(withdrawalForm.value.amountId==0){
      CuToast.error(msg: "请选择金额");
      return;
    }
  }
  /// 提现列表
  Future<void> getWithdrawalList() async {
    try{
      EasyLoading.show(status: "加载中...");
      withdrawalList.value = await Api().getWithdrawalList();
      if(withdrawalList.isNotEmpty){
        withdrawalForm.value.amountId = withdrawalList[0].id;
        selectedWithdrawalModel.value = withdrawalList[0];
      }
      Utils.logError("提现可选列表：￥${withdrawalList.toJson()}");
    }catch(e){
      Utils.logError("getWithdrawalList: $e");
    }finally{
      EasyLoading.dismiss();
    }
  }
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
    getWithdrawalList();
    super.onInit();
  }
}
