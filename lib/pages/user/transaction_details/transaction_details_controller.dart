import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/backModel/userModel/UserAmountListModel.dart';
import 'package:base_object/models/backModel/userModel/UserWithdrawalModel.dart';
import 'package:base_object/models/localModels/BoxCategory.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class TransactionDetailsController extends GetxController {
  RxString appbarTitle = "收支明细".obs;
  final BannerTool bannerTool = Get.find<BannerTool>();
  // 收入表
  final RxList<UserAmountListModel> userAmountListModelList = <UserAmountListModel>[].obs;
  // 提现表
  final RxList<UserWithdrawalModel> userWithdrawalModelList = <UserWithdrawalModel>[].obs;
  /// 饰品分类列表
  List<BoxCategory> userBagNavs = [
    BoxCategory(id: 0, categoryName: "收入"),
    BoxCategory(id: 1, categoryName: "提现"),
  ];
  RxInt currentIndex = 0.obs;
  void tabChange(i) {
    currentIndex.value = i;
    if (i == 0) {
      getUserAmountList();
    } else {
      getWithdrawalOrderList();
    }
  }
  // 获取收入表
  Future<void> getUserAmountList() async {
    try{
      userAmountListModelList.clear();
      userAmountListModelList.value = await Api.to.getUserAmountList();
    }catch(e){
      Utils.logError("收入明细表报错：$e");
    }
  }
  // 获取提现表
  Future<void> getWithdrawalOrderList() async {
    try{
      userWithdrawalModelList.clear();
      userWithdrawalModelList.value = await Api.to.getWithdrawalOrderList();
    }catch(e){
      Utils.logError("收入明细表报错：$e");
    }
  }
  void onBackPressed(){
    Get.back();
  }
  @override
  void onInit() {
    getUserAmountList();
    super.onInit();
  }
}
