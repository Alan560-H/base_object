import 'package:base_object/manager/banner_tool.dart';
import 'package:get/get.dart';

class TransactionDetailsController extends GetxController {
  RxString appbarTitle = "提现页面标题".obs;
  final BannerTool bannerTool = Get.find<BannerTool>();
  void onBackPressed(){
    Get.back();
  }
  @override
  void onInit() {

    super.onInit();
  }
}
