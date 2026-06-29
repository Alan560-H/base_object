/// Taku 应用凭据与广告位 ID（须与开发者后台一致，修改后真机回归）
class AppAdConfig {
  AppAdConfig._();

  /// Taku 应用 ID（[InitTool.initTopon]）
  static const String appidStr = 'a6a22687ae48d8';

  /// Taku App Key
  static const String appidkeyStr = 'a239a12bb43c91cb8a46ebc6908657e36';

  /// 横幅广告位
  static const String bannerPlacementID = 'b6a22693735479';

  /// 原生信息流广告位（[NativeTool]）
  static const String nativePlacementID = 'b6a2bdabf9155f';

  /// 信息流场景 ID（与 placement 一致，供 entryNativeScenario / PlatformNativeWidget）
  static const String nativeSceneID = nativePlacementID;

  /// 激励视频广告位
  static const String rewarderPlacementID = 'b6a3b7682af958';
}
