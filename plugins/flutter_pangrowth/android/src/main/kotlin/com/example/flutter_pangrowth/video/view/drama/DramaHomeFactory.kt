package com.example.flutter_pangrowth.video.view.drama

import android.app.Activity
import android.content.Context
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


internal class DramaHomeFactory(
    private val messenger: BinaryMessenger,
    private val activity: FragmentActivity
) : PlatformViewFactory(
    StandardMessageCodec.INSTANCE
) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val params = args as Map<String?, Any?>
        return DramaHomeView(activity, messenger, viewId, params)
    }
}