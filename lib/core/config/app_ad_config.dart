import 'package:get/get.dart';

class AppAdConfig extends GetxController {
  static AppAdConfig get instance => Get.find();
  static const String appidStr = 'a69fad92ad270e';
  static const String appidkeyStr = 'af3fa273f0ee087bbebcc37fa43249660';

  /// 开屏 id
  static const String splashID = 'b69fc5b4a7b868';
  static const String splashSceneID = 'b69fc5b4a7b868';

  /// 横幅 id
  static const String bannerPlacementID = 'b69fc5b2462299';
  static const String bannerSceneID = 'b69fc5b2462299';

  /// 插屏id
  static const String interstitialPlacementID = 'b69fc5b3904ed1';

  /// 插屏场景id
  static const String interstitialSceneID = 'b69fc5b3904ed1';

  /// 原生id
  static const String nativePlacementID = 'b69fc5af196537';

  /// 原生场景id
  static const String nativeSceneID = 'b69fc5af196537';

  /// 激励视频id
  static const String rewarderPlacementID = 'b69fc5b0f90830';

  /// 激励视频场景id
  static const String rewarderSceneID = 'b69fc5b0f90830';
}
