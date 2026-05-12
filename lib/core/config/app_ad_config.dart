import 'package:get/get.dart';

class AppAdConfig extends GetxController {
  static AppAdConfig get instance => Get.find();
  static const String appidStr = 'a6a02edc510688';
  static const String appidkeyStr = 'a9dfbeb796a19b7695dbc0d563734d86a';

  /// 开屏 id
  static const String splashID = 'b69fad6b5bdcfd';
  static const String splashSceneID = 'b69fad6b5bdcfd';

  /// 横幅 id
  static const String bannerPlacementID = 'b6a02ee1db6f26';
  static const String bannerSceneID = 'b6a02ee1db6f26';

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
