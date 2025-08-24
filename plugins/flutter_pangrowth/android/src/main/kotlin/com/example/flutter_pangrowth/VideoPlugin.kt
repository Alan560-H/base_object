package com.example.flutter_pangrowth

import android.app.Application
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @Author: gstory
 * @CreateDate: 2021/12/13 3:44 下午
 * @Description: 描述
 */

object VideoPlugin {
    /**
     * 短视频注册
     */
    fun registerVideo(context: Application?, call: MethodCall, result: MethodChannel.Result) {
        VideoHolder.initSDK(context!!, call, result)
    }

}