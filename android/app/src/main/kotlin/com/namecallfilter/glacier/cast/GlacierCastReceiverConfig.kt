package com.namecallfilter.glacier.cast

import android.content.Context
import com.google.android.gms.cast.CastMediaControlIntent
import com.namecallfilter.glacier.R

object GlacierCastReceiverConfig {
    fun receiverApplicationId(context: Context): String {
        return customReceiverApplicationId(context)
            ?: CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID
    }

    fun maskedReceiverApplicationId(context: Context): String {
        val customId = customReceiverApplicationId(context)
        val receiverId = customId ?: CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID
        val source = if (customId == null) "default" else "custom"

        return "$source:${receiverId.masked()}"
    }

    private fun customReceiverApplicationId(context: Context): String? {
        return context
            .getString(R.string.cast_receiver_app_id)
            .trim()
            .takeIf(String::isNotEmpty)
    }

    private fun String.masked(): String {
        if (length <= MASK_VISIBLE_CHARACTERS) {
            return "*".repeat(length)
        }

        return "${take(MASK_VISIBLE_PREFIX)}***${takeLast(MASK_VISIBLE_SUFFIX)}"
    }

    private const val MASK_VISIBLE_PREFIX = 3
    private const val MASK_VISIBLE_SUFFIX = 2
    private const val MASK_VISIBLE_CHARACTERS = MASK_VISIBLE_PREFIX + MASK_VISIBLE_SUFFIX
}
