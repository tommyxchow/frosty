package com.namecallfilter.glacier.streamproxy

import android.graphics.Bitmap
import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.webkit.ScriptHandler
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature

class StreamProxyWebViewClient(
    initialConfig: StreamProxyConfig,
    private val router: StreamProxyRequestRouter,
    private val onPageFinished: (String) -> Unit,
) : WebViewClient() {
    @Volatile
    private var config = initialConfig

    private val fetcher = StreamProxyFetcher(::log)
    private var webView: WebView? = null
    private var documentStartScript: ScriptHandler? = null
    private var documentStartSupported = false

    fun attachToWebView(view: WebView) {
        webView = view
        installDocumentStartScript()
    }

    fun updateConfig(newConfig: StreamProxyConfig) {
        config = newConfig
        installDocumentStartScript()
        webView?.post {
            webView?.evaluateJavascript(
                StreamProxyPageScript.updateConfigScript(newConfig),
                null,
            )
        }
    }

    fun detachFromWebView() {
        removeDocumentStartScript()
        webView = null
    }

    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        if (!documentStartSupported && config.enabled) {
            view?.evaluateJavascript(StreamProxyPageScript.create(config), null)
        }
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        if (url != null) {
            onPageFinished(url)
        }
    }

    override fun shouldInterceptRequest(
        view: WebView?,
        request: WebResourceRequest?,
    ): WebResourceResponse? {
        if (request == null) return null

        val currentConfig = config
        val decision = router.route(
            url = request.url.toString(),
            method = request.method,
            headers = request.requestHeaders ?: emptyMap(),
            config = currentConfig,
        )

        if (decision.action != StreamProxyAction.PROXY) {
            logDecision(decision)
            return null
        }

        return try {
            val response = fetcher.fetch(
                request = request,
                decision = decision,
                config = currentConfig,
                router = router,
            )

            if (response == null) {
                log(
                    "matched type=${decision.requestType.logName} " +
                        "channel=${decision.channel ?: ""} action=fallback " +
                        "reason=proxy_failed",
                )
            }

            response
        } catch (error: Exception) {
            log(
                "matched type=${decision.requestType.logName} " +
                    "channel=${decision.channel ?: ""} action=fallback " +
                    "reason=${error.javaClass.simpleName}",
            )
            null
        }
    }

    private fun logDecision(decision: StreamProxyDecision) {
        log(
            "matched type=${decision.requestType.logName} " +
                "channel=${decision.channel ?: ""} " +
                "action=${decision.action.logName} " +
                "reason=${decision.reason ?: "none"}",
        )
    }

    private fun log(message: String) {
        if (config.debugLogging) {
            Log.d(LOG_TAG, message)
        }
    }

    private fun installDocumentStartScript() {
        val view = webView ?: return
        removeDocumentStartScript()
        documentStartSupported = WebViewFeature.isFeatureSupported(
            WebViewFeature.DOCUMENT_START_SCRIPT,
        )

        if (!config.enabled) return

        if (!documentStartSupported) {
            log("page_hook action=skip reason=document_start_unsupported")
            return
        }

        try {
            documentStartScript = WebViewCompat.addDocumentStartJavaScript(
                view,
                StreamProxyPageScript.create(config),
                setOf(
                    "https://player.twitch.tv",
                    "https://www.twitch.tv",
                    "https://m.twitch.tv",
                    "https://*.twitch.tv",
                ),
            )
            log("page_hook action=installed")
        } catch (error: Exception) {
            documentStartSupported = false
            log("page_hook action=install_failed reason=${error.javaClass.simpleName}")
        }
    }

    private fun removeDocumentStartScript() {
        try {
            documentStartScript?.remove()
        } catch (error: Exception) {
            log("page_hook action=remove_failed reason=${error.javaClass.simpleName}")
        } finally {
            documentStartScript = null
        }
    }

    companion object {
        private const val LOG_TAG = "FrostyStreamProxy"
    }
}
