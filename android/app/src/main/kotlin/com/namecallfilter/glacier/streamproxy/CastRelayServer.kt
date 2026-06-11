package com.namecallfilter.glacier.streamproxy

import java.io.Closeable
import java.net.Inet4Address
import java.net.InetAddress
import java.net.NetworkInterface
import java.net.ServerSocket
import java.net.Socket
import java.net.URI
import java.nio.charset.Charset
import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.util.Collections
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

class CastRelayServer(
    private val log: (String) -> Unit,
) : Closeable {
    private val targets = ConcurrentHashMap<String, RelayTarget>()
    private val targetIds = ConcurrentHashMap<String, String>()
    private val fetcher = StreamProxyFetcher(log)

    @Volatile
    private var router = StreamProxyRequestRouter()

    @Volatile
    private var config = StreamProxyConfig(
        mode = StreamProxyMode.OFF,
        currentChannelLogin = "",
        proxyUrls = emptyList(),
        whitelistedChannels = emptySet(),
        debugLogging = false,
    )

    @Volatile
    private var serverSocket: ServerSocket? = null

    @Volatile
    private var baseUrl: String? = null

    fun update(
        router: StreamProxyRequestRouter,
        config: StreamProxyConfig,
    ) {
        this.router = router
        this.config = config
    }

    fun relayUrlFor(
        sourceUrl: String,
        selectedQuality: String? = null,
    ): String {
        ensureStarted()
        val relayBaseUrl = baseUrl ?: error("Cast relay did not start")
        val key = "$sourceUrl\n${selectedQuality.orEmpty()}"
        val id = targetIds.getOrPut(key) {
            stableTargetId(key)
        }
        targets[id] = RelayTarget(
            sourceUrl = sourceUrl,
            selectedQuality = selectedQuality,
        )

        return "$relayBaseUrl/relay/$id.${extensionFor(sourceUrl)}"
    }

    override fun close() {
        serverSocket?.close()
        serverSocket = null
        baseUrl = null
        targets.clear()
        targetIds.clear()
    }

    private fun ensureStarted() {
        if (serverSocket != null) return

        synchronized(this) {
            if (serverSocket != null) return

            val socket = ServerSocket(
                0,
                SERVER_BACKLOG,
                InetAddress.getByName("0.0.0.0"),
            )
            serverSocket = socket
            val relayAddress = lanAddress()
            baseUrl = "http://$relayAddress:${socket.localPort}"

            Thread {
                acceptLoop(socket)
            }.apply {
                isDaemon = true
                name = "GlacierCastRelay"
                start()
            }

            log("cast_relay action=started url=$baseUrl address=$relayAddress")
        }
    }

    private fun acceptLoop(socket: ServerSocket) {
        while (!socket.isClosed) {
            try {
                val client = socket.accept()
                Thread {
                    handleClient(client)
                }.apply {
                    isDaemon = true
                    name = "GlacierCastRelayClient"
                    start()
                }
            } catch (error: Exception) {
                if (!socket.isClosed) {
                    log("cast_relay action=accept_failed reason=${error.javaClass.simpleName}")
                }
            }
        }
    }

    private fun handleClient(socket: Socket) {
        socket.use { client ->
            try {
                val request = readRequest(client)
                    ?: return
                log(
                    "cast_relay action=request method=${request.method} " +
                        "path=${request.target.substringBefore("?")} " +
                        "from=${client.inetAddress.hostAddress}",
                )

                when (request.method.uppercase(Locale.US)) {
                    "OPTIONS" -> sendResponse(
                        socket = client,
                        statusCode = 204,
                        reasonPhrase = "No Content",
                        headers = corsHeaders(),
                        body = ByteArray(0),
                        headOnly = true,
                    )
                    "GET",
                    "HEAD" -> handleRelayRequest(client, request)
                    else -> sendError(client, 405, "Method Not Allowed")
                }
            } catch (error: Exception) {
                log("cast_relay action=request_failed reason=${error.javaClass.simpleName}")
                runCatching { sendError(client, 500, "Internal Server Error") }
            }
        }
    }

    private fun handleRelayRequest(socket: Socket, request: HttpRequest) {
        val path = request.target.substringBefore("?")
        if (!path.startsWith("/relay/")) {
            sendError(socket, 404, "Not Found")
            return
        }

        val id = path
            .removePrefix("/relay/")
            .substringBefore(".")
            .takeIf(String::isNotEmpty)
        val target = targets[id]
        if (target == null) {
            log("cast_relay action=response path=$path status=404 reason=missing_target")
            sendError(socket, 404, "Not Found")
            return
        }

        val currentConfig = config
        val requestHeaders = CastRelayUpstreamHeaders.build(
            requestHeaders = request.headers,
            config = currentConfig,
        )
        val upstreamMethod = if (request.method.equals("HEAD", ignoreCase = true)) {
            "HEAD"
        } else {
            "GET"
        }
        val upstreamRequest = StreamProxyRequest(
            url = target.sourceUrl,
            method = upstreamMethod,
            headers = requestHeaders,
        )
        val decision = router.route(
            url = target.sourceUrl,
            method = upstreamMethod,
            headers = requestHeaders,
            config = currentConfig,
        )
        val response = fetcher.fetch(
            request = upstreamRequest,
            decision = decision,
            config = currentConfig,
            router = router,
            directWhenSkipped = true,
        )

        if (response == null) {
            log("cast_relay action=response path=$path status=502 reason=upstream_null")
            sendError(socket, 502, "Bad Gateway")
            return
        }

        response.use { upstream ->
            val headOnly = request.method.equals("HEAD", ignoreCase = true)
            var body = if (headOnly) {
                ByteArray(0)
            } else {
                upstream.body.readBytes()
            }
            val headers = responseHeaders(upstream)
            var mimeType = upstream.mimeType
            var selectedQuality: String? = null

            if (!headOnly && isPlaylistResponse(target.sourceUrl, upstream)) {
                val playlist = decodeBody(body, upstream.encoding)
                val rewritten = HlsPlaylistRewriter.rewritePlaylist(
                    body = playlist,
                    baseUrl = target.sourceUrl,
                    selectedQuality = target.selectedQuality,
                    rewriteUrl = { nestedSourceUrl ->
                        relayUrlFor(nestedSourceUrl)
                    },
                )
                body = rewritten.body.toByteArray(StandardCharsets.UTF_8)
                selectedQuality = rewritten.selectedQuality
                mimeType = "application/vnd.apple.mpegurl"
                headers["Content-Type"] = "$mimeType; charset=utf-8"
                CastRelayPlaylistHeaders.applyNoCache(headers)
            } else if (mimeType != null && headers.keys.none {
                    it.equals("Content-Type", ignoreCase = true)
                }
            ) {
                headers["Content-Type"] = mimeType
            }

            headers.putAll(corsHeaders())
            headers["Content-Length"] = body.size.toString()
            log(
                "cast_relay action=response method=${request.method} " +
                    "path=$path status=${upstream.statusCode} " +
                    "source=${sourceDescription(target.sourceUrl)} " +
                    "bytes=${body.size} mime=${mimeType.orEmpty()} " +
                    "playlist=${isPlaylistResponse(target.sourceUrl, upstream)} " +
                    "selected_quality=${selectedQuality.orEmpty()}",
            )

            sendResponse(
                socket = socket,
                statusCode = upstream.statusCode,
                reasonPhrase = upstream.reasonPhrase,
                headers = headers,
                body = body,
                headOnly = headOnly,
            )
        }
    }

    private fun responseHeaders(response: StreamProxyResponse): MutableMap<String, String> {
        return response.headers
            .filterKeys { name ->
                !hopByHopHeaders.contains(name.lowercase(Locale.US))
            }
            .toMutableMap()
    }

    private fun readRequest(socket: Socket): HttpRequest? {
        val input = socket.getInputStream().buffered()
        val requestLine = readAsciiLine(input) ?: return null
        val parts = requestLine.split(" ", limit = 3)
        if (parts.size < 2) return null

        val headers = linkedMapOf<String, String>()
        while (true) {
            val line = readAsciiLine(input) ?: break
            if (line.isEmpty()) break

            val separatorIndex = line.indexOf(":")
            if (separatorIndex <= 0) continue

            headers[line.substring(0, separatorIndex).trim()] =
                line.substring(separatorIndex + 1).trim()
        }

        return HttpRequest(
            method = parts[0],
            target = parts[1],
            headers = headers,
        )
    }

    private fun sendError(
        socket: Socket,
        statusCode: Int,
        reasonPhrase: String,
    ) {
        sendResponse(
            socket = socket,
            statusCode = statusCode,
            reasonPhrase = reasonPhrase,
            headers = corsHeaders() + mapOf("Content-Type" to "text/plain; charset=utf-8"),
            body = reasonPhrase.toByteArray(StandardCharsets.UTF_8),
            headOnly = false,
        )
    }

    private fun sendResponse(
        socket: Socket,
        statusCode: Int,
        reasonPhrase: String,
        headers: Map<String, String>,
        body: ByteArray,
        headOnly: Boolean,
    ) {
        val output = socket.getOutputStream()
        val headerText = buildString {
            append("HTTP/1.1 ")
            append(statusCode)
            append(" ")
            append(reasonPhrase)
            append("\r\n")
            headers.forEach { (name, value) ->
                append(name)
                append(": ")
                append(value)
                append("\r\n")
            }
            append("Connection: close\r\n")
            append("\r\n")
        }

        output.write(headerText.toByteArray(StandardCharsets.ISO_8859_1))
        if (!headOnly) {
            output.write(body)
        }
        output.flush()
    }

    private fun corsHeaders(): Map<String, String> {
        return mapOf(
            "Access-Control-Allow-Origin" to "*",
            "Access-Control-Allow-Methods" to "GET, HEAD, OPTIONS",
            "Access-Control-Allow-Headers" to "*",
        )
    }

    private fun readAsciiLine(input: java.io.BufferedInputStream): String? {
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

    private fun isPlaylistResponse(
        sourceUrl: String,
        response: StreamProxyResponse,
    ): Boolean {
        val mimeType = response.mimeType.orEmpty()
        return mimeType.contains("mpegurl", ignoreCase = true) ||
            mimeType.contains("m3u8", ignoreCase = true) ||
            URI(sourceUrl).path?.endsWith(".m3u8", ignoreCase = true) == true
    }

    private fun decodeBody(bytes: ByteArray, encoding: String?): String {
        return try {
            bytes.toString(Charset.forName(encoding ?: "UTF-8"))
        } catch (_: Exception) {
            bytes.toString(Charsets.UTF_8)
        }
    }

    private fun stableTargetId(key: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
            .digest(key.toByteArray(StandardCharsets.UTF_8))

        return digest
            .take(12)
            .joinToString("") { byte ->
                "%02x".format(byte.toInt() and 0xff)
            }
    }

    private fun extensionFor(sourceUrl: String): String {
        val path = runCatching { URI(sourceUrl).path.orEmpty() }
            .getOrDefault("")
            .lowercase(Locale.US)

        return when {
            path.endsWith(".m3u8") -> "m3u8"
            path.endsWith(".ts") -> "ts"
            path.endsWith(".mp4") -> "mp4"
            path.endsWith(".m4s") -> "m4s"
            path.endsWith(".aac") -> "aac"
            else -> "bin"
        }
    }

    private fun sourceDescription(sourceUrl: String): String {
        return runCatching {
            val uri = URI(sourceUrl)
            "${uri.host.orEmpty()}${uri.path.orEmpty()}"
        }.getOrDefault("unknown")
    }

    private fun lanAddress(): String {
        val interfaces = runCatching {
            Collections.list(NetworkInterface.getNetworkInterfaces())
        }.getOrDefault(emptyList())

        val candidates = interfaces
            .filter { networkInterface -> networkInterface.isUp && !networkInterface.isLoopback }
            .flatMap { networkInterface ->
                Collections.list(networkInterface.inetAddresses)
                    .filterIsInstance<Inet4Address>()
                    .map { address ->
                        CastRelayLanAddressSelector.Candidate(
                            interfaceName = networkInterface.name.orEmpty(),
                            displayName = networkInterface.displayName.orEmpty(),
                            address = address,
                        )
                    }
            }
        val selected = CastRelayLanAddressSelector.select(candidates)

        return selected?.address?.hostAddress ?: "127.0.0.1"
    }

    private data class HttpRequest(
        val method: String,
        val target: String,
        val headers: Map<String, String>,
    )

    private data class RelayTarget(
        val sourceUrl: String,
        val selectedQuality: String?,
    )

    private companion object {
        private const val SERVER_BACKLOG = 32

        private val hopByHopHeaders = setOf(
            "connection",
            "content-length",
            "host",
            "keep-alive",
            "proxy-authenticate",
            "proxy-authorization",
            "te",
            "trailer",
            "transfer-encoding",
            "upgrade",
        )
    }
}

internal object CastRelayLanAddressSelector {
    data class Candidate(
        val interfaceName: String,
        val displayName: String,
        val address: Inet4Address,
    )

    fun select(candidates: List<Candidate>): Candidate? {
        return candidates
            .filter { candidate ->
                val address = candidate.address
                !address.isLoopbackAddress &&
                    !address.isLinkLocalAddress &&
                    !address.isAnyLocalAddress
            }
            .maxWithOrNull(
                compareBy<Candidate> { interfaceScore(it) }
                    .thenBy { addressScore(it.address) },
            )
    }

    private fun interfaceScore(candidate: Candidate): Int {
        val name = "${candidate.interfaceName} ${candidate.displayName}"
            .lowercase(Locale.US)

        return when {
            preferredInterfaceTokens.any { name.contains(it) } -> 3
            avoidedInterfaceTokens.any { name.contains(it) } -> 0
            else -> 1
        }
    }

    private fun addressScore(address: Inet4Address): Int {
        return when {
            address.isSiteLocalAddress -> 2
            else -> 0
        }
    }

    private val preferredInterfaceTokens = listOf(
        "wlan",
        "wifi",
        "wi-fi",
        "eth",
        "ap",
        "bridge",
        "br-",
    )

    private val avoidedInterfaceTokens = listOf(
        "rmnet",
        "cell",
        "mobile",
        "pdp",
        "ccmni",
        "wwan",
        "tun",
        "tap",
        "vpn",
        "clat",
    )
}
