import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class ShortVideoController extends GetxController {
  RxString appbarTitle = "短视频页面标题".obs;
  // showNatvieAd()async {
  //   bool isReadyNative = await NativeTool.to.nativeAdReady();
  //   if(isReadyNative){
  //     NativeTool.to.showNative();
  //   }
  //   Utils.logError("是否准备好：$isReadyNative");
  // }
  bool _hasShow = false;

  /// 订阅 ListenerTool 的开屏广告事件
  // void nativeEvent() async {
  //   // ever：持续监听 splashEvent 的变化（广告状态更新时触发）
  //   ever(ListenerTool.to.nativeEvent, (event) {
  //     if (event == null || _hasShow) return; // 过滤空事件或重复跳转
  //
  //     // 获取事件类型（从 event 中解析，与 ListenerTool 中转发的格式对应）
  //     String eventType = event["eventType"] ?? "";
  //     String placementID = event["placementID"] ?? "";
  //
  //     Utils.logError("原生广告收到原生视频广告事件：$eventType，广告位ID：$placementID，事件参数：$event");
  //     // 根据事件类型执行业务逻辑
  //     switch (eventType) {
  //     // 原生广告加载失败
  //       case "NativeStatus.nativeAdFailToLoadAD":
  //         Utils.logError("原生广告加载失败，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告加载完成
  //       case "NativeStatus.nativeAdDidFinishLoading":
  //         Utils.logError("原生广告加载完成，广告位ID：$placementID，事件参数：$event");
  //         showNatvieAd();
  //         break;
  //
  //     // 原生广告被点击
  //       case "NativeStatus.nativeAdDidClick":
  //         Utils.logError("原生广告被点击，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告深度链接
  //       case "NativeStatus.nativeAdDidDeepLink":
  //         Utils.logError("原生广告深度链接，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告视频播放结束
  //       case "NativeStatus.nativeAdDidEndPlayingVideo":
  //         Utils.logError("原生广告视频播放结束，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告进入全屏视频
  //       case "NativeStatus.nativeAdEnterFullScreenVideo":
  //         Utils.logError("原生广告进入全屏视频，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告退出全屏视频
  //       case "NativeStatus.nativeAdExitFullScreenVideoInAd":
  //         Utils.logError("原生广告退出全屏视频，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告展示成功
  //       case "NativeStatus.nativeAdDidShowNativeAd":
  //         Utils.logError("原生广告展示成功，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告视频开始播放
  //       case "NativeStatus.nativeAdDidStartPlayingVideo":
  //         Utils.logError("原生广告视频开始播放，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告点击关闭按钮
  //       case "NativeStatus.nativeAdDidTapCloseButton":
  //         Utils.logError("原生广告点击关闭按钮，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告加载成功并渲染
  //       case "NativeStatus.nativeAdDidLoadSuccessDraw":
  //         Utils.logError("原生广告加载成功并渲染，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告关闭详情页
  //       case "NativeStatus.nativeAdDidCloseDetailInAdView":
  //         Utils.logError("原生广告关闭详情页，广告位ID：$placementID，事件参数：$event");
  //         break;
  //
  //     // 原生广告未知事件（默认case，覆盖枚举的unknown及未定义情况）
  //       case "NativeStatus.nativeAdUnknown":
  //       default:
  //         Utils.logError("原生广告未知事件，广告位ID：$placementID，事件类型：$eventType，事件参数：$event");
  //         break;
  //     }
  //   });
  // }

  @override
  void onReady() {
    // TODO: implement onReady‘
    Utils.logError("短视频页面onReady");
    super.onReady();
  }
  @override
  void onClose() {
    // TODO: implement onClose
    Utils.logError("短视频页面onClose");
    super.onClose();
  }
  @override
  void onInit() {
    Utils.logError("短视频页面初始化");
    // nativeEvent();
    super.onInit();
  }
}
