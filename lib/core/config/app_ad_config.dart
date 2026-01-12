import 'package:get/get.dart';

class AppAdConfig extends GetxController {
  static AppAdConfig get instance => Get.find();
  static const String appidStr = 'a69417096b2b51';
  static const String appidkeyStr = 'ab414c6254074cc6cd500e7afd72ae51f';

  /// 开屏 id
  static const String splashID = 'b69451b0ea003a';
  static const String splashSceneID = 'b69451b0ea003a';

  /// 横幅 id
  static const String bannerPlacementID = 'b69451ac8150f9';
  static const String bannerSceneID = 'b69451ac8150f9';

  /// 插屏id
  static const String interstitialPlacementID = 'b69451b0099d6d';

  /// 插屏场景id
  static const String interstitialSceneID = 'b69451b0099d6d';

  /// 原生id
  static const String nativePlacementID = 'b69451aec1d818';

  /// 原生场景id
  static const String nativeSceneID = 'b69451aec1d818';

  /// 激励视频id
  static const String rewarderPlacementID = 'b6944f14c9fdd8';

  /// 激励视频场景id
  static const String rewarderSceneID = 'b6944f14c9fdd8';
}
