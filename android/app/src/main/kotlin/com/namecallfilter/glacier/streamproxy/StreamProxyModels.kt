package com.namecallfilter.glacier.streamproxy

import java.io.Closeable
import java.io.InputStream

data class StreamProxyRequest(
    val url: String,
    val method: String,
    val headers: Map<String, String>,
)

class StreamProxyResponse(
    val mimeType: String?,
    val encoding: String?,
    val statusCode: Int,
    val reasonPhrase: String,
    val headers: Map<String, String>,
    val body: InputStream,
    private val closeHandler: (() -> Unit)? = null,
) : Closeable {
    override fun close() {
        try {
            body.close()
        } finally {
            closeHandler?.invoke()
        }
    }
}
