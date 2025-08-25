import 'package:get/get.dart';

class AppAdConfig extends GetxController{
  static AppAdConfig get instance => Get.find();
  static const String appidStr = 'a689c533c67b04';
  static const String appidkeyStr = 'a724012c3ed03c72db567173ba652c312';
  /// 开屏 id
  static const String splashID = 'b689daec72b9c7';
  static const String splashSceneID = 'b689daec72b9c7';
  /// 横幅 id
  static const String bannerPlacementID = 'b68a434ddd85eb';
  static const String bannerSceneID = 'b68a434ddd85eb';
  /// 插屏id
  static const String interstitialPlacementID = 'b68a434de767f3';
  /// 插屏场景id
  static const String interstitialSceneID = 'b68a434de767f3';
  /// 原生id
  static const String nativePlacementID = 'b68a434dd3882c';
  /// 原生场景id
  static const String nativeSceneID = 'b68a434dd3882c';
  /// 激励视频id
  static const String rewarderPlacementID = 'b689c53eae2be5';
  /// 激励视频场景id
  static const String rewarderSceneID = 'b689c53eae2be5';
}