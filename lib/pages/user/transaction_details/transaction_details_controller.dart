import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/backModel/userModel/UserAmountListModel.dart';
import 'package:base_object/models/backModel/userModel/UserWithdrawalModel.dart';
import 'package:base_object/models/localModels/BoxCategory.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class TransactionDetailsController extends GetxController {
  RxString appbarTitle = "收支明细".obs;
  // 收入表
  final RxList<UserAmountListModel> userAmountListModelList = <UserAmountListModel>[].obs;
  // 提现表
  final RxList<UserWithdrawalModel> userWithdrawalModelList = <UserWithdrawalModel>[].obs;
  BannerTool bannerTool = Get.find<BannerTool>();
  /// 来源
  Map<int,String> sourceFn = {
    1:"广告收益",
    2:"新人福利",
    3:"邀请人福利",
    4:"提现扣币",
    5:"平台奖励"
  };
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
    Utils.logError("收支明细页面oninit");
    bannerTool.hideBannerAd();
    getUserAmountList();
    super.onInit();
  }
  @override
  void onReady() {
    Utils.logError("收支明细页面onready");
    // TODO: implement onReady
    super.onReady();
  }
  @override
  void onClose() {
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    Utils.logError("收支明细页面onClose");
    super.onClose();
  }
}
