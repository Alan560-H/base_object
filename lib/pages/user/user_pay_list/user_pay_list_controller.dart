import 'package:base_object/core/api/api.dart';
import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class UserPayListController extends GetxController {
  RxString appbarTitle = "用户支付列表".obs;
  RxList<UserPayLModel> userPayLModelList = <UserPayLModel>[].obs;

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
