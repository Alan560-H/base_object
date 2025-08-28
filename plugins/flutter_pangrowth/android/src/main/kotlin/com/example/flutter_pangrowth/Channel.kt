package com.example.flutter_pangrowth

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

object Channel {

    lateinit var methodChannel: MethodChannel

    fun init(binaryMessenger: BinaryMessenger) {
        methodChannel = MethodChannel(binaryMessenger, "DramaHomeView_channel")
    }

}