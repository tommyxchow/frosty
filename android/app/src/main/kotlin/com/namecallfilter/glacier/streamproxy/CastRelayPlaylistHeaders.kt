package com.namecallfilter.glacier.streamproxy

internal object CastRelayPlaylistHeaders {
    fun applyNoCache(headers: MutableMap<String, String>) {
        removeHeader(headers, "Cache-Control")
        removeHeader(headers, "Pragma")
        removeHeader(headers, "Expires")

        headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        headers["Pragma"] = "no-cache"
        headers["Expires"] = "0"
    }

    private fun removeHeader(headers: MutableMap<String, String>, name: String) {
        headers.keys
            .filter { key -> key.equals(name, ignoreCase = true) }
            .toList()
            .forEach(headers::remove)
    }
}
