package com.namecallfilter.glacier.streamproxy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class HlsPlaylistRewriterTest {
    @Test
    fun parseMasterPlaylistBuildsQualityLabelsAndAbsoluteUrls() {
        val playlist = """
            #EXTM3U
            #EXT-X-STREAM-INF:BANDWIDTH=4500000,RESOLUTION=1920x1080,FRAME-RATE=60.000,SCORE=1.0
            source/index.m3u8
            #EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,FRAME-RATE=30.000,SCORE=0.7
            720/index.m3u8
        """.trimIndent()

        val master = HlsPlaylistRewriter.parseMasterPlaylist(
            body = playlist,
            baseUrl = "https://usher.ttvnw.net/api/channel/hls/streamer.m3u8?token=abc",
        )

        assertEquals(listOf("1080p60", "720p30"), master.variants.map { it.quality })
        assertEquals(
            "https://usher.ttvnw.net/api/channel/hls/source/index.m3u8",
            master.variants[0].url,
        )
        assertEquals(
            "https://usher.ttvnw.net/api/channel/hls/720/index.m3u8",
            master.variants[1].url,
        )
    }

    @Test
    fun rewritePlaylistFiltersMasterPlaylistToSelectedQuality() {
        val playlist = """
            #EXTM3U
            #EXT-X-VERSION:3
            #EXT-X-STREAM-INF:BANDWIDTH=4500000,RESOLUTION=1920x1080,FRAME-RATE=60.000,SCORE=1.0
            source/index.m3u8
            #EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,FRAME-RATE=60.000,SCORE=0.7
            720/index.m3u8
        """.trimIndent()

        val result = HlsPlaylistRewriter.rewritePlaylist(
            body = playlist,
            baseUrl = "https://usher.ttvnw.net/api/channel/hls/streamer.m3u8",
            selectedQuality = "720p60",
            rewriteUrl = { originalUrl ->
                "http://192.168.1.10:49200/relay/${originalUrl.substringAfterLast("/")}"
            },
        )

        assertEquals("720p60", result.selectedQuality)
        assertTrue(result.body.contains("#EXT-X-VERSION:3"))
        assertTrue(result.body.contains("RESOLUTION=1280x720"))
        assertTrue(result.body.contains("http://192.168.1.10:49200/relay/index.m3u8"))
        assertFalse(result.body.contains("RESOLUTION=1920x1080"))
        assertFalse(result.body.contains("source/index.m3u8"))
    }

    @Test
    fun rewritePlaylistRewritesAllMediaPlaylistUrisThroughRelay() {
        val playlist = """
            #EXTM3U
            #EXT-X-MAP:URI="init.mp4"
            #EXT-X-KEY:METHOD=AES-128,URI="keys/key.bin"
            #EXTINF:2.000,
            segment-1.ts
            #EXTINF:2.000,
            https://video-weaver.example.hls.ttvnw.net/v1/segment-2.ts
        """.trimIndent()

        val result = HlsPlaylistRewriter.rewritePlaylist(
            body = playlist,
            baseUrl = "https://video-weaver.example.hls.ttvnw.net/v1/playlist/live.m3u8",
            selectedQuality = null,
            rewriteUrl = { originalUrl ->
                "http://phone/relay/${originalUrl.substringAfterLast("/")}"
            },
        )

        assertTrue(result.body.contains("#EXT-X-MAP:URI=\"http://phone/relay/init.mp4\""))
        assertTrue(result.body.contains("#EXT-X-KEY:METHOD=AES-128,URI=\"http://phone/relay/key.bin\""))
        assertTrue(result.body.contains("http://phone/relay/segment-1.ts"))
        assertTrue(result.body.contains("http://phone/relay/segment-2.ts"))
        assertFalse(result.body.contains("\nsegment-1.ts"))
    }

    @Test
    fun rewritePlaylistSelectsHighestVariantWhenRequested() {
        val playlist = """
            #EXTM3U
            #EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,FRAME-RATE=60.000,SCORE=0.7
            720/index.m3u8
            #EXT-X-STREAM-INF:BANDWIDTH=4500000,RESOLUTION=1920x1080,FRAME-RATE=60.000,SCORE=1.0
            source/index.m3u8
        """.trimIndent()

        val result = HlsPlaylistRewriter.rewritePlaylist(
            body = playlist,
            baseUrl = "https://usher.ttvnw.net/api/channel/hls/streamer.m3u8",
            selectedQuality = "highest",
            rewriteUrl = { "http://phone/relay/${it.substringAfterLast("/")}" },
        )

        assertEquals("1080p60", result.selectedQuality)
        assertTrue(result.body.contains("RESOLUTION=1920x1080"))
        assertFalse(result.body.contains("RESOLUTION=1280x720"))
    }
}
