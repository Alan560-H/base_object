/// Taku 应用凭据与广告位 ID（须与开发者后台一致，修改后真机回归）
class AppAdConfig {
  AppAdConfig._();

  /// Taku 应用 ID（[InitTool.initTopon]）
  static const String appidStr = 'a6a41ebaf25f02';

  /// Taku App Key
  static const String appidkeyStr = 'af93b3beee86d27e9d694c95d0edf1a65';

  /// 横幅广告位
  static const String bannerPlacementID = 'b6a41ed3f36751';

  /// 原生信息流广告位（[NativeTool]）
  static const String nativePlacementID = 'b6a41fc69d8129';

  /// 信息流场景 ID（与 placement 一致，供 entryNativeScenario / PlatformNativeWidget）
  static const String nativeSceneID = nativePlacementID;

  /// 激励视频广告位
  static const String rewarderPlacementID = 'b6a41fc59ac6d0';
}
