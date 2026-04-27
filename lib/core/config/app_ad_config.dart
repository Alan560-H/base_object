import 'package:get/get.dart';

class AppAdConfig extends GetxController {
  static AppAdConfig get instance => Get.find();
  static const String appidStr = 'a69eb16d37c0df';
  static const String appidkeyStr = 'af882731d2a7e4a4ebecbec601032924f';

  /// 开屏 id
  static const String splashID = 'b69451b0ea003a';
  static const String splashSceneID = 'b69451b0ea003a';

  /// 横幅 id
  static const String bannerPlacementID = 'b69eb1b699cf6b';
  static const String bannerSceneID = 'b69eb1b699cf6b';

  /// 插屏id
  static const String interstitialPlacementID = 'b69451b0099d6d';

  /// 插屏场景id
  static const String interstitialSceneID = 'b69451b0099d6d';

  /// 原生id
  static const String nativePlacementID = 'b69451aec1d818';

  /// 原生场景id
  static const String nativeSceneID = 'b69451aec1d818';

  /// 激励视频id
  static const String rewarderPlacementID = 'b69de3944747ca';

  /// 激励视频场景id
  static const String rewarderSceneID = 'b69de3944747ca';
}
