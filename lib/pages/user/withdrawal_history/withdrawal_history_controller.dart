import 'package:base_object/core/api/api.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/backModel/userModel/UserWithdrawalModel.dart';
import 'package:base_object/pages/user/user_bag/user_bag_controller.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class WithdrawalHistoryController extends GetxController {
  RxString appbarTitle = "提现记录".obs;
  UserBagController userBagController = Get.find<UserBagController>();
  BannerTool bannerTool = Get.find<BannerTool>();

  // 提现表
  final RxList<UserWithdrawalModel> userWithdrawalModelList = <UserWithdrawalModel>[].obs;
  // 获取提现表
  Future<void> getWithdrawalOrderList() async {
    try{
      userWithdrawalModelList.clear();
      userWithdrawalModelList.value = await Api.to.getWithdrawalOrderList();
    }catch(e){
      Utils.logError("提现记录报错：$e");
    }
  }
  @override
  void onInit() {
    Utils.logError("提现记录页面初始化");
    bannerTool.hideBannerAd();
    getWithdrawalOrderList();
    // TODO: implement onInit
    super.onInit();
  }
  @override
  void onClose() {
    Utils.logError("关闭页面");
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    super.onClose();
  }
}
