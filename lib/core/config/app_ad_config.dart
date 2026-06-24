import 'package:get/get.dart';

class AppAdConfig extends GetxController {
  static AppAdConfig get instance => Get.find();
  static const String appidStr = 'a6a2bda1ad01b0';
  static const String appidkeyStr = 'acb9c86f1a0c6e45d7fc0fdbdf593f536';

  /// 横幅 id
  static const String bannerPlacementID = 'b6a2bda6aa050a';
  static const String bannerSceneID = 'b6a2bda6aa050a';

  /// 原生 id（底栏清理用）
  static const String nativePlacementID = 'b6a2bdabf9155f';
  static const String nativeSceneID = 'b6a2bdabf9155f';

  /// 激励视频 id
  static const String rewarderPlacementID = 'b6a3b7682af958';
  static const String rewarderSceneID = 'b6a3b7682af958';
}
