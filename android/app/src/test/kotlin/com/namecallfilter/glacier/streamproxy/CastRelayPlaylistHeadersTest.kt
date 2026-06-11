package com.namecallfilter.glacier.streamproxy

import org.junit.Assert.assertEquals
import org.junit.Test

class CastRelayPlaylistHeadersTest {
    @Test
    fun appliesNoCacheHeadersToPlaylistResponses() {
        val headers = mutableMapOf(
            "Content-Type" to "application/vnd.apple.mpegurl; charset=utf-8",
        )

        CastRelayPlaylistHeaders.applyNoCache(headers)

        assertEquals(
            "no-store, no-cache, must-revalidate, max-age=0",
            headers["Cache-Control"],
        )
        assertEquals("no-cache", headers["Pragma"])
        assertEquals("0", headers["Expires"])
    }

    @Test
    fun replacesExistingCacheHeadersForPlaylistResponses() {
        val headers = mutableMapOf(
            "Cache-Control" to "public, max-age=60",
            "Pragma" to "cache",
            "Expires" to "Wed, 21 Oct 2030 07:28:00 GMT",
        )

        CastRelayPlaylistHeaders.applyNoCache(headers)

        assertEquals(
            "no-store, no-cache, must-revalidate, max-age=0",
            headers["Cache-Control"],
        )
        assertEquals("no-cache", headers["Pragma"])
        assertEquals("0", headers["Expires"])
    }
}
