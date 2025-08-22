import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/localModels/BannerVo.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class InviteUserController extends GetxController {
  RxString appbarTitle = "邀请好友页面标题".obs;
  BannerTool bannerTool = Get.find<BannerTool>();
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
  // final List<BannerVo> swipers = [
  //   BannerVo(imageUrl: ImageConfig.banner8, id: 0),
  //   BannerVo(imageUrl: ImageConfig.banner9, id: 1),
  //   BannerVo(imageUrl: ImageConfig.banner10, id: 2),
  // ];
}
