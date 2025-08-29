package com.ruyimh

import android.content.Intent
import android.webkit.WebView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// 获取渠道标识的方法
class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.base_object/channel"
    private val UACHANNEL = "ua_channel"

    // 1. 新增：保存 MethodChannel 引用，用于 Activity 销毁时解绑
    private lateinit var uaMethodChannel: MethodChannel
    private lateinit var channelMethodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 页面复用逻辑（原有逻辑保留，无需修改）
        if ((intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) !== 0) {
            finish()
            return
        }

        // 2. 处理 UACHANNEL（修复 WebView Context 问题）
        uaMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UACHANNEL
        )
        uaMethodChannel.setMethodCallHandler { call, result ->
            if (call.method == "getUA") {
                // 核心修复1：用 Application Context 代替 Activity Context（避免随页面销毁失效）
                val appContext = applicationContext
                if (appContext == null) {
                    // 防御性判断：若 Context 无效，返回错误而非崩溃
                    result.error("CONTEXT_ERROR", "应用 Context 为空，无法获取 UserAgent", null)
                    return@setMethodCallHandler
                }

                var webView: WebView? = null
                try {
                    // 用 Application Context 创建 WebView
                    webView = WebView(appContext)
                    val ua = webView.settings.userAgentString
                    result.success(ua) // 成功返回 UserAgent
                } catch (e: Exception) {
                    // 核心修复2：捕获异常（如 WebView 初始化失败），避免崩溃
                    result.error("UA_GET_FAILED", "获取 UserAgent 失败：${e.message}", null)
                } finally {
                    // 核心修复3：手动销毁 WebView，释放 Context 引用和内存
                    webView?.destroy()
                }
            } else {
                result.notImplemented()
            }
        }

        // 3. 处理 CHANNEL（原有逻辑保留，因已用 Application Context 无需修改）
        channelMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
        channelMethodChannel.setMethodCallHandler { call, result ->
            if (call.method == "getChannel") {
                val context = applicationContext
                try {
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
                } catch (e: Exception) {
                    // 新增：捕获包管理相关异常（如权限问题），避免崩溃
                    result.error("CHANNEL_GET_FAILED", "获取渠道信息失败：${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // 4. 新增：Activity 销毁时解绑 MethodChannel，避免内存泄漏和无效回调
    override fun onDestroy() {
        super.onDestroy()
        // 解绑后，Flutter 侧再调用方法不会触发回调，避免使用已失效的 Context
        uaMethodChannel.setMethodCallHandler(null)
        channelMethodChannel.setMethodCallHandler(null)
    }
}