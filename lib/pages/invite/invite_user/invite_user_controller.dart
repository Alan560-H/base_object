import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/localModels/BannerVo.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class InviteUserController extends GetxController {
  RxString appbarTitle = "邀请好友页面标题".obs;
  final UserInfo userInfo = Get.find<UserInfo>();
  BannerTool bannerTool = Get.find<BannerTool>();
  final RxList<BannerVo> swipers = [
    BannerVo(imageUrl: ImageConfig.inviteBanner1, id: 0),
    BannerVo(imageUrl: ImageConfig.inviteBanner3, id: 1),
  ].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    bannerTool.hideBannerAd();
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
