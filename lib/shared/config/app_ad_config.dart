/// Taku 应用凭据与广告位 ID（须与开发者后台一致，修改后真机回归）
class AppAdConfig {
  AppAdConfig._();

  /// Taku 应用 ID（[InitTool.initTopon]）
  static const String appidStr = 'a6a02edc510688';

  /// Taku App Key
  static const String appidkeyStr = 'a9dfbeb796a19b7695dbc0d563734d86a';

  /// 横幅广告位
  static const String bannerPlacementID = 'b6a02ee1db6f26';

  /// 原生信息流广告位（[NativeTool]）
  static const String nativePlacementID = 'b6a033299c2230';

  /// 信息流场景 ID（与 placement 一致，供 entryNativeScenario / PlatformNativeWidget）
  static const String nativeSceneID = nativePlacementID;

  /// 激励视频广告位
  static const String rewarderPlacementID = 'b69fad67a43bb4';
}
