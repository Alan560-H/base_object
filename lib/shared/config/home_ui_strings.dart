/// 首页广告相关用户可见文案（信息流、横幅按钮与槽位占位）
abstract final class HomeUiStrings {
  static const startBannerAd = '开始横幅广告';
  static const stopBannerAd = '停止广告';
  static const startNativeFeed = '开始信息流';
  static const stopNativeFeed = '停止信息流';
  static const loadingEllipsis = '加载中…';

  static const nativeTapToLoad = '点击开始信息流加载广告';
  static const nativeLoading = '信息流加载中…';
  static const nativeFailed = '暂无广告或加载失败';
  static const nativeReady = '广告已就绪，正在展示…';
  static const nativeAndroidOnly = '信息流广告仅支持 Android';

  static String stopNativeFeedWaiting(int elapsedSeconds) =>
      '$stopNativeFeed（等待${elapsedSeconds}s）';
}
