package com.example.base_object


import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
/// 获取渠道标识的方法
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.base_object/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getChannel") {
                val context = applicationContext
                val metaData = context.packageManager.getApplicationInfo(context.packageName, android.content.pm.PackageManager.GET_META_DATA)
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