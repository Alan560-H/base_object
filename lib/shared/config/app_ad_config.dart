/// Taku 应用凭据与广告位 ID（须与开发者后台一致，修改后真机回归）
class AppAdConfig {
  AppAdConfig._();

  /// Taku 应用 ID（[InitTool.initTopon]）
  static const String appidStr = 'a6a0d60edb9321';

  /// Taku App Key
  static const String appidkeyStr = 'a7fac837f14cfaf4f8b761418f7faa2c3';

  /// 横幅广告位
  static const String bannerPlacementID = 'b6a0d615e4ed64';

  /// 原生信息流广告位（[NativeTool]）
  static const String nativePlacementID = 'b6a0d61722f617';

  /// 信息流场景 ID（与 placement 一致，供 entryNativeScenario / PlatformNativeWidget）
  static const String nativeSceneID = nativePlacementID;

  /// 激励视频广告位
  static const String rewarderPlacementID = 'b6a41e32ebd6be';
}
