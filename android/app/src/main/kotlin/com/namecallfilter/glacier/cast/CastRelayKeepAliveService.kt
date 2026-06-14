package com.namecallfilter.glacier.cast

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import com.namecallfilter.glacier.R

class CastRelayKeepAliveService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }

        startForegroundCompat()
        acquireLocks()
        Log.d(LOG_TAG, "cast_keep_alive action=started")
        return START_STICKY
    }

    override fun onDestroy() {
        releaseLocks()
        Log.d(LOG_TAG, "cast_keep_alive action=stopped")
        super.onDestroy()
    }

    private fun startForegroundCompat() {
        createNotificationChannel()
        val notification = notification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            "Cast relay",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Keeps the local Cast relay active while casting"
            setShowBadge(false)
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)
    }

    private fun notification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Glacier cast relay")
            .setContentText("Keeping local playback relay active")
            .setOngoing(true)
            .setShowWhen(false)
            .build()
    }

    private fun acquireLocks() {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        if (wakeLock?.isHeld != true) {
            wakeLock = powerManager
                .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Glacier:CastRelayWakeLock")
                .apply {
                    setReferenceCounted(false)
                    acquire()
                }
        }

        val wifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        if (wifiLock?.isHeld != true) {
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                WifiManager.WIFI_MODE_FULL_LOW_LATENCY
            } else {
                @Suppress("DEPRECATION")
                WifiManager.WIFI_MODE_FULL_HIGH_PERF
            }
            wifiLock = wifiManager
                .createWifiLock(mode, "Glacier:CastRelayWifiLock")
                .apply {
                    setReferenceCounted(false)
                    acquire()
                }
        }
    }

    private fun releaseLocks() {
        wakeLock
            ?.takeIf(PowerManager.WakeLock::isHeld)
            ?.release()
        wakeLock = null

        wifiLock
            ?.takeIf(WifiManager.WifiLock::isHeld)
            ?.release()
        wifiLock = null
    }

    companion object {
        private const val ACTION_START = "com.namecallfilter.glacier.cast.START_RELAY_KEEP_ALIVE"
        private const val ACTION_STOP = "com.namecallfilter.glacier.cast.STOP_RELAY_KEEP_ALIVE"
        private const val CHANNEL_ID = "glacier_cast_relay"
        private const val NOTIFICATION_ID = 5312
        private const val LOG_TAG = "GlacierCast"

        fun start(context: Context) {
            val intent = Intent(context, CastRelayKeepAliveService::class.java)
                .setAction(ACTION_START)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(
                Intent(context, CastRelayKeepAliveService::class.java)
                    .setAction(ACTION_STOP),
            )
        }
    }
}
