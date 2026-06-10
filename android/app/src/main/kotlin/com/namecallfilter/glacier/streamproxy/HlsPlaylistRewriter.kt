package com.namecallfilter.glacier.streamproxy

import java.net.URI
import java.util.Locale
import kotlin.math.roundToInt

object HlsPlaylistRewriter {
    data class MasterPlaylist(
        val variants: List<Variant>,
    )

    data class Variant(
        val quality: String,
        val url: String,
        val streamInfoLine: String,
        val streamInfoIndex: Int,
        val uriIndex: Int,
        val bandwidth: Long?,
        val width: Int?,
        val height: Int?,
        val frameRate: Double?,
        val score: Double?,
    )

    data class RewriteResult(
        val body: String,
        val selectedQuality: String?,
    )

    fun parseMasterPlaylist(body: String, baseUrl: String): MasterPlaylist {
        return MasterPlaylist(parseVariants(body.lines(), baseUrl))
    }

    fun rewritePlaylist(
        body: String,
        baseUrl: String,
        selectedQuality: String?,
        rewriteUrl: (String) -> String,
    ): RewriteResult {
        val lines = body.lines()
        val variants = parseVariants(lines, baseUrl)

        if (variants.isNotEmpty()) {
            return rewriteMasterPlaylist(
                lines = lines,
                variants = variants,
                selectedQuality = selectedQuality,
                rewriteUrl = rewriteUrl,
            )
        }

        return RewriteResult(
            body = lines
                .map { line -> rewriteMediaPlaylistLine(line, baseUrl, rewriteUrl) }
                .joinToString("\n"),
            selectedQuality = null,
        )
    }

    private fun rewriteMasterPlaylist(
        lines: List<String>,
        variants: List<Variant>,
        selectedQuality: String?,
        rewriteUrl: (String) -> String,
    ): RewriteResult {
        val selectedVariant = selectVariant(variants, selectedQuality)
        val variantByStreamInfoIndex = variants.associateBy { it.streamInfoIndex }
        val output = mutableListOf<String>()
        var lineIndex = 0

        while (lineIndex < lines.size) {
            val variant = variantByStreamInfoIndex[lineIndex]
            if (variant == null) {
                output.add(lines[lineIndex])
                lineIndex += 1
                continue
            }

            if (selectedVariant == null || selectedVariant == variant) {
                output.add(variant.streamInfoLine)
                output.add(rewriteUrl(variant.url))
            }
            lineIndex = variant.uriIndex + 1
        }

        return RewriteResult(
            body = output.joinToString("\n"),
            selectedQuality = selectedVariant?.quality,
        )
    }

    private fun selectVariant(
        variants: List<Variant>,
        selectedQuality: String?,
    ): Variant? {
        val normalizedQuality = selectedQuality
            ?.trim()
            ?.lowercase(Locale.US)
            ?.takeIf(String::isNotEmpty)

        return when (normalizedQuality) {
            null,
            "auto" -> null
            "highest" -> variants.maxWithOrNull(
                compareBy<Variant> { it.score ?: 0.0 }
                    .thenBy { it.height ?: 0 }
                    .thenBy { it.frameRate ?: 0.0 }
                    .thenBy { it.bandwidth ?: 0L },
            )
            else -> variants.firstOrNull {
                it.quality.lowercase(Locale.US) == normalizedQuality
            }
        }
    }

    private fun rewriteMediaPlaylistLine(
        line: String,
        baseUrl: String,
        rewriteUrl: (String) -> String,
    ): String {
        val trimmed = line.trim()
        if (trimmed.isEmpty()) return line

        if (trimmed.startsWith("#")) {
            return uriAttributeRegex.replace(line) { match ->
                val originalUrl = match.groupValues[1]
                "URI=\"${rewriteUrl(resolveUrl(baseUrl, originalUrl))}\""
            }
        }

        return rewriteUrl(resolveUrl(baseUrl, trimmed))
    }

    private fun parseVariants(lines: List<String>, baseUrl: String): List<Variant> {
        val variants = mutableListOf<Variant>()
        var lineIndex = 0

        while (lineIndex < lines.size) {
            val line = lines[lineIndex].trim()
            if (!line.startsWith("#EXT-X-STREAM-INF:", ignoreCase = true)) {
                lineIndex += 1
                continue
            }

            val uriIndex = nextUriLineIndex(lines, lineIndex + 1)
            if (uriIndex == null) {
                lineIndex += 1
                continue
            }

            val attributes = parseAttributes(line.substringAfter(":"))
            val resolution = attributes["RESOLUTION"]
                ?.split("x", limit = 2)
                ?.mapNotNull { it.toIntOrNull() }
                ?.takeIf { it.size == 2 }
            val width = resolution?.getOrNull(0)
            val height = resolution?.getOrNull(1)
            val frameRate = attributes["FRAME-RATE"]?.toDoubleOrNull()
            val bandwidth = attributes["BANDWIDTH"]?.toLongOrNull()
            val score = attributes["SCORE"]?.toDoubleOrNull()

            variants += Variant(
                quality = qualityLabel(
                    height = height,
                    frameRate = frameRate,
                    bandwidth = bandwidth,
                    name = attributes["NAME"],
                ),
                url = resolveUrl(baseUrl, lines[uriIndex].trim()),
                streamInfoLine = lines[lineIndex],
                streamInfoIndex = lineIndex,
                uriIndex = uriIndex,
                bandwidth = bandwidth,
                width = width,
                height = height,
                frameRate = frameRate,
                score = score,
            )
            lineIndex = uriIndex + 1
        }

        return variants
    }

    private fun nextUriLineIndex(lines: List<String>, startIndex: Int): Int? {
        for (index in startIndex until lines.size) {
            val line = lines[index].trim()
            if (line.isEmpty()) continue
            if (!line.startsWith("#")) return index
            if (line.startsWith("#EXT-X-STREAM-INF:", ignoreCase = true)) return null
        }
        return null
    }

    private fun parseAttributes(value: String): Map<String, String> {
        return splitAttributeList(value).mapNotNull { attribute ->
            val separatorIndex = attribute.indexOf("=")
            if (separatorIndex <= 0) return@mapNotNull null

            val name = attribute.substring(0, separatorIndex).trim()
            val rawValue = attribute.substring(separatorIndex + 1).trim()
            name to rawValue.trim('"')
        }.toMap()
    }

    private fun splitAttributeList(value: String): List<String> {
        val attributes = mutableListOf<String>()
        val current = StringBuilder()
        var inQuotes = false

        value.forEach { char ->
            when (char) {
                '"' -> {
                    inQuotes = !inQuotes
                    current.append(char)
                }
                ',' -> {
                    if (inQuotes) {
                        current.append(char)
                    } else {
                        attributes += current.toString()
                        current.clear()
                    }
                }
                else -> current.append(char)
            }
        }

        if (current.isNotEmpty()) {
            attributes += current.toString()
        }

        return attributes
    }

    private fun qualityLabel(
        height: Int?,
        frameRate: Double?,
        bandwidth: Long?,
        name: String?,
    ): String {
        if (height != null) {
            val roundedFrameRate = frameRate?.roundToInt()
            return buildString {
                append(height)
                append("p")
                if (roundedFrameRate != null) {
                    append(roundedFrameRate)
                }
            }
        }

        if (!name.isNullOrBlank()) return name

        return bandwidth
            ?.let { "${it / 1000}k" }
            ?: "auto"
    }

    private fun resolveUrl(baseUrl: String, value: String): String {
        return runCatching { URI(baseUrl).resolve(value).toString() }
            .getOrDefault(value)
    }

    private val uriAttributeRegex = Regex("""URI="([^"]+)"""")
}
