package com.namecallfilter.glacier.cast

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class CastReceiverMessageParserTest {
    @Test
    fun parsesLatencyStatusMessage() {
        val status = CastReceiverMessageParser.parse(
            """{"type":"status","latencyMs":7420,"playerState":"PLAYING","currentTimeSec":12.5,"rangeStartSec":3,"rangeEndSec":19.92,"targetLatencySec":1,"maxLatencySec":5,"playbackRate":1.075,"requestedPlaybackRate":1.075,"correction":"playbackRateCatchup","latencyBeforeCorrectionMs":6120}""",
        )

        assertEquals(7420L, status?.latencyMs)
        assertEquals("PLAYING", status?.playerState)
        assertEquals(12.5, status?.currentTimeSec ?: 0.0, 0.001)
        assertEquals(3.0, status?.rangeStartSec ?: 0.0, 0.001)
        assertEquals(19.92, status?.rangeEndSec ?: 0.0, 0.001)
        assertEquals(1.0, status?.targetLatencySec ?: 0.0, 0.001)
        assertEquals(5.0, status?.maxLatencySec ?: 0.0, 0.001)
        assertEquals(1.075, status?.playbackRate ?: 0.0, 0.001)
        assertEquals(1.075, status?.requestedPlaybackRate ?: 0.0, 0.001)
        assertEquals("playbackRateCatchup", status?.correction)
        assertEquals(6120L, status?.latencyBeforeCorrectionMs)
    }

    @Test
    fun ignoresMalformedMessages() {
        assertNull(CastReceiverMessageParser.parse("not-json"))
        assertNull(CastReceiverMessageParser.parse("""{"type":"unknown"}"""))
    }
}
