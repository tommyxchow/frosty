package com.tommychow.frosty

import android.webkit.CookieManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CookieExtractorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "frosty/cookie_extractor")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "extractTwitchAuthToken") {
            val cookies = CookieManager.getInstance().getCookie("https://twitch.tv")
            val authToken = cookies?.split(";")
                ?.map { it.trim() }
                ?.firstOrNull { it.startsWith("auth-token=") }
                ?.substringAfter("auth-token=")
            result.success(authToken)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
