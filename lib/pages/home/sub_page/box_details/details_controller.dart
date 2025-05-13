import 'package:base_object/pages/home/home_controller.dart';
import 'package:get/get.dart';

class DetailController extends GetxController {
  // 获取首页控制器的数据
  int get homeCount => Get.find<HomeController>().count.value;
}