package com.tommychow.frosty.streamproxy

import android.os.Handler
import android.os.Looper
import android.webkit.WebViewClient
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi
import java.util.concurrent.ConcurrentHashMap

object StreamProxyChannel {
    private const val CHANNEL_NAME = "frosty/stream_proxy"

    fun register(flutterEngine: FlutterEngine) {
        val mainHandler = Handler(Looper.getMainLooper())
        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        )
        val routers = ConcurrentHashMap<Long, StreamProxyRequestRouter>()
        val clients = ConcurrentHashMap<Long, StreamProxyWebViewClient>()

        methodChannel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "attach" -> {
                        val webViewIdentifier = webViewIdentifier(call)
                            ?: return@setMethodCallHandler result.error(
                                "missing_webview_identifier",
                                "Missing webViewIdentifier",
                                null,
                            )
                        val webView = WebViewFlutterAndroidExternalApi.getWebView(
                            flutterEngine,
                            webViewIdentifier,
                        ) ?: return@setMethodCallHandler result.error(
                            "webview_not_found",
                            "No WebView found for identifier $webViewIdentifier",
                            null,
                        )
                        val config = config(call)
                        val router = routers.getOrPut(webViewIdentifier) {
                            StreamProxyRequestRouter()
                        }
                        val client = clients[webViewIdentifier]?.also {
                            it.updateConfig(config)
                        } ?: StreamProxyWebViewClient(
                            initialConfig = config,
                            router = router,
                            onPageFinished = { url ->
                                mainHandler.post {
                                    methodChannel.invokeMethod(
                                        "pageFinished",
                                        mapOf(
                                            "webViewIdentifier" to webViewIdentifier,
                                            "url" to url,
                                        ),
                                    )
                                }
                            },
                        ).also {
                            clients[webViewIdentifier] = it
                        }

                        webView.webViewClient = client
                        client.attachToWebView(webView)
                        result.success(null)
                    }
                    "updateConfig" -> {
                        val config = config(call)
                        val webViewIdentifier = webViewIdentifier(call)
                        if (webViewIdentifier != null) {
                            clients[webViewIdentifier]?.updateConfig(config)
                        } else {
                            clients.values.forEach { it.updateConfig(config) }
                        }
                        result.success(null)
                    }
                    "detach" -> {
                        val webViewIdentifier = webViewIdentifier(call)
                            ?: return@setMethodCallHandler result.success(null)
                        clients.remove(webViewIdentifier)
                            ?.detachFromWebView()
                        routers.remove(webViewIdentifier)

                        WebViewFlutterAndroidExternalApi.getWebView(
                            flutterEngine,
                            webViewIdentifier,
                        )?.webViewClient = WebViewClient()

                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error(
                    "stream_proxy_error",
                    error.message,
                    error.javaClass.simpleName,
                )
            }
        }
    }

    private fun webViewIdentifier(call: MethodCall): Long? {
        val arguments = call.arguments as? Map<*, *> ?: return null
        return when (val value = arguments["webViewIdentifier"]) {
            is Int -> value.toLong()
            is Long -> value
            is Number -> value.toLong()
            else -> null
        }
    }

    private fun config(call: MethodCall): StreamProxyConfig {
        val arguments = call.arguments as? Map<*, *>
        return StreamProxyConfig.fromMap(arguments?.get("config") as? Map<*, *>)
    }
}
