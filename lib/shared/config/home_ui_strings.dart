/// 首页广告相关用户可见文案（信息流、横幅按钮与槽位占位）
abstract final class HomeUiStrings {
  /// 首页信息流槽位与按钮开关。
  static const showHomeNativeFeedUi = true;

  /// 首页激励视频按钮开关。
  static const showHomeRewardedVideoControl = true;

  static const startBannerAd = '开始横幅';
  static const stopBannerAd = '停止广告';
  static const startNativeFeed = '开始信息流';
  static const stopNativeFeed = '停止信息流';
  static const loadingEllipsis = '加载中…';

  static const nativeTapToLoad = '点击开始信息流加载广告';
  static const nativeLoading = '信息流加载中…';
  static const nativeFailed = '暂无广告或加载失败';
  static const nativeNoFill = '暂无广告填充';
  static const nativeReady = '广告已就绪，正在展示…';
  static const nativeWaitingShow = '等待信息流展示…';
  static const nativeAndroidOnly = '信息流广告仅支持 Android';

  static String stopNativeFeedWaiting(int elapsedSeconds) =>
      '$stopNativeFeed（等待${elapsedSeconds}s）';

  static String bannerPollingIntervalRestarted(int seconds) =>
      '横幅轮询间隔已设为 ${seconds}s，已重新开始';

  static String bannerPollingSwitchRestarted(bool enabled) =>
      enabled ? '横幅轮询已开启，已重新开始' : '横幅轮询已关闭';

  static String bannerIntervalSavedWhenPollingOff(int seconds) =>
      '横幅间隔已设为 ${seconds}s（开启轮询后生效）';

  static String nativePollingIntervalRestarted(int seconds) =>
      '信息流轮询间隔已设为 ${seconds}s，已重新开始';

  static String nativePollingSwitchRestarted(bool enabled) =>
      enabled ? '信息流轮询已开启，已重新开始' : '信息流轮询已关闭';

  static String nativeIntervalSavedWhenPollingOff(int seconds) =>
      '信息流间隔已设为 ${seconds}s（开启轮询后生效）';

  static String homeAdCountSummary({
    required int bannerCount,
    required int nativeCount,
  }) =>
      '横幅：${bannerCount}次 信息：${nativeCount}次';
}
