package com.ruyimh.www

import android.content.pm.PackageManager
import android.os.Bundle // 关键：导入 Bundle 类（解决 Unresolved reference 'Bundle'）
import android.provider.Settings
import android.util.Log
import android.webkit.WebView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterFragmentActivity() {
    // 日志标签
    private val tag = "RiskControlMainActivity"

    // 1. 错误修复：移除 const 修饰符（类内部不能用 const，const 只能在顶层/伴生对象中）
    private val uaChannel = "uaChannel"
    private val channelChannel = "com.example.base_object/channel"
    private val riskControlChannel = "com.example.riskcontrol"

    // 2. 错误修复：移除 const 修饰符，改为普通 val
    private val methodGetUa = "getUA"
    private val methodGetChannel = "getChannel"
    private val methodIsDeveloperMode = "isDeveloperModeEnabled"
    private val methodIsAccessibilityEnabled = "isAccessibilityModeEnabled"
    private val methodGetAccessibilityServices = "getEnabledAccessibilityServices"

    // 声明各功能的 MethodChannel
    private lateinit var _uaMethodChannel: MethodChannel
    private lateinit var _channelMethodChannel: MethodChannel
    private lateinit var _riskControlChannel: MethodChannel

    // 3. 错误修复：onCreate 方法签名匹配父类（参数为 Bundle?，且已导入 Bundle 类）
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(tag, "MainActivity 已创建：onCreate 执行")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(tag, "=== configureFlutterEngine 开始执行 ===")

        // 1. 初始化「UA 获取」通道
        _uaMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            uaChannel
        )
        _uaMethodChannel.setMethodCallHandler { call, result ->
            handleUAMethodCall(call, result)
        }

        // 2. 初始化「应用渠道获取」通道
        _channelMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelChannel
        )
        _channelMethodChannel.setMethodCallHandler { call, result ->
            handleChannelMethodCall(call, result)
        }

        // 3. 初始化「风控检测」通道
        _riskControlChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            riskControlChannel
        )
        _riskControlChannel.setMethodCallHandler { call, result ->
            handleRiskControlMethodCall(call, result)
        }

        Log.d(tag, "=== configureFlutterEngine 执行完成 ===")
    }

    // ========== 处理「UA 获取」相关逻辑 ==========
    private fun handleUAMethodCall(call: MethodCall, result: Result) {
        if (call.method == methodGetUa) {
            val appContext = applicationContext ?: run {
                Log.e(tag, "UA 通道错误：应用 Context 为空")
                result.error("CONTEXT_ERROR", "应用 Context 为空，无法获取 UserAgent", null)
                return
            }

            var webView: WebView? = null
            try {
                webView = WebView(appContext)
                val ua = webView.settings.userAgentString
                Log.d(tag, "UA 获取成功：$ua")
                result.success(ua)
            } catch (e: Exception) {
                Log.e(tag, "UA 获取失败：${e.message}", e)
                result.error("UA_GET_FAILED", "获取 UserAgent 失败：${e.message}", null)
            } finally {
                webView?.destroy() // 及时销毁 WebView，避免内存泄漏
            }
        } else {
            Log.w(tag, "UA 通道：未实现的方法=${call.method}")
            result.notImplemented()
        }
    }

    // ========== 处理「应用渠道获取」相关逻辑 ==========
    private fun handleChannelMethodCall(call: MethodCall, result: Result) {
        if (call.method == methodGetChannel) {
            val context = applicationContext ?: run {
                Log.e(tag, "Channel 通道错误：应用 Context 为空")
                result.error("CONTEXT_ERROR", "应用 Context 为空，无法获取渠道", null)
                return
            }
            try {
                val metaData = context.packageManager.getApplicationInfo(
                    context.packageName,
                    PackageManager.GET_META_DATA
                )
                val channel = metaData.metaData.getString("CHANNEL")
                if (channel != null) {
                    Log.d(tag, "CHANNEL 获取成功：$channel")
                    result.success(channel)
                } else {
                    Log.e(tag, "CHANNEL 获取失败：Manifest 中未找到 CHANNEL meta-data")
                    result.error("CHANNEL_NOT_FOUND", "未找到渠道信息", null)
                }
            } catch (e: Exception) {
                Log.e(tag, "CHANNEL 获取异常：${e.message}", e)
                result.error("CHANNEL_GET_FAILED", "获取渠道信息失败：${e.message}", null)
            }
        } else {
            Log.w(tag, "Channel 通道：未实现的方法=${call.method}")
            result.notImplemented()
        }
    }

    // ========== 处理「风控检测」相关逻辑 ==========
    private fun handleRiskControlMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            // 1. 检测「系统开发者模式」是否开启
            methodIsDeveloperMode -> {
                val isDevMode = try {
                    Settings.Global.getInt(contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1
                } catch (e: Exception) {
                    Log.e(tag, "检测开发者模式异常：${e.message}", e)
                    false
                }
                Log.d(tag, "系统开发者模式状态：$isDevMode")
                result.success(isDevMode)
            }

            // 2. 检测「无障碍模式总开关」是否开启
            methodIsAccessibilityEnabled -> {
                val isAccessEnabled = try {
                    Settings.Secure.getInt(contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0) == 1
                } catch (e: Exception) {
                    Log.e(tag, "检测无障碍模式异常：${e.message}", e)
                    false
                }
                Log.d(tag, "无障碍模式总开关状态：$isAccessEnabled")
                result.success(isAccessEnabled)
            }

            // 3. 获取「已启用的无障碍服务」列表
            methodGetAccessibilityServices -> {
                val services = try {
                    Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: ""
                } catch (e: Exception) {
                    Log.e(tag, "获取无障碍服务列表异常：${e.message}", e)
                    ""
                }
                val serviceList = if (services.isNotEmpty()) services.split(":") else emptyList()
                Log.d(tag, "已启用的无障碍服务数量：${serviceList.size}，列表：$serviceList")
                result.success(serviceList)
            }

            // 其他未实现的方法
            else -> {
                Log.w(tag, "风控通道：未实现的方法=${call.method}")
                result.notImplemented()
            }
        }
    }

    // Activity 销毁时，解绑所有通道（避免内存泄漏）
    override fun onDestroy() {
        super.onDestroy()
        Log.d(tag, "MainActivity 销毁：解绑所有通道")
        _uaMethodChannel.setMethodCallHandler(null)
        _channelMethodChannel.setMethodCallHandler(null)
        _riskControlChannel.setMethodCallHandler(null)
    }
}