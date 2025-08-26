part of 'flutter_pangrowth.dart';

class PangrowthVideo {
  static Future<bool> registerVideo({
    required String appName,
    required String andoridAppId,
    required String appLogAppId,
    required String iosAppId,
    bool? debug,
    String? mPartner,
    String? mSecureKey,
    String? mOldPartner,
    String? mOldUUID,
  }) async {
    return await FlutterPangrowth.pangrowthChannel
        .invokeMethod("registerVideo", {
          "andoridAppId": andoridAppId,
          "iosAppId": iosAppId,
          "debug": debug ?? false,
          "appLogAppId": appLogAppId,
        });
  }

  ///短剧聚合页
  static Widget drawHomeView({
    required double viewWidth,
    required double viewHeight,
  }) {
    return DrawHomeView(viewWidth: viewWidth, viewHeight: viewHeight);
  }

  static Widget videoSingleCardView({
    required double viewWidth,
    required double viewHeight,
  }) {
    return VideoSingleCardView(viewWidth: viewWidth, viewHeight: viewHeight);
  }
}
