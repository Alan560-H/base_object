import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// @Author: gstory
/// @CreateDate: 2021/12/14 12:10 下午
/// @Email gstory0404@gmail.com
/// @Description: dart类作用描述

class DrawHomeView extends StatefulWidget {
  final double viewWidth;
  final double viewHeight;

  const DrawHomeView({
    Key? key,
    required this.viewWidth,
    required this.viewHeight,
  }) : super(key: key);

  @override
  _DrawHomeViewState createState() => _DrawHomeViewState();
}

class _DrawHomeViewState extends State<DrawHomeView> {
  final String _viewType = "com.gstory.flutter_pangrowth/DramaHomeView";

  final MethodChannel _channel = const MethodChannel("DramaHomeView_channel");

  final String onUnlockMethod = "on_unlock_method";

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (call.method == onUnlockMethod) {
        print("onUnlockMethod: ${call.arguments}");
        call.arguments<bool>("isUnlock") ?? false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return SizedBox(
        width: widget.viewWidth,
        height: widget.viewHeight,
        child: AndroidView(
          viewType: _viewType,
          creationParams: {
            "viewWidth": widget.viewWidth,
            "viewHeight": widget.viewHeight,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: widget.viewWidth,
        height: widget.viewHeight,
        child: UiKitView(
          viewType: _viewType,
          creationParams: {
            "viewWidth": widget.viewWidth,
            "viewHeight": widget.viewHeight,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      return Container();
    }
  }

  //注册cannel
  void _registerChannel(int id) {}
}
