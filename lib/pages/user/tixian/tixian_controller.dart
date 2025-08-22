import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/FormModel/withdrawal/WithdrawalForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/userModel/WithdrawalModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class TixianController extends GetxController {
  RxString appbarTitle = "提现界面".obs;
  UserInfo userInfo = Get.find<UserInfo>();
  BannerTool bannerTool = Get.find<BannerTool>();

  RxList<WithdrawalModel> withdrawalList = <WithdrawalModel>[].obs;
  Rx<WithdrawalModel> selectedWithdrawalModel = WithdrawalModel().obs;
  Rx<WithdrawalForm> withdrawalForm = WithdrawalForm().obs;
  /// 密码控制器
  final nameController = TextEditingController();
  /// 账号控制器
  final accountController = TextEditingController();
  Future<void> submitForm()async{
    try{
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
      EasyLoading.show(status: "提现进行中...");
      Utils.logError(withdrawalForm.toJson());
      BackModel backModel = await Api().getWithdrawalMoney(withdrawalForm.value);
      if(backModel.code==CuErrorConfig.success){
        CuToast.success(msg: "提现成功");
        nameController.clear();
        accountController.clear();
        withdrawalForm.value.payName = "";
        withdrawalForm.value.payAccount = "";
      }
    }catch(e){
      Utils.logError("提现提交出错: $e");
    }finally{
      EasyLoading.dismiss();
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
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    Utils.logError("提现界面onClose");
    super.onClose();
  }
  @override
  void onInit() {
    Utils.logError("提现界面初始化");
    // TODO: implement onInit
    bannerTool.hideBannerAd();
    getWithdrawalList();
    super.onInit();
  }
}
