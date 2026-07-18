/// Taku 应用凭据与广告位 ID（须与开发者后台一致，修改后真机回归）
class AppAdConfig {
  AppAdConfig._();

  /// Taku 应用 ID（[InitTool.initTopon]）
  static const String appidStr = 'a6a5744ab0cfaf';

  /// Taku App Key
  static const String appidkeyStr = 'ac13bfaf1c77a9374d928c2881aad64e9';

  /// 横幅广告位
  static const String bannerPlacementID = 'b6a5749ca17b7a';

  /// 原生信息流广告位（[NativeTool]）
  static const String nativePlacementID = 'b6a5749de978c4';

  /// 信息流场景 ID（与 placement 一致，供 entryNativeScenario / PlatformNativeWidget）
  static const String nativeSceneID = nativePlacementID;

  /// 激励视频广告位
  static const String rewarderPlacementID = 'b6a58a3db336c6';
}
