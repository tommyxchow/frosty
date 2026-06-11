package com.namecallfilter.glacier.streamproxy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CastRelayUpstreamHeadersTest {
    @Test
    fun stripsReceiverBrowserHeadersFromUpstreamRequests() {
        val headers = CastRelayUpstreamHeaders.build(
            requestHeaders = mapOf(
                "Accept" to "*/*",
                "User-Agent" to "CrKey/1.0",
                "Origin" to "https://glacier-cast-receiver.example",
                "Referer" to "https://glacier-cast-receiver.example/",
                "Sec-Fetch-Site" to "cross-site",
                "Accept-Encoding" to "gzip",
                "Range" to "bytes=0-",
            ),
            config = disabledConfig(),
        )

        assertEquals("*/*", headers["Accept"])
        assertTrue(headers["User-Agent"].orEmpty().contains("Mozilla/5.0"))
        assertFalse(headers["User-Agent"].orEmpty().contains("CrKey"))
        assertEquals("bytes=0-", headers["Range"])
        assertFalse(headers.containsKey("Origin"))
        assertFalse(headers.containsKey("Referer"))
        assertFalse(headers.containsKey("Sec-Fetch-Site"))
        assertFalse(headers.containsKey("Accept-Encoding"))
    }

    @Test
    fun addsProxyAcceptFlagWhenProxyConfigIsEnabled() {
        val headers = CastRelayUpstreamHeaders.build(
            requestHeaders = mapOf("Accept" to "application/vnd.apple.mpegurl"),
            config = enabledConfig(),
        )

        assertEquals(
            "application/vnd.apple.mpegurl,TTV-LOL-PRO",
            headers["Accept"],
        )
    }

    @Test
    fun suppliesStableDefaultsWhenReceiverOmitsHeaders() {
        val headers = CastRelayUpstreamHeaders.build(
            requestHeaders = emptyMap(),
            config = disabledConfig(),
        )

        assertEquals(
            "application/vnd.apple.mpegurl,application/x-mpegURL,*/*",
            headers["Accept"],
        )
        assertTrue(headers["User-Agent"].orEmpty().contains("Mozilla/5.0"))
    }

    @Test
    fun forcesFreshPlaylistRequestsWithoutDroppingMediaRangeBehavior() {
        val playlistHeaders = CastRelayUpstreamHeaders.build(
            requestHeaders = mapOf(
                "Accept" to "application/vnd.apple.mpegurl",
                "Range" to "bytes=0-99",
                "If-Match" to "\"old-match\"",
                "If-None-Match" to "\"old-none-match\"",
                "If-Modified-Since" to "Wed, 21 Oct 2015 07:28:00 GMT",
                "If-Unmodified-Since" to "Wed, 21 Oct 2015 07:28:00 GMT",
            ),
            config = disabledConfig(),
            isPlaylistRequest = true,
        )

        assertFalse(playlistHeaders.containsKey("Range"))
        assertFalse(playlistHeaders.containsKey("If-Match"))
        assertFalse(playlistHeaders.containsKey("If-None-Match"))
        assertFalse(playlistHeaders.containsKey("If-Modified-Since"))
        assertFalse(playlistHeaders.containsKey("If-Unmodified-Since"))
        assertEquals("no-cache, no-store, max-age=0", playlistHeaders["Cache-Control"])
        assertEquals("no-cache", playlistHeaders["Pragma"])

        val mediaHeaders = CastRelayUpstreamHeaders.build(
            requestHeaders = mapOf("Range" to "bytes=0-99"),
            config = disabledConfig(),
            isPlaylistRequest = false,
        )

        assertEquals("bytes=0-99", mediaHeaders["Range"])
    }

    private fun disabledConfig() = StreamProxyConfig(
        mode = StreamProxyMode.OFF,
        currentChannelLogin = "streamer",
        proxyUrls = emptyList(),
        whitelistedChannels = emptySet(),
        debugLogging = false,
    )

    private fun enabledConfig() = StreamProxyConfig(
        mode = StreamProxyMode.TTV_LOL_PRO,
        currentChannelLogin = "streamer",
        proxyUrls = listOf("proxy.example.com:3128"),
        whitelistedChannels = emptySet(),
        debugLogging = false,
    )
}
