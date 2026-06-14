package com.namecallfilter.glacier.streamproxy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.BufferedInputStream
import java.io.Closeable
import java.io.OutputStream
import java.net.HttpURLConnection
import java.net.InetAddress
import java.net.Proxy
import java.net.ServerSocket
import java.net.Socket
import java.net.SocketTimeoutException
import java.net.URI
import java.net.URL
import java.nio.charset.StandardCharsets
import java.util.Locale
import java.util.concurrent.CountDownLatch
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit

class CastRelayServerTest {
    @Test
    fun forwardsRelayQueryParamsToUpstreamPlaylistWhilePreservingOriginalQuery() {
        RawUpstreamServer { _, output ->
            writeHttpResponse(
                output = output,
                contentType = "application/vnd.apple.mpegurl",
                body = """
                    #EXTM3U
                    #EXT-X-TARGETDURATION:2
                """.trimIndent(),
            )
        }.use { upstream ->
            CastRelayServer(log = {}).use { relay ->
                val sourceUrl = upstream.url("/live/index.m3u8?token=abc&sig=def")
                val relayUrl = localRelayUrl(
                    relay.relayUrlFor(sourceUrl),
                    "?_HLS_msn=42&_HLS_part=3&_HLS_skip=YES",
                )

                val body = get(relayUrl).body

                assertTrue(body.contains("#EXTM3U"))
                val request = upstream.takeRequest()
                assertEquals("/live/index.m3u8", URI("http://upstream${request.target}").path)
                assertEquals(
                    "token=abc&sig=def&_HLS_msn=42&_HLS_part=3&_HLS_skip=YES",
                    URI("http://upstream${request.target}").rawQuery,
                )
            }
        }
    }

    @Test
    fun forcesFreshUpstreamPlaylistRequestsButKeepsRangeForMediaRequests() {
        RawUpstreamServer { request, output ->
            val contentType = if (request.target.contains(".m3u8")) {
                "application/vnd.apple.mpegurl"
            } else {
                "video/mp2t"
            }
            val body = if (request.target.contains(".m3u8")) {
                "#EXTM3U\n#EXT-X-TARGETDURATION:2\n"
            } else {
                "segment"
            }
            writeHttpResponse(output, contentType, body)
        }.use { upstream ->
            CastRelayServer(log = {}).use { relay ->
                val playlistRelayUrl = localRelayUrl(
                    relay.relayUrlFor(upstream.url("/live/index.m3u8?token=abc")),
                )
                get(
                    playlistRelayUrl,
                    headers = mapOf(
                        "Range" to "bytes=0-99",
                        "If-Match" to "\"old-match\"",
                        "If-None-Match" to "\"old-none-match\"",
                        "If-Modified-Since" to "Wed, 21 Oct 2015 07:28:00 GMT",
                        "If-Unmodified-Since" to "Wed, 21 Oct 2015 07:28:00 GMT",
                    ),
                )

                val playlistRequest = upstream.takeRequest()
                assertFalse(playlistRequest.hasHeader("Range"))
                assertFalse(playlistRequest.hasHeader("If-Match"))
                assertFalse(playlistRequest.hasHeader("If-None-Match"))
                assertFalse(playlistRequest.hasHeader("If-Modified-Since"))
                assertFalse(playlistRequest.hasHeader("If-Unmodified-Since"))
                assertEquals(
                    "no-cache, no-store, max-age=0",
                    playlistRequest.header("Cache-Control"),
                )
                assertEquals("no-cache", playlistRequest.header("Pragma"))

                val mediaRelayUrl = localRelayUrl(
                    relay.relayUrlFor(upstream.url("/segment.ts")),
                )
                get(mediaRelayUrl, headers = mapOf("Range" to "bytes=0-99"))

                val mediaRequest = upstream.takeRequest()
                assertEquals("bytes=0-99", mediaRequest.header("Range"))
            }
        }
    }

    @Test
    fun streamsMediaResponsesBeforeUpstreamBodyCompletes() {
        val firstChunkWritten = CountDownLatch(1)
        val releaseRest = CountDownLatch(1)

        RawUpstreamServer { _, output ->
            output.write(
                (
                    "HTTP/1.1 200 OK\r\n" +
                        "Content-Type: video/mp2t\r\n" +
                        "Content-Length: 6\r\n" +
                        "\r\n"
                    )
                    .toByteArray(StandardCharsets.ISO_8859_1),
            )
            output.write("abc".toByteArray(StandardCharsets.ISO_8859_1))
            output.flush()
            firstChunkWritten.countDown()
            assertTrue(releaseRest.await(3, TimeUnit.SECONDS))
            output.write("def".toByteArray(StandardCharsets.ISO_8859_1))
            output.flush()
        }.use { upstream ->
            CastRelayServer(log = {}).use { relay ->
                val relayUri = URI(localRelayUrl(relay.relayUrlFor(upstream.url("/segment.ts"))))

                Socket("127.0.0.1", relayUri.port).use { socket ->
                    socket.soTimeout = 1000
                    socket.getOutputStream().write(
                        (
                            "GET ${relayUri.rawPath} HTTP/1.1\r\n" +
                                "Host: 127.0.0.1:${relayUri.port}\r\n" +
                                "\r\n"
                            )
                            .toByteArray(StandardCharsets.ISO_8859_1),
                    )
                    socket.getOutputStream().flush()

                    assertTrue(firstChunkWritten.await(2, TimeUnit.SECONDS))

                    try {
                        val input = socket.getInputStream().buffered()
                        assertEquals("HTTP/1.1 200 OK", readAsciiLine(input))
                        val headers = readHeaders(input)
                        assertEquals("6", header(headers, "Content-Length"))

                        val firstChunk = ByteArray(3)
                        readFully(input, firstChunk)
                        assertEquals("abc", firstChunk.toString(StandardCharsets.ISO_8859_1))
                    } catch (error: SocketTimeoutException) {
                        throw AssertionError(
                            "relay buffered the media body instead of sending response headers",
                            error,
                        )
                    } finally {
                        releaseRest.countDown()
                    }
                }
            }
        }
    }

    @Test
    fun logsRelayTimingForMediaResponses() {
        val logs = mutableListOf<String>()

        RawUpstreamServer { _, output ->
            writeHttpResponse(
                output = output,
                contentType = "video/mp2t",
                body = "segment",
            )
        }.use { upstream ->
            CastRelayServer(log = logs::add).use { relay ->
                val relayUrl = localRelayUrl(
                    relay.relayUrlFor(upstream.url("/segment.ts")),
                )

                val response = get(relayUrl)

                assertEquals("segment", response.body)
                val responseLog = logs.firstOrNull { log ->
                    log.contains("cast_relay action=response") &&
                        log.contains("playlist=false")
                } ?: error("Expected media response timing log in $logs")

                assertTrue(responseLog.contains("upstream_connect_ms="))
                assertTrue(responseLog.contains("upstream_first_byte_ms="))
                assertTrue(responseLog.contains("total_ms="))
                assertTrue(responseLog.contains("bytes=7"))
                assertTrue(responseLog.contains("playlist=false"))
            }
        }
    }

    @Test
    fun logsRelayTimingAndLiveEdgeMetadataForPlaylists() {
        val logs = mutableListOf<String>()

        RawUpstreamServer { _, output ->
            writeHttpResponse(
                output = output,
                contentType = "application/vnd.apple.mpegurl",
                body = """
                    #EXTM3U
                    #EXT-X-MEDIA-SEQUENCE:777
                    #EXT-X-TARGETDURATION:2
                    #EXT-X-PROGRAM-DATE-TIME:2026-06-12T10:00:00.000Z
                    #EXTINF:2.000,
                    segment-777.ts
                    #EXT-X-PROGRAM-DATE-TIME:2026-06-12T10:00:02.000Z
                    #EXTINF:2.000,
                    segment-778.ts
                """.trimIndent(),
            )
        }.use { upstream ->
            CastRelayServer(log = logs::add).use { relay ->
                val relayUrl = localRelayUrl(
                    relay.relayUrlFor(upstream.url("/live/index.m3u8")),
                )

                val response = get(relayUrl)

                assertTrue(response.body.contains("#EXTM3U"))
                val responseLog = logs.firstOrNull { log ->
                    log.contains("cast_relay action=response") &&
                        log.contains("playlist=true")
                } ?: error("Expected playlist response timing log in $logs")

                assertTrue(responseLog.contains("upstream_connect_ms="))
                assertTrue(responseLog.contains("upstream_first_byte_ms="))
                assertTrue(responseLog.contains("total_ms="))
                assertTrue(responseLog.contains("playlist=true"))
                assertTrue(responseLog.contains("media_sequence=777"))
                assertTrue(responseLog.contains("program_date_time=2026-06-12T10:00:02.000Z"))
                assertTrue(responseLog.contains("target_duration=2"))
                assertTrue(responseLog.contains("last_segment_uri=segment-778.ts"))
            }
        }
    }

    @Test
    fun rewritesPlaylistResponsesAndAppliesNoCacheHeaders() {
        RawUpstreamServer { _, output ->
            writeHttpResponse(
                output = output,
                contentType = "application/vnd.apple.mpegurl",
                body = """
                    #EXTM3U
                    #EXT-X-TARGETDURATION:2
                    #EXT-X-PART:DURATION=0.33334,URI="parts/segment-1.part0.m4s"
                    #EXT-X-PRELOAD-HINT:TYPE=PART,URI="parts/segment-2.part0.m4s"
                    #EXTINF:2.000,
                    segment-1.ts
                """.trimIndent(),
                headers = mapOf("Cache-Control" to "public, max-age=60"),
            )
        }.use { upstream ->
            CastRelayServer(log = {}).use { relay ->
                val relayUrl = localRelayUrl(
                    relay.relayUrlFor(upstream.url("/live/index.m3u8?token=abc")),
                )

                val response = get(relayUrl)

                assertEquals(
                    "no-store, no-cache, must-revalidate, max-age=0",
                    response.headers["cache-control"],
                )
                assertEquals("no-cache", response.headers["pragma"])
                assertEquals("0", response.headers["expires"])
                assertTrue(response.body.contains("#EXT-X-PART:DURATION=0.33334,URI=\""))
                assertTrue(response.body.contains("#EXT-X-PRELOAD-HINT:TYPE=PART,URI=\""))
                assertTrue(response.body.contains("/relay/"))
                assertFalse(response.body.contains("URI=\"parts/segment-1.part0.m4s\""))
                assertFalse(response.body.contains("URI=\"parts/segment-2.part0.m4s\""))
                assertFalse(response.body.contains("\nsegment-1.ts"))
            }
        }
    }

    private fun get(
        url: String,
        headers: Map<String, String> = emptyMap(),
    ): RelayResponse {
        val connection = URL(url).openConnection(Proxy.NO_PROXY) as HttpURLConnection
        connection.connectTimeout = 2000
        connection.readTimeout = 2000
        headers.forEach(connection::setRequestProperty)

        val body = connection.inputStream.use { input ->
            input.readBytes().toString(StandardCharsets.UTF_8)
        }
        val responseHeaders = connection.headerFields
            .mapNotNull { (name, values) ->
                val value = values?.firstOrNull()
                if (name != null && value != null) {
                    name.lowercase(Locale.US) to value
                } else {
                    null
                }
            }
            .toMap()
        connection.disconnect()

        return RelayResponse(body, responseHeaders)
    }

    private fun localRelayUrl(
        relayUrl: String,
        query: String = "",
    ): String {
        val uri = URI(relayUrl)
        return "http://127.0.0.1:${uri.port}${uri.rawPath}$query"
    }

    private data class RelayResponse(
        val body: String,
        val headers: Map<String, String>,
    )
}

private class RawUpstreamServer(
    private val handler: (RecordedRequest, OutputStream) -> Unit,
) : Closeable {
    private val socket = ServerSocket(0, 50, InetAddress.getByName("127.0.0.1"))
    private val requests = LinkedBlockingQueue<RecordedRequest>()
    private val acceptThread = Thread { acceptLoop() }

    init {
        acceptThread.isDaemon = true
        acceptThread.name = "CastRelayServerTestUpstream"
        acceptThread.start()
    }

    fun url(pathAndQuery: String): String {
        return "http://127.0.0.1:${socket.localPort}$pathAndQuery"
    }

    fun takeRequest(): RecordedRequest {
        return requests.poll(2, TimeUnit.SECONDS)
            ?: error("Expected upstream request")
    }

    override fun close() {
        socket.close()
    }

    private fun acceptLoop() {
        while (!socket.isClosed) {
            try {
                val client = socket.accept()
                Thread {
                    handle(client)
                }.apply {
                    isDaemon = true
                    name = "CastRelayServerTestUpstreamClient"
                    start()
                }
            } catch (_: Exception) {
                if (!socket.isClosed) throw AssertionError("Unexpected upstream accept failure")
            }
        }
    }

    private fun handle(client: Socket) {
        client.use { socket ->
            val input = socket.getInputStream().buffered()
            val requestLine = readAsciiLine(input) ?: return
            val requestLineParts = requestLine.split(" ", limit = 3)
            val headers = readHeaders(input)
            val request = RecordedRequest(
                method = requestLineParts.getOrElse(0) { "" },
                target = requestLineParts.getOrElse(1) { "" },
                headers = headers,
            )
            requests += request
            handler(request, socket.getOutputStream())
        }
    }
}

private data class RecordedRequest(
    val method: String,
    val target: String,
    val headers: Map<String, String>,
) {
    fun hasHeader(name: String): Boolean {
        return header(name) != null
    }

    fun header(name: String): String? {
        return header(headers, name)
    }
}

private fun writeHttpResponse(
    output: OutputStream,
    contentType: String,
    body: String,
    headers: Map<String, String> = emptyMap(),
) {
    val bodyBytes = body.toByteArray(StandardCharsets.UTF_8)
    val responseHeaders = buildString {
        append("HTTP/1.1 200 OK\r\n")
        append("Content-Type: ")
        append(contentType)
        append("\r\n")
        append("Content-Length: ")
        append(bodyBytes.size)
        append("\r\n")
        headers.forEach { (name, value) ->
            append(name)
            append(": ")
            append(value)
            append("\r\n")
        }
        append("\r\n")
    }

    output.write(responseHeaders.toByteArray(StandardCharsets.ISO_8859_1))
    output.write(bodyBytes)
    output.flush()
}

private fun readHeaders(input: BufferedInputStream): Map<String, String> {
    val headers = linkedMapOf<String, String>()
    while (true) {
        val line = readAsciiLine(input) ?: break
        if (line.isEmpty()) break

        val separatorIndex = line.indexOf(":")
        if (separatorIndex <= 0) continue
        headers[line.substring(0, separatorIndex).trim()] =
            line.substring(separatorIndex + 1).trim()
    }
    return headers
}

private fun readAsciiLine(input: BufferedInputStream): String? {
    val buffer = StringBuilder()
    while (true) {
        val next = input.read()
        if (next == -1) {
            if (buffer.isEmpty()) return null
            break
        }
        if (next == '\n'.code) break
        if (next != '\r'.code) {
            buffer.append(next.toChar())
        }
    }
    return buffer.toString()
}

private fun readFully(input: BufferedInputStream, buffer: ByteArray) {
    var offset = 0
    while (offset < buffer.size) {
        val count = input.read(buffer, offset, buffer.size - offset)
        if (count == -1) error("Unexpected end of stream")
        offset += count
    }
}

private fun header(headers: Map<String, String>, name: String): String? {
    return headers.entries
        .firstOrNull { (key, _) -> key.equals(name, ignoreCase = true) }
        ?.value
}
