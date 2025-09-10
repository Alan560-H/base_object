import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/FormModel/withdrawal/WithdrawalForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class UserPayListController extends GetxController {
  RxString appbarTitle = "用户支付列表".obs;
  RxList<UserPayLModel> userPayLModelList = <UserPayLModel>[].obs;
  Future<void> getRemoveBindPay(UserPayLModel userPayLModel) async {
    try {
      EasyLoading.show();
      WithdrawalForm withdrawalForm = WithdrawalForm();
      withdrawalForm.id = userPayLModel.id;
      withdrawalForm.channelPackage =
          Store.instance.getAppUpLoadModel.channelPackage;
      BackModel backModel = await Api.to.getRemoveBindPay(withdrawalForm);
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: backModel.data);
        getPayList();
      }
    } catch (e) {
      Utils.logError("删除失败$e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// 获取支付列表
  Future<void> getPayList() async {
    try {
      EasyLoading.show();
      FormModel formModel = FormModel();
      formModel.channelPackage =
          Store.instance.getAppUpLoadModel.channelPackage;
      userPayLModelList.value = await Api.to.getPayList(formModel);
      Utils.logError("长度${userPayLModelList.length}");
    } catch (e) {
      Utils.logError("获取支付列表失败$e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void onInit() async {
    getPayList();
    super.onInit();
  }
}
