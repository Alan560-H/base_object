import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/FormModel/withdrawal/WithdrawalForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:base_object/models/backModel/userModel/WithdrawalModel.dart';
import 'package:base_object/store/store.dart';
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
  Future<void> submitForm() async {
    try {
      if (withdrawalForm.value.userPayAccountId == null) {
        CuToast.error(msg: "请选择提现方式");
        return;
      }
      EasyLoading.show(status: "提现进行中...");
      Utils.logError(withdrawalForm.toJson());
      BackModel backModel = await Api().getWithdrawalMoney(
        withdrawalForm.value,
      );
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: backModel.msg);
        nameController.clear();
        accountController.clear();
        withdrawalForm.value.payName = "";
        withdrawalForm.value.payAccount = "";
        await UserInfo.instance.getUserInfoFn();
      }
    } catch (e) {
      Utils.logError("提现提交出错: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// 提现列表
  Future<void> getWithdrawalList() async {
    try {
      EasyLoading.show(status: "加载中...");
      withdrawalList.value = await Api().getWithdrawalList();
      if (withdrawalList.isNotEmpty) {
        withdrawalForm.value.amountId = withdrawalList[0].id;
        selectedWithdrawalModel.value = withdrawalList[0];
      }
      Utils.logError("提现可选列表：￥${withdrawalList.toJson()}");
    } catch (e) {
      Utils.logError("getWithdrawalList: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  RxList<UserPayLModel> userPayLModelList = <UserPayLModel>[].obs;
  Rx<UserPayLModel> selectPay = UserPayLModel().obs;

  /// 获取支付列表
  Future<void> getPayList() async {
    try {
      EasyLoading.show();
      FormModel formModel = FormModel();
      formModel.channelPackage =
          Store.instance.getAppUpLoadModel.channelPackage;
      userPayLModelList.value = await Api.to.getPayList(formModel);
      if (userPayLModelList.isNotEmpty) {
        selectPay.value = userPayLModelList[0];
        withdrawalForm.value.userPayAccountId = selectPay.value.id;
      }
      Utils.logError("长度${userPayLModelList.length}");
    } catch (e) {
      Utils.logError("获取支付列表失败$e");
    } finally {
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
    BannerTool.to.removeBannerAd();
    // TODO: implement onClose
    Utils.logError("提现界面onClose");
    super.onClose();
  }

  @override
  void onInit() {
    Utils.logError("提现界面初始化");

    withdrawalForm.value.channelPackage =
        Store.instance.getAppUpLoadModel.channelPackage;
    BannerTool.to.hideBannerAd();
    getWithdrawalList();
    getPayList();
    super.onInit();
  }
}
