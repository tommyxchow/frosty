package com.namecallfilter.glacier.streamproxy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class StreamProxyRequestRouterTest {
    @Test
    fun routesFlaggedUsherRequestsThroughProxy() {
        val router = StreamProxyRequestRouter()
        val decision = router.route(
            url = "https://usher.ttvnw.net/api/channel/hls/Streamer.m3u8?player_type=site",
            method = "GET",
            headers = mapOf("Accept" to "application/vnd.apple.mpegurl,TTV-LOL-PRO"),
            config = enabledConfig(),
        )

        assertEquals(StreamProxyRequestType.USHER, decision.requestType)
        assertEquals(StreamProxyAction.PROXY, decision.action)
        assertEquals("streamer", decision.channel)
    }

    @Test
    fun remembersLatestUsherManifestUrlFromManifestResponses() {
        val router = StreamProxyRequestRouter()
        val manifestUrl = "https://usher.ttvnw.net/api/channel/hls/Streamer.m3u8?token=abc"
        val manifestBody = """
            #EXTM3U
            #EXT-X-STREAM-INF:BANDWIDTH=100,RESOLUTION=640x360
            https://video-weaver.example.hls.ttvnw.net/v1/playlist/live.m3u8
        """.trimIndent()

        router.rememberUsherManifest(
            channel = "Streamer",
            manifestUrl = manifestUrl,
            manifestBody = manifestBody,
        )

        assertEquals(manifestUrl, router.latestUsherManifestUrl("streamer"))
    }

    @Test
    fun remembersLatestUsherManifestUrlFromObservedRequests() {
        val router = StreamProxyRequestRouter()
        val manifestUrl = "https://usher.ttvnw.net/api/channel/hls/Streamer.m3u8?token=abc"

        router.rememberUsherRequest(manifestUrl)

        assertEquals(manifestUrl, router.latestUsherManifestUrl("streamer"))
        assertNull(router.latestUsherManifestUrl("other_streamer"))
    }

    private fun enabledConfig() = StreamProxyConfig(
        mode = StreamProxyMode.TTV_LOL_PRO,
        currentChannelLogin = "streamer",
        proxyUrls = listOf("proxy.example.com:3128"),
        whitelistedChannels = emptySet(),
        debugLogging = false,
    )
}
