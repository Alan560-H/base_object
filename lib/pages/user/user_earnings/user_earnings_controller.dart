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
  /// 来源
  Map<int,String> sourceFn = {
    1:"广告收益",
    2:"新人福利",
    3:"邀请人福利",
    4:"提现扣币",
    5:"平台奖励"
  };
  RxInt currentIndex = 0.obs;
  void tabChange(i) {
    currentIndex.value = i;
    if (i == 0) {
      getUserAmountList();
    } else {
      getInviteAmountList();
    }
  }
  // 邀新奖励
  final RxList<UserAmountListModel> inviteAmountNewList = <UserAmountListModel>[].obs;
  // 获取邀新奖励表
  Future<void> getInviteAmountList() async {
    try{
      inviteAmountNewList.clear();
      inviteAmountNewList.value = await Api.to.getInviteAmountList();
    }catch(e){
      Utils.logError("获取邀新奖励表报错：$e");
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
