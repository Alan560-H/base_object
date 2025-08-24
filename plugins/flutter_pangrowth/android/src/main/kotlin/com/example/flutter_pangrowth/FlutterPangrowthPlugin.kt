package com.example.flutter_pangrowth

import android.app.Activity
import android.app.Application
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** FlutterPangrowthPlugin */
class FlutterPangrowthPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var applicationContext: Context? = null
    private var mActivity: Activity? = null
    private lateinit var channel: MethodChannel
    private var mFlutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
        FlutterPangrowthViewPlugin.registerWith(
            mFlutterPluginBinding!!,
            mActivity as FragmentActivity
        )
//        Log.e("FlutterUnionadPlugin->","onAttachedToActivity")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mActivity = binding.activity
//        Log.e("FlutterUnionadPlugin->","onReattachedToActivityForConfigChanges")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        mActivity = null
//        Log.e("FlutterUnionadPlugin->","onDetachedFromActivityForConfigChanges")
    }

    override fun onDetachedFromActivity() {
        mActivity = null
//        Log.e("FlutterUnionadPlugin->","onDetachedFromActivity")
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_pangrowth")
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
        mFlutterPluginBinding = flutterPluginBinding
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d("FlutterPangrowthPlugin", "onMethodCall: ${call.method}")
        if (call.method == "registerVideo") {
            VideoPlugin.registerVideo(applicationContext as? Application, call) {
                result.success(it)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
