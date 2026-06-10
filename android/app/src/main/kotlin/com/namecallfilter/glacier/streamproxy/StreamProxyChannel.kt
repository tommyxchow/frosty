package com.namecallfilter.glacier.streamproxy

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.webkit.WebViewClient
import com.namecallfilter.glacier.cast.CastStreamContext
import com.namecallfilter.glacier.cast.GlacierCastController
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi

object StreamProxyChannel {
    private const val CHANNEL_NAME = "frosty/stream_proxy"

    fun register(
        flutterEngine: FlutterEngine,
        context: Context,
    ) {
        val mainHandler = Handler(Looper.getMainLooper())
        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        )
        val castController = GlacierCastController(
            context = context,
            onStateChanged = { state ->
                mainHandler.post {
                    methodChannel.invokeMethod("castStateChanged", state)
                }
            },
            onRoutesChanged = { state ->
                mainHandler.post {
                    methodChannel.invokeMethod("castRoutesChanged", state)
                }
            },
        )

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
                        val router = StreamProxySessionRegistry.getOrCreateRouter(
                            webViewIdentifier,
                        )
                        val client = StreamProxySessionRegistry.clientFor(webViewIdentifier)
                            ?.also { client ->
                                client.updateConfig(config)
                            }
                            ?: StreamProxyWebViewClient(
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
                            ).also { client ->
                                StreamProxySessionRegistry.putClient(
                                    webViewIdentifier,
                                    client,
                                )
                            }

                        webView.webViewClient = client
                        client.attachToWebView(webView)
                        result.success(null)
                    }
                    "updateConfig" -> {
                        val config = config(call)
                        val webViewIdentifier = webViewIdentifier(call)
                        if (webViewIdentifier != null) {
                            StreamProxySessionRegistry
                                .clientFor(webViewIdentifier)
                                ?.updateConfig(config)
                        } else {
                            StreamProxySessionRegistry.updateAllClients(config)
                        }
                        result.success(null)
                    }
                    "updateCastContext" -> {
                        val config = config(call)
                        val webViewIdentifier = webViewIdentifier(call)
                            ?: return@setMethodCallHandler result.success(null)
                        castController.updateContext(
                            CastStreamContext(
                                webViewIdentifier = webViewIdentifier,
                                channelLogin = config.currentChannelLogin,
                                title = stringArgument(call, "title")
                                    ?: config.currentChannelLogin,
                                subtitle = stringArgument(call, "subtitle"),
                                quality = stringArgument(call, "quality"),
                                config = config,
                            ),
                        )
                        result.success(null)
                    }
                    "startCastRouteDiscovery" -> {
                        mainHandler.post {
                            castController.startRouteDiscovery()
                        }
                        result.success(null)
                    }
                    "stopCastRouteDiscovery" -> {
                        mainHandler.post {
                            castController.stopRouteDiscovery()
                        }
                        result.success(null)
                    }
                    "selectCastRoute" -> {
                        val routeId = stringArgument(call, "routeId")
                            ?: return@setMethodCallHandler result.error(
                                "missing_route_id",
                                "Missing routeId",
                                null,
                            )
                        mainHandler.post {
                            castController.selectRoute(routeId)
                        }
                        result.success(null)
                    }
                    "stopCasting" -> {
                        mainHandler.post {
                            castController.stopCasting()
                        }
                        result.success(null)
                    }
                    "detach" -> {
                        val webViewIdentifier = webViewIdentifier(call)
                            ?: return@setMethodCallHandler result.success(null)
                        StreamProxySessionRegistry.removeClient(webViewIdentifier)
                            ?.detachFromWebView()
                        StreamProxySessionRegistry.removeRouter(webViewIdentifier)

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

    private fun stringArgument(call: MethodCall, key: String): String? {
        val arguments = call.arguments as? Map<*, *> ?: return null
        return (arguments[key] as? String)
            ?.trim()
            ?.takeIf(String::isNotEmpty)
    }
}
