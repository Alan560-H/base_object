package com.recorder

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.jialeb/channel"
    private val TAG = "MainActivityDebug"
    private val UACHANNEL = "com.jialeb/uaChannel"

    private lateinit var uaMethodChannel: MethodChannel
    private lateinit var channelMethodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "MainActivity 已创建：onCreate 执行")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "=== configureFlutterEngine 开始执行 ===")

        if ((intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            Log.d(TAG, "检测到页面复用标记，不销毁 Activity")
            return
        }

        Log.d(TAG, "开始注册 UA 通道：$UACHANNEL")
        uaMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UACHANNEL
        )
        uaMethodChannel.setMethodCallHandler { call, result ->
            Log.d(TAG, "UA 通道收到调用：方法名=${call.method}")
            if (call.method == "getUA") {
                val appContext = applicationContext
                if (appContext == null) {
                    Log.e(TAG, "UA 通道错误：应用 Context 为空")
                    result.error("CONTEXT_ERROR", "应用 Context 为空，无法获取 UserAgent", null)
                    return@setMethodCallHandler
                }
                var webView: WebView? = null
                try {
                    webView = WebView(appContext)
                    val ua = webView.settings.userAgentString
                    Log.d(TAG, "UA 获取成功：$ua")
                    result.success(ua)
                } catch (e: Exception) {
                    Log.e(TAG, "UA 获取失败：${e.message}", e)
                    result.error("UA_GET_FAILED", "获取 UserAgent 失败：${e.message}", null)
                } finally {
                    webView?.destroy()
                }
            } else {
                Log.w(TAG, "UA 通道：未实现的方法=${call.method}")
                result.notImplemented()
            }
        }

        Log.d(TAG, "开始注册 CHANNEL 通道：$CHANNEL")
        channelMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
        channelMethodChannel.setMethodCallHandler { call, result ->
            Log.d(TAG, "CHANNEL 通道收到调用：方法名=${call.method}")
            if (call.method == "getChannel") {
                val context = applicationContext
                try {
                    val metaData = context.packageManager.getApplicationInfo(
                        context.packageName,
                        android.content.pm.PackageManager.GET_META_DATA
                    )
                    val channel = metaData.metaData.getString("CHANNEL")
                    if (channel != null) {
                        Log.d(TAG, "CHANNEL 获取成功：$channel")
                        result.success(channel)
                    } else {
                        Log.e(TAG, "CHANNEL 获取失败：Manifest 中未找到 CHANNEL meta-data")
                        result.error("CHANNEL_NOT_FOUND", "未找到渠道信息", null)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "CHANNEL 获取异常：${e.message}", e)
                    result.error("CHANNEL_GET_FAILED", "获取渠道信息失败：${e.message}", null)
                }
            } else {
                Log.w(TAG, "CHANNEL 通道：未实现的方法=${call.method}")
                result.notImplemented()
            }
        }

        Log.d(TAG, "=== configureFlutterEngine 执行完成 ===")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "MainActivity 销毁：解绑所有通道")
        uaMethodChannel.setMethodCallHandler(null)
        channelMethodChannel.setMethodCallHandler(null)
    }
}
