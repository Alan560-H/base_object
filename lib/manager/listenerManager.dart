import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class ListenerTool extends GetxService {
  // GetX单例获取方式
  static ListenerTool get to => Get.find<ListenerTool>();

  rewarderListen() {
    ATListenerManager.rewardedVideoEventHandler.listen((value) {
      switch (value.rewardStatus) {
        case RewardedStatus.rewardedVideoDidFailToLoad:
          Utils.logError("flutter：激励视频加载失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.requestMessage}");
          break;
        case RewardedStatus.rewardedVideoDidFinishLoading:
          Utils.logError("flutter：激励视频加载完成 ---- 广告位ID: ${value.placementID}");
          break;
        case RewardedStatus.rewardedVideoDidStartPlaying:
          Utils.logError("flutter：激励视频开始播放 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidEndPlaying:
          Utils.logError("flutter：激励视频播放结束 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidFailToPlay:
          Utils.logError("flutter：激励视频播放失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidRewardSuccess:
          Utils.logError("flutter：激励视频奖励发放成功 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidClick:
          Utils.logError("flutter：激励视频被点击 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidDeepLink:
          Utils.logError("flutter：激励视频深度链接跳转 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap} ---- 跳转成功:${value.isDeeplinkSuccess}");
          break;
        case RewardedStatus.rewardedVideoDidClose:
          Utils.logError("flutter：激励视频关闭 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoUnknown:
          Utils.logError("flutter：激励视频状态未知");
          break;
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
          Utils.logError("flutter：激励视频再次开始播放 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
          Utils.logError("flutter：激励视频再次播放结束 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:
          Utils.logError("flutter：激励视频再次播放失败 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          Utils.logError("flutter：激励视频再次奖励发放成功 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case RewardedStatus.rewardedVideoDidAgainClick:
          Utils.logError("flutter：激励视频再次被点击 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
      }
    });
  }

  interListen() {
    ATListenerManager.interstitialEventHandler.listen((value) {
      switch (value.interstatus) {
        case InterstitialStatus.interstitialAdFailToLoadAD:
          Utils.logError("flutter：插屏广告加载失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.requestMessage}");
          break;
        case InterstitialStatus.interstitialAdDidFinishLoading:
          Utils.logError("flutter：插屏广告加载完成 ---- 广告位ID: ${value.placementID}");
          break;
        case InterstitialStatus.interstitialAdDidStartPlaying:
          Utils.logError("flutter：插屏广告开始播放 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialAdDidEndPlaying:
          Utils.logError("flutter：插屏广告播放结束 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialDidFailToPlayVideo:
          Utils.logError("flutter：插屏广告视频播放失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.requestMessage}");
          break;
        case InterstitialStatus.interstitialDidShowSucceed:
          Utils.logError("flutter：插屏广告展示成功 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialFailedToShow:
          Utils.logError("flutter：插屏广告展示失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.requestMessage}");
          break;
        case InterstitialStatus.interstitialAdDidClick:
          Utils.logError("flutter：插屏广告被点击 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialAdDidDeepLink:
          Utils.logError("flutter：插屏广告深度链接跳转 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialAdDidClose:
          Utils.logError("flutter：插屏广告关闭 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case InterstitialStatus.interstitialUnknown:
          Utils.logError("flutter：插屏广告状态未知");
          break;
      }
    });
  }

  bannerListen() {
    ATListenerManager.bannerEventHandler.listen((value) {
      switch (value.bannerStatus) {
        case BannerStatus.bannerAdFailToLoadAD:
          Utils.logError("flutter：横幅广告加载失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.requestMessage}");
          break;
        case BannerStatus.bannerAdDidFinishLoading:
          Utils.logError("flutter：横幅广告加载完成 ---- 广告位ID: ${value.placementID}");
          break;
        case BannerStatus.bannerAdAutoRefreshSucceed:
          Utils.logError("flutter：横幅广告自动刷新成功 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case BannerStatus.bannerAdDidClick:
          Utils.logError("flutter：横幅广告被点击 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case BannerStatus.bannerAdDidDeepLink:
          Utils.logError("flutter：横幅广告深度链接跳转 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap} ---- 跳转成功:${value.isDeeplinkSuccess}");
          break;
        case BannerStatus.bannerAdDidShowSucceed:
          Utils.logError("flutter：横幅广告展示成功 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case BannerStatus.bannerAdTapCloseButton:
          Utils.logError("flutter：横幅广告点击关闭按钮 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case BannerStatus.bannerAdAutoRefreshFail:
          Utils.logError("flutter：横幅广告自动刷新失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.requestMessage}");
          break;
        case BannerStatus.bannerAdUnknown:
          Utils.logError("flutter：横幅广告状态未知");
          break;
      }
    });
  }

  nativeListen() {
    ATListenerManager.nativeEventHandler.listen((value) {
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdFailToLoadAD:
          Utils.logError("flutter：原生广告加载失败 ---- 广告位ID: ${value.placementID} ---- 错误信息:${value.requestMessage}");
          break;
        case NativeStatus.nativeAdDidFinishLoading:
          Utils.logError("flutter：原生广告加载完成 ---- 广告位ID: ${value.placementID}");
          break;
        case NativeStatus.nativeAdDidClick:
          Utils.logError("flutter：原生广告被点击 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidDeepLink:
          Utils.logError("flutter：原生广告深度链接跳转 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap} ---- 跳转成功:${value.isDeeplinkSuccess}");
          break;
        case NativeStatus.nativeAdDidEndPlayingVideo:
          Utils.logError("flutter：原生广告视频播放结束 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdEnterFullScreenVideo:
          Utils.logError("flutter：原生广告进入全屏视频 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdExitFullScreenVideoInAd:
          Utils.logError("flutter：原生广告退出广告内全屏视频 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidShowNativeAd:
          Utils.logError("flutter：原生广告展示成功 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidStartPlayingVideo:
          Utils.logError("flutter：原生广告视频开始播放 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidTapCloseButton:
          Utils.logError("flutter：原生广告点击关闭按钮 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidCloseDetailInAdView:
          Utils.logError("flutter：原生广告关闭广告内详情页 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdDidLoadSuccessDraw:
          Utils.logError("flutter：原生广告素材绘制加载成功 ---- 广告位ID: ${value.placementID} ---- 附加信息:${value.extraMap}");
          break;
        case NativeStatus.nativeAdUnknown:
          Utils.logError("flutter：原生广告状态未知"); // 原"downloadUnknown"为笔误，修正为"原生广告状态未知"
          break;
      }
    });
  }

  downLoadListen() {
    ATListenerManager.downloadEventHandler.listen((value) {
      switch (value.downloadStatus) {
        case DownloadStatus.downloadStart:
          Utils.logError("flutter：下载开始 ---- 广告位ID: ${value.placementID}, 总大小: ${value.totalBytes}, 当前进度: ${value.currBytes}, "
              "文件名: ${value.fileName}, 应用名: ${value.appName}, 附加信息: ${value.extraMap}");
          break;
        case DownloadStatus.downloadUpdate:
          Utils.logError("flutter：下载进度更新 ---- 广告位ID: ${value.placementID}, 总大小: ${value.totalBytes}, 当前进度: ${value.currBytes}, "
              "文件名: ${value.fileName}, 应用名: ${value.appName}, 附加信息: ${value.extraMap}");
          break;
        case DownloadStatus.downloadPause:
          Utils.logError("flutter：下载暂停 ---- 广告位ID: ${value.placementID}, 总大小: ${value.totalBytes}, 当前进度: ${value.currBytes}, "
              "文件名: ${value.fileName}, 应用名: ${value.appName}, 附加信息: ${value.extraMap}");
          break;
        case DownloadStatus.downloadFinished:
          Utils.logError("flutter：下载完成 ---- 广告位ID: ${value.placementID}, 总大小: ${value.totalBytes}, "
              "文件名: ${value.fileName}, 应用名: ${value.appName}, 附加信息: ${value.extraMap}");
          break;
        case DownloadStatus.downloadFailed:
          Utils.logError("flutter：下载失败 ---- 广告位ID: ${value.placementID}, 总大小: ${value.totalBytes}, 当前进度: ${value.currBytes}, "
              "文件名: ${value.fileName}, 应用名: ${value.appName}, 附加信息: ${value.extraMap}");
          break;
        case DownloadStatus.downloadInstalled:
          Utils.logError("flutter：应用安装完成 ---- 广告位ID: ${value.placementID}, "
              "文件名: ${value.fileName}, 应用名: ${value.appName}, 附加信息: ${value.extraMap}");
          break;
        case DownloadStatus.downloadUnknown:
          Utils.logError("flutter：下载状态未知"); // 原"downloadUnknow"修正为"下载状态未知"（补充字母"n"）
          break;
      }
    });
  }
}