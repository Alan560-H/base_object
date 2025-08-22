import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/backModel/userModel/UserAmountListModel.dart';
import 'package:base_object/models/localModels/BoxCategory.dart';
import 'package:base_object/pages/invite/invite_controller.dart';
import 'package:base_object/pages/user/user_bag/user_bag_controller.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class UserEarningsController extends GetxController {
  RxString appbarTitle = "用户收益".obs;
  BannerTool bannerTool = Get.find<BannerTool>();
  UserBagController userBagController = Get.find<UserBagController>();
  InviteController inviteController = Get.find<InviteController>();
  /// 饰品分类列表
  List<BoxCategory> userBagNavs = [
    BoxCategory(id: 0, categoryName: "日账单"),
    BoxCategory(id: 1, categoryName: "邀新奖励"),
  ];
  RxInt currentIndex = 0.obs;
  void tabChange(i) {
    currentIndex.value = i;
    if (i == 0) {
      getUserAmountList();
    } else {
    }
  }
  // 收入表
  final RxList<UserAmountListModel> userAmountListModelList = <UserAmountListModel>[].obs;
  // 获取收入表
  Future<void> getUserAmountList() async {
    try{
      userAmountListModelList.clear();
      userAmountListModelList.value = await Api.to.getUserAmountList();
    }catch(e){
      Utils.logError("收入明细表报错：$e");
    }
  }
  @override
  void onInit() {
    // TODO: implement onInit
    bannerTool.hideBannerAd();
    getUserAmountList();
    super.onInit();
  }
  @override
  void onClose() {
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    super.onClose();
  }
}
