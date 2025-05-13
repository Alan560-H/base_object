import 'package:get/get.dart';

class Store extends GetxController{
  /// 获取单例
  static Store get instance => Get.find();
  final RxInt _currentIndex = 0.obs;
  void changeIndex(int index){
    _currentIndex.value = index;
  }
}