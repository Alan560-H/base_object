package com.xinrui.vita


import android.webkit.WebView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// 获取渠道标识的方法
class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.base_object/channel"
    private val UACHANNEL = "ua_channel"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 处理UACHANNEL
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UACHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getUA") {
                val webView = WebView(this@MainActivity)
                val ua = webView.settings.userAgentString
                result.success(ua)
            } else {
                result.notImplemented()
            }
        }

        // 处理CHANNEL
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getChannel") {
                val context = applicationContext
                val metaData = context.packageManager.getApplicationInfo(
                    context.packageName,
                    android.content.pm.PackageManager.GET_META_DATA
                )
                val channel = metaData.metaData.getString("CHANNEL")
                if (channel != null) {
                    result.success(channel)
                } else {
                    result.error("CHANNEL_NOT_FOUND", "未找到渠道信息", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}