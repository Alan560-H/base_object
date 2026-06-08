import 'package:get/get.dart';

class AppAdConfig extends GetxController {
  static AppAdConfig get instance => Get.find();
  static const String appidStr = 'a6a215f2307e69';
  static const String appidkeyStr = 'ac714f851f5c582e1a56c6de3b7647115';

  /// 开屏 id
  static const String splashID = 'b69fad6b5bdcfd';
  static const String splashSceneID = 'b69fad6b5bdcfd';

  /// 横幅 id
  static const String bannerPlacementID = 'b6a21602267f7f';
  static const String bannerSceneID = 'b6a21602267f7f';

  /// 插屏id
  static const String interstitialPlacementID = 'b69fad6a45d07a';

  /// 插屏场景id
  static const String interstitialSceneID = 'b69fad6a45d07a';

  /// 原生id
  static const String nativePlacementID = 'b69fad6645bd21';

  /// 原生场景id
  static const String nativeSceneID = 'b69fad6645bd21';

  /// 激励视频id
  static const String rewarderPlacementID = 'b69fad67a43bb4';

  /// 激励视频场景id
  static const String rewarderSceneID = 'b69fad67a43bb4';
}
