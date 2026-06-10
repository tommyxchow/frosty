package com.namecallfilter.glacier.streamproxy

import java.util.Locale

object CastRelayUpstreamHeaders {
    fun build(
        requestHeaders: Map<String, String>,
        config: StreamProxyConfig,
    ): Map<String, String> {
        val headers = linkedMapOf<String, String>()
        val requestHeaderLookup = requestHeaders.entries.associateBy {
            it.key.lowercase(Locale.US)
        }

        headers["Accept"] = acceptHeader(
            requestHeaderLookup["accept"]?.value,
            config,
        )
        headers["User-Agent"] = DEFAULT_USER_AGENT

        passthroughHeaderNames.forEach { headerName ->
            requestHeaderLookup[headerName.lowercase(Locale.US)]
                ?.value
                ?.takeIf(String::isNotBlank)
                ?.let { value -> headers[headerName] = value }
        }

        return headers
    }

    private fun acceptHeader(
        requestAccept: String?,
        config: StreamProxyConfig,
    ): String {
        val accept = requestAccept
            ?.takeIf(String::isNotBlank)
            ?: DEFAULT_ACCEPT

        if (!config.enabled || accept.contains(ACCEPT_FLAG, ignoreCase = true)) {
            return accept
        }

        return "$accept,$ACCEPT_FLAG"
    }

    private const val ACCEPT_FLAG = "TTV-LOL-PRO"
    private const val DEFAULT_ACCEPT = "application/vnd.apple.mpegurl,application/x-mpegURL,*/*"
    private const val DEFAULT_USER_AGENT =
        "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 " +
            "(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"

    private val passthroughHeaderNames = listOf(
        "Accept-Language",
        "Range",
        "If-Match",
        "If-None-Match",
        "If-Modified-Since",
        "If-Unmodified-Since",
    )
}
