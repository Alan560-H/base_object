/// Taku 应用凭据与广告位 ID（须与开发者后台一致，修改后真机回归）
class AppAdConfig {
  AppAdConfig._();

  /// Taku 应用 ID（[InitTool.initTopon]）
  static const String appidStr = 'a6a3bdafad0763';

  /// Taku App Key
  static const String appidkeyStr = 'aae845a3b9c714a789ff6f491dbbdf0a6';

  /// 横幅广告位
  static const String bannerPlacementID = 'b6a3e7cccd4ba1';

  /// 原生信息流广告位（[NativeTool]）
  static const String nativePlacementID = 'b6a06907ae251e';

  /// 信息流场景 ID（与 placement 一致，供 entryNativeScenario / PlatformNativeWidget）
  static const String nativeSceneID = nativePlacementID;

  /// 激励视频广告位
  static const String rewarderPlacementID = 'b6a3b7682af958';
}
