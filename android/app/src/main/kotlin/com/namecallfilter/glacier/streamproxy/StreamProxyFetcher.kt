package com.namecallfilter.glacier.streamproxy

import android.util.Base64
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.FilterInputStream
import java.io.InputStream
import java.net.Authenticator
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.PasswordAuthentication
import java.net.Proxy
import java.net.Socket
import java.net.URL
import java.nio.charset.Charset
import java.nio.charset.StandardCharsets
import java.util.Locale
import javax.net.ssl.SSLSocket
import javax.net.ssl.SSLSocketFactory

class StreamProxyFetcher(
    private val log: (String) -> Unit,
) {
    private val acceptFlag = "TTV-LOL-PRO"
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
        "accept-encoding",
    )

    fun fetch(
        request: WebResourceRequest,
        decision: StreamProxyDecision,
        config: StreamProxyConfig,
        router: StreamProxyRequestRouter,
    ): WebResourceResponse? {
        if (config.proxyUrls.isEmpty()) {
            return if (decision.flagged) {
                fetchDirect(request, decision, router, "no_proxy_urls")
            } else {
                null
            }
        }

        val requestUrl = request.url.toString()
        config.proxyUrls.forEachIndexed { index, proxyUrl ->
            val parsedProxy = parseProxyUrl(proxyUrl)
            if (parsedProxy == null) {
                log(
                    "matched type=${decision.requestType.logName} " +
                        "channel=${decision.channel ?: ""} action=skip " +
                        "proxy=${index + 1} reason=invalid_proxy",
                )
                return@forEachIndexed
            }

            var connection: HttpURLConnection? = null
            try {
                log(
                    "matched type=${decision.requestType.logName} " +
                        "channel=${decision.channel ?: ""} action=proxy " +
                        "proxy=${index + 1} host=${parsedProxy.displayHost} " +
                        "auth=${parsedProxy.hasCredentials}",
                )

                if (URL(requestUrl).protocol.equals("https", ignoreCase = true)) {
                    return fetchHttpsViaConnect(
                        request = request,
                        decision = decision,
                        proxy = parsedProxy,
                        router = router,
                    )
                }

                return ProxyAuthenticator.withCredentials(parsedProxy) {
                    val proxy = Proxy(
                        Proxy.Type.HTTP,
                        InetSocketAddress(parsedProxy.host, parsedProxy.port),
                    )
                    connection = URL(requestUrl).openConnection(proxy) as HttpURLConnection
                    connection.connectTimeout = CONNECT_TIMEOUT_MS
                    connection.readTimeout = READ_TIMEOUT_MS
                    connection.instanceFollowRedirects = true
                    connection.requestMethod = request.method
                    copyRequestHeaders(request.requestHeaders ?: emptyMap(), connection)
                    setProxyAuthorization(parsedProxy, connection)

                    val statusCode = connection.responseCode
                    val responseStream = if (request.method.equals("HEAD", ignoreCase = true)) {
                        ByteArrayInputStream(ByteArray(0))
                    } else if (statusCode >= 400) {
                        connection.errorStream ?: ByteArrayInputStream(ByteArray(0))
                    } else {
                        connection.inputStream
                    }

                    val contentType = connection.contentType
                    val responseHeaders = responseHeaders(connection)
                    val mimeType = mimeTypeFrom(contentType, requestUrl)
                    val encoding = encodingFrom(contentType)
                    val reason = connection.responseMessage ?: "OK"

                    if (
                        decision.requestType == StreamProxyRequestType.USHER &&
                        statusCode in 200..399 &&
                        !request.method.equals("HEAD", ignoreCase = true)
                    ) {
                        val bytes = responseStream.readBytes()
                        val body = decodeBody(bytes, encoding)
                        router.rememberUsherManifest(
                            channel = decision.channel,
                            manifestUrl = requestUrl,
                            manifestBody = body,
                        )
                        connection.disconnect()

                        return@withCredentials WebResourceResponse(
                            mimeType,
                            encoding,
                            statusCode,
                            reason,
                            responseHeaders,
                            ByteArrayInputStream(bytes),
                        )
                    }

                    WebResourceResponse(
                        mimeType,
                        encoding,
                        statusCode,
                        reason,
                        responseHeaders,
                        responseStream,
                    )
                }
            } catch (error: Exception) {
                connection?.disconnect()
                log(
                    "matched type=${decision.requestType.logName} " +
                        "channel=${decision.channel ?: ""} action=proxy_failed " +
                        "proxy=${index + 1} host=${parsedProxy.displayHost} " +
                        "reason=${formatError(error)}",
                )
            }
        }

        return if (decision.flagged) {
            fetchDirect(request, decision, router, "proxy_failed")
        } else {
            null
        }
    }

    private fun fetchDirect(
        request: WebResourceRequest,
        decision: StreamProxyDecision,
        router: StreamProxyRequestRouter,
        reason: String,
    ): WebResourceResponse? {
        var connection: HttpURLConnection? = null
        val requestUrl = request.url.toString()

        return try {
            log(
                "matched type=${decision.requestType.logName} " +
                    "channel=${decision.channel ?: ""} action=direct_fallback " +
                    "reason=$reason",
            )
            connection = URL(requestUrl).openConnection() as HttpURLConnection
            connection.connectTimeout = CONNECT_TIMEOUT_MS
            connection.readTimeout = READ_TIMEOUT_MS
            connection.instanceFollowRedirects = true
            connection.requestMethod = request.method
            copyRequestHeaders(request.requestHeaders ?: emptyMap(), connection)

            val statusCode = connection.responseCode
            val responseStream = if (request.method.equals("HEAD", ignoreCase = true)) {
                ByteArrayInputStream(ByteArray(0))
            } else if (statusCode >= 400) {
                connection.errorStream ?: ByteArrayInputStream(ByteArray(0))
            } else {
                connection.inputStream
            }

            val contentType = connection.contentType
            val responseHeaders = responseHeaders(connection)
            val mimeType = mimeTypeFrom(contentType, requestUrl)
            val encoding = encodingFrom(contentType)
            val reasonPhrase = connection.responseMessage ?: "OK"

            if (
                decision.requestType == StreamProxyRequestType.USHER &&
                statusCode in 200..399 &&
                !request.method.equals("HEAD", ignoreCase = true)
            ) {
                val bytes = responseStream.readBytes()
                val body = decodeBody(bytes, encoding)
                router.rememberUsherManifest(
                    channel = decision.channel,
                    manifestUrl = requestUrl,
                    manifestBody = body,
                )
                connection.disconnect()

                WebResourceResponse(
                    mimeType,
                    encoding,
                    statusCode,
                    reasonPhrase,
                    responseHeaders,
                    ByteArrayInputStream(bytes),
                )
            } else {
                WebResourceResponse(
                    mimeType,
                    encoding,
                    statusCode,
                    reasonPhrase,
                    responseHeaders,
                    responseStream,
                )
            }
        } catch (error: Exception) {
            connection?.disconnect()
            log(
                "matched type=${decision.requestType.logName} " +
                    "channel=${decision.channel ?: ""} action=direct_failed " +
                    "reason=${formatError(error)}",
            )
            null
        }
    }

    private fun fetchHttpsViaConnect(
        request: WebResourceRequest,
        decision: StreamProxyDecision,
        proxy: ParsedProxy,
        router: StreamProxyRequestRouter,
    ): WebResourceResponse {
        val requestUrl = request.url.toString()
        val url = URL(requestUrl)
        val port = if (url.port != -1) url.port else 443

        val proxySocket = Socket()
        proxySocket.connect(
            InetSocketAddress(proxy.host, proxy.port),
            CONNECT_TIMEOUT_MS,
        )
        proxySocket.soTimeout = READ_TIMEOUT_MS

        try {
            val proxyInput = proxySocket.getInputStream().buffered()
            val proxyOutput = proxySocket.getOutputStream()
            writeConnectRequest(proxyOutput, proxy, url.host, port)
            val connectStatus = readStatusLine(proxyInput, "proxy CONNECT")
            val connectHeaders = readHeaders(proxyInput)
            if (connectStatus.statusCode !in 200..299) {
                throw java.io.IOException(
                    "proxy CONNECT ${connectStatus.statusCode} " +
                        "${connectStatus.reason} headers=${connectHeaders.keys.joinToString(",")}",
                )
            }

            val sslSocketFactory = SSLSocketFactory.getDefault() as SSLSocketFactory
            val sslSocket = sslSocketFactory.createSocket(
                proxySocket,
                url.host,
                port,
                true,
            ) as SSLSocket
            sslSocket.soTimeout = READ_TIMEOUT_MS
            sslSocket.startHandshake()

            val responseInput = sslSocket.getInputStream().buffered()
            val responseOutput = sslSocket.getOutputStream()
            writeOriginRequest(
                output = responseOutput,
                request = request,
                url = url,
            )

            val status = readStatusLine(responseInput, "origin response")
            val headers = readHeaders(responseInput)
            val bodyStream = responseBodyStream(
                input = responseInput,
                headers = headers,
                closeSocket = sslSocket,
                isHead = request.method.equals("HEAD", ignoreCase = true),
            )
            val contentType = headers.entries
                .firstOrNull { it.key.equals("content-type", ignoreCase = true) }
                ?.value
            val mimeType = mimeTypeFrom(contentType, requestUrl)
            val encoding = encodingFrom(contentType)
            val responseHeaders = headers
                .filterKeys { !it.equals("transfer-encoding", ignoreCase = true) }

            if (
                decision.requestType == StreamProxyRequestType.USHER &&
                status.statusCode in 200..399 &&
                !request.method.equals("HEAD", ignoreCase = true)
            ) {
                val bytes = bodyStream.readBytes()
                val body = decodeBody(bytes, encoding)
                router.rememberUsherManifest(
                    channel = decision.channel,
                    manifestUrl = requestUrl,
                    manifestBody = body,
                )
                sslSocket.close()

                return WebResourceResponse(
                    mimeType,
                    encoding,
                    status.statusCode,
                    status.reason,
                    responseHeaders,
                    ByteArrayInputStream(bytes),
                )
            }

            return WebResourceResponse(
                mimeType,
                encoding,
                status.statusCode,
                status.reason,
                responseHeaders,
                bodyStream,
            )
        } catch (error: Exception) {
            proxySocket.close()
            throw error
        }
    }

    private fun copyRequestHeaders(
        headers: Map<String, String>,
        connection: HttpURLConnection,
    ) {
        copyRequestHeaders(headers) { name, value ->
            connection.setRequestProperty(name, value)
        }
    }

    private fun copyRequestHeaders(
        headers: Map<String, String>,
        appendHeader: (String, String) -> Unit,
    ) {
        headers.forEach { (name, value) ->
            if (!hopByHopHeaders.contains(name.lowercase(Locale.US))) {
                sanitizedHeaderValue(name, value)?.let { sanitizedValue ->
                    appendHeader(name, sanitizedValue)
                }
            }
        }
    }

    private fun sanitizedHeaderValue(name: String, value: String): String? {
        if (!name.equals("accept", ignoreCase = true)) return value

        val sanitized = value
            .replace(acceptFlag, "", ignoreCase = true)
            .trim()

        return sanitized.takeIf(String::isNotEmpty)
    }

    private fun setProxyAuthorization(
        proxy: ParsedProxy,
        connection: HttpURLConnection,
    ) {
        connection.setRequestProperty(
            "Proxy-Authorization",
            proxyAuthorizationHeader(proxy) ?: return,
        )
    }

    private fun proxyAuthorizationHeader(proxy: ParsedProxy): String? {
        val username = proxy.username ?: return null
        val password = proxy.password ?: ""
        val credentials = "$username:$password"
        val encodedCredentials = Base64.encodeToString(
            credentials.toByteArray(Charsets.UTF_8),
            Base64.NO_WRAP,
        )
        return "Basic $encodedCredentials"
    }

    private fun writeConnectRequest(
        output: java.io.OutputStream,
        proxy: ParsedProxy,
        host: String,
        port: Int,
    ) {
        val request = buildString {
            append("CONNECT ")
            append(host)
            append(":")
            append(port)
            append(" HTTP/1.1\r\n")
            append("Host: ")
            append(host)
            append(":")
            append(port)
            append("\r\n")
            append("Connection: keep-alive\r\n")
            proxyAuthorizationHeader(proxy)?.let { authorization ->
                append("Proxy-Authorization: ")
                append(authorization)
                append("\r\n")
            }
            append("\r\n")
        }
        output.write(request.toByteArray(StandardCharsets.ISO_8859_1))
        output.flush()
    }

    private fun writeOriginRequest(
        output: java.io.OutputStream,
        request: WebResourceRequest,
        url: URL,
    ) {
        val path = url.file.takeIf(String::isNotEmpty) ?: "/"
        val requestText = buildString {
            append(request.method.uppercase(Locale.US))
            append(" ")
            append(path)
            append(" HTTP/1.1\r\n")
            append("Host: ")
            append(url.host)
            if (url.port != -1 && url.port != 443) {
                append(":")
                append(url.port)
            }
            append("\r\n")
            copyRequestHeaders(request.requestHeaders ?: emptyMap()) { name, value ->
                append(name)
                append(": ")
                append(value)
                append("\r\n")
            }
            append("Connection: close\r\n")
            append("\r\n")
        }
        output.write(requestText.toByteArray(StandardCharsets.ISO_8859_1))
        output.flush()
    }

    private fun responseHeaders(connection: HttpURLConnection): Map<String, String> {
        return connection.headerFields
            .mapNotNull { (name, values) ->
                val value = values?.firstOrNull()
                if (name != null && value != null) {
                    name to value
                } else {
                    null
                }
            }
            .toMap()
    }

    private fun readStatusLine(
        input: java.io.BufferedInputStream,
        context: String,
    ): HttpStatus {
        val statusLine = readAsciiLine(input)
            ?: throw java.io.IOException("$context missing status line")
        val parts = statusLine.split(" ", limit = 3)
        val statusCode = parts.getOrNull(1)?.toIntOrNull()
            ?: throw java.io.IOException("$context invalid status line '$statusLine'")
        return HttpStatus(
            statusCode = statusCode,
            reason = parts.getOrNull(2)?.takeIf(String::isNotEmpty) ?: "OK",
        )
    }

    private fun readHeaders(input: java.io.BufferedInputStream): Map<String, String> {
        val headers = linkedMapOf<String, String>()
        while (true) {
            val line = readAsciiLine(input) ?: break
            if (line.isEmpty()) break

            val separatorIndex = line.indexOf(":")
            if (separatorIndex <= 0) continue

            val name = line.substring(0, separatorIndex).trim()
            val value = line.substring(separatorIndex + 1).trim()
            headers[name] = value
        }
        return headers
    }

    private fun readAsciiLine(input: java.io.BufferedInputStream): String? {
        val buffer = ByteArrayOutputStream()
        while (true) {
            val next = input.read()
            if (next == -1) {
                if (buffer.size() == 0) return null
                break
            }
            if (next == '\n'.code) break
            if (next != '\r'.code) {
                buffer.write(next)
            }
        }
        return buffer.toString(StandardCharsets.ISO_8859_1.name())
    }

    private fun responseBodyStream(
        input: java.io.BufferedInputStream,
        headers: Map<String, String>,
        closeSocket: Socket,
        isHead: Boolean,
    ): InputStream {
        if (isHead) {
            closeSocket.close()
            return ByteArrayInputStream(ByteArray(0))
        }

        val transferEncoding = headers.entries
            .firstOrNull { it.key.equals("transfer-encoding", ignoreCase = true) }
            ?.value

        val bodyStream = if (transferEncoding?.contains("chunked", ignoreCase = true) == true) {
            ChunkedInputStream(input)
        } else {
            input
        }

        return ClosingInputStream(bodyStream, closeSocket)
    }

    private fun mimeTypeFrom(contentType: String?, url: String): String? {
        val mimeType = contentType
            ?.substringBefore(";")
            ?.trim()
            ?.takeIf(String::isNotEmpty)

        if (mimeType != null) return mimeType

        return when {
            url.endsWith(".m3u8", ignoreCase = true) -> "application/vnd.apple.mpegurl"
            url.endsWith(".ts", ignoreCase = true) -> "video/mp2t"
            url.endsWith(".mp4", ignoreCase = true) -> "video/mp4"
            else -> null
        }
    }

    private fun encodingFrom(contentType: String?): String? {
        return contentType
            ?.split(";")
            ?.map(String::trim)
            ?.firstOrNull { it.startsWith("charset=", ignoreCase = true) }
            ?.substringAfter("=")
            ?.takeIf(String::isNotEmpty)
    }

    private fun decodeBody(bytes: ByteArray, encoding: String?): String {
        return try {
            bytes.toString(Charset.forName(encoding ?: "UTF-8"))
        } catch (_: Exception) {
            bytes.toString(Charsets.UTF_8)
        }
    }

    companion object {
        private const val CONNECT_TIMEOUT_MS = 8000
        private const val READ_TIMEOUT_MS = 15000

        private fun formatError(error: Exception): String {
            val message = error.message
                ?.replace(Regex("\\s+"), " ")
                ?.take(180)
                ?.let { ":$it" }
                ?: ""
            return "${error.javaClass.simpleName}$message"
        }
    }

    private data class HttpStatus(
        val statusCode: Int,
        val reason: String,
    )
}

private class ClosingInputStream(
    delegate: InputStream,
    private val socket: Socket,
) : FilterInputStream(delegate) {
    override fun close() {
        try {
            super.close()
        } finally {
            socket.close()
        }
    }
}

private class ChunkedInputStream(
    private val input: java.io.BufferedInputStream,
) : InputStream() {
    private var remainingInChunk = 0
    private var done = false

    override fun read(): Int {
        if (!prepareChunk()) return -1

        val value = input.read()
        if (value == -1) {
            done = true
            return -1
        }

        remainingInChunk -= 1
        if (remainingInChunk == 0) {
            readAsciiLine(input)
        }
        return value
    }

    override fun read(buffer: ByteArray, offset: Int, length: Int): Int {
        if (!prepareChunk()) return -1

        val count = input.read(buffer, offset, minOf(length, remainingInChunk))
        if (count == -1) {
            done = true
            return -1
        }

        remainingInChunk -= count
        if (remainingInChunk == 0) {
            readAsciiLine(input)
        }
        return count
    }

    private fun prepareChunk(): Boolean {
        if (done) return false
        if (remainingInChunk > 0) return true

        val chunkHeader = readAsciiLine(input) ?: run {
            done = true
            return false
        }
        val chunkSize = chunkHeader
            .substringBefore(";")
            .trim()
            .toIntOrNull(16)
            ?: throw java.io.IOException("invalid chunk size '$chunkHeader'")

        if (chunkSize == 0) {
            while (true) {
                val trailerLine = readAsciiLine(input) ?: break
                if (trailerLine.isEmpty()) break
            }
            done = true
            return false
        }

        remainingInChunk = chunkSize
        return true
    }

    private fun readAsciiLine(input: java.io.BufferedInputStream): String? {
        val buffer = ByteArrayOutputStream()
        while (true) {
            val next = input.read()
            if (next == -1) {
                if (buffer.size() == 0) return null
                break
            }
            if (next == '\n'.code) break
            if (next != '\r'.code) {
                buffer.write(next)
            }
        }
        return buffer.toString(StandardCharsets.ISO_8859_1.name())
    }
}

private object ProxyAuthenticator : Authenticator() {
    private val credentials = ThreadLocal<PasswordAuthentication?>()

    init {
        System.setProperty("jdk.http.auth.tunneling.disabledSchemes", "")
        Authenticator.setDefault(this)
    }

    fun <T> withCredentials(proxy: ParsedProxy, block: () -> T): T {
        credentials.set(proxy.passwordAuthentication)
        try {
            return block()
        } finally {
            credentials.remove()
        }
    }

    override fun getPasswordAuthentication(): PasswordAuthentication? {
        if (requestorType != RequestorType.PROXY) return null
        return credentials.get()
    }
}
