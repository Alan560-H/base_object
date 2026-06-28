/// Taku 应用凭据与广告位 ID（须与开发者后台一致，修改后真机回归）
class AppAdConfig {
  AppAdConfig._();

  /// Taku 应用 ID（[InitTool.initTopon]）
  static const String appidStr = 'a68ada29a8380c';

  /// Taku App Key
  static const String appidkeyStr = 'a18899a8b8b91ea35ba2138f06d22d980';

  /// 横幅广告位
  static const String bannerPlacementID = 'b69de35953c985';

  /// 原生信息流广告位（[NativeTool]）
  static const String nativePlacementID = 'b6a06907ae251e';

  /// 信息流场景 ID（与 placement 一致，供 entryNativeScenario / PlatformNativeWidget）
  static const String nativeSceneID = nativePlacementID;

  /// 激励视频广告位
  static const String rewarderPlacementID = 'b6a3b7682af958';
}
