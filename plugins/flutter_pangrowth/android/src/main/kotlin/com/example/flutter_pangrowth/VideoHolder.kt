package com.example.flutter_pangrowth

import android.app.Application
import android.util.Log
import com.bytedance.sdk.djx.DJXSdk
import com.bytedance.sdk.djx.DJXSdkConfig
import com.bytedance.sdk.djx.IDJXPrivacyController
import com.bytedance.sdk.dp.DPSdk
import com.bytedance.sdk.dp.DPSdkConfig
import com.bytedance.sdk.dp.DPWidgetDrawParams
import com.bytedance.sdk.dp.IDPPrivacyController
import com.bytedance.sdk.dp.IDPWidget
import com.bytedance.sdk.dp.IDPWidgetFactory
import com.bytedance.sdk.openadsdk.TTAdConfig
import com.bytedance.sdk.openadsdk.TTAdConstant
import com.bytedance.sdk.openadsdk.TTAdSdk
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope

object VideoHolder : CoroutineScope by MainScope() {

    private const val TAG = "VideoHolder"

    private const val configJson = "pangrowthconfig.json"

    var isDPStarted: Boolean = false

    fun initSDK(context: Application, call: MethodCall, onInited: (Boolean) -> Unit) {
        val debug = call.argument<Boolean>("debug") as Boolean
        val androidAppId = call.argument<String>("andoridAppId")


        val build = TTAdConfig.Builder()
            .appId(androidAppId) //穿山甲媒体id
            .appName("")
            .titleBarTheme(TTAdConstant.TITLE_BAR_THEME_DARK)
            .allowShowNotify(true)
            .supportMultiProcess(true)
            .debug(debug)
            .build()
        TTAdSdk.init(context, build)

        val djConfig = DJXSdkConfig.Builder()
            .debug(debug)
            .build()

        // 配置青少年模式，可选
        djConfig.apply {
            privacyController = object : IDJXPrivacyController() {
                override fun isTeenagerMode(): Boolean {
                    return false
                }
            }
        }

        DJXSdk.init(context, configJson, djConfig)

        TTAdSdk.start(object : TTAdSdk.Callback {
            override fun success() {
                Log.e(TAG, "TTAdSdk aysnc init success")

                // 配置隐私控制开关，可选
                DJXSdk.start { isSuccess, message, error ->
                    Log.d(TAG, "DJXSdk doInitTask: $isSuccess, $message, $error")
                }
                initDpSdk(context, debug)
            }

            override fun fail(code: Int, msg: String?) {
                Log.e(TAG, "TTAdSdk aysnc init fail, code = $code msg = $msg")
            }
        })

        onInited(true)
    }

    private var dpStartCount = 0

    fun initDpSdk(context: Application, debug: Boolean) {
        Log.e(TAG, "DPSdk start init dpStartCount $dpStartCount")
        val configBuilder = DPSdkConfig.Builder()
            .debug(true)
            .debug(debug)
            .luckConfig(
                DPSdkConfig.LuckConfig().application(context).enableLuck(false)
            ) // 积分配置

        val dpConfig = configBuilder.build().apply {
            // 配置青少年模式，可选
            privacyController = object : IDPPrivacyController() {
                override fun isTeenagerMode(): Boolean {
                    return false
                }
            }
        }

        DPSdk.init(context, configJson, dpConfig)

        DPSdk.start { isSuccess, message ->
            //请确保使用时Sdk已经成功启动
            //isSuccess=true表示启动成功
            //启动失败，可以再次调用启动接口（建议最多不要超过3次)
            isDPStarted = isSuccess
            Log.e(TAG, "DPSdk start result=$isSuccess, msg=$message")
        }
    }

    private fun getFactory(): IDPWidgetFactory {
        //一定要初始化后才能调用，否则会发生异常问题
        return DPSdk.factory()
    }

    fun buildDrawWidget(params: DPWidgetDrawParams?): IDPWidget? {
        //创建draw视频流组件
        return getFactory().createDraw(params)
    }
}