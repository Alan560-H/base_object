package com.example.flutter_pangrowth

import androidx.fragment.app.FragmentActivity
import com.example.flutter_pangrowth.video.view.drama.DramaHomeFactory
import com.example.flutter_pangrowth.video.view.single_video_card.VideoSingleCardViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * @Author: gstory
 * @CreateDate: 2021/12/9 6:31 下午
 * @Description: 描述
 */

object FlutterPangrowthViewPlugin {
    fun registerWith(binding: FlutterPlugin.FlutterPluginBinding, activity: FragmentActivity) {
        binding.platformViewRegistry.registerViewFactory(
            "com.gstory.flutter_pangrowth/DramaHomeView",
            DramaHomeFactory(binding.binaryMessenger, activity)
        )

        //视频卡片 单视频
        binding.platformViewRegistry.registerViewFactory(
            "com.gstory.flutter_pangrowth/VideoSingleCardView",
            VideoSingleCardViewFactory(binding.binaryMessenger, activity)
        )

    }
}