package com.cjy.smooth

import androidx.annotation.NonNull

import java.util.Date
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SmoothPlugin */
class SmoothPlugin: FlutterPlugin, SmoothHostApi {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // ref: https://github.com/flutter/plugins/blob/master/packages/video_player/video_player/android/src/main/java/io/flutter/plugins/videoplayer/VideoPlayerPlugin.java#L210
    NativeUtilsHostApi.setup(flutterPluginBinding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    NativeUtilsHostApi.setup(binding.binaryMessenger, null)
  }

  override fun pointerEventDateTimeDiffTimeStamp(): Long {
    // #6069
    val dateTimeValue = System.currentTimeMillis() * 1000
    val timeStampValue = SystemClock.uptimeMillis() * 1000
    return dateTimeValue - timeStampValue
  }
}
