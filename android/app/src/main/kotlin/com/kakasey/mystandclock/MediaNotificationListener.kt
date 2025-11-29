package com.kakasey.mystandclock

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.app.Notification
import android.util.Log
import android.graphics.Bitmap
import android.os.Bundle
import java.io.ByteArrayOutputStream
import android.util.Base64
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.media.MediaMetadata
import android.content.Context
import android.content.ComponentName
import android.os.Build
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Icon
import android.graphics.Canvas

class MediaNotificationListener : NotificationListenerService() {
    
    private var mediaSessionManager: MediaSessionManager? = null
    private var sessionListener: MediaSessionManager.OnActiveSessionsChangedListener? = null

    companion object {
        var instance: MediaNotificationListener? = null
        
        // Media app package names to filter
        private val mediaApps = listOf(
            "com.spotify.music",
            "com.google.android.apps.youtube.music",
            "com.apple.android.music",
            "com.amazon.mp3",
            "com.soundcloud.android",
            "deezer.android.app",
            "com.pandora.android"
        )
        
        fun isMediaApp(packageName: String): Boolean {
            return mediaApps.any { packageName.contains(it) } ||
                   packageName.contains("music") ||
                   packageName.contains("player")
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        setupMediaSessionListener()
    }

    override fun onDestroy() {
        instance = null
        sessionListener?.let { mediaSessionManager?.removeOnActiveSessionsChangedListener(it) }
        super.onDestroy()
    }

    fun getAllActiveNotifications(): List<StatusBarNotification> {
        return try {
            activeNotifications?.toList() ?: emptyList()
        } catch (e: Exception) {
            Log.e("NotifListener", "Error getting active notifications", e)
            emptyList()
        }
    }

    private fun setupMediaSessionListener() {
        try {
            mediaSessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
            val componentName = ComponentName(this, MediaNotificationListener::class.java)
            
            sessionListener = MediaSessionManager.OnActiveSessionsChangedListener { controllers ->
                controllers?.firstOrNull()?.let { controller ->
                    sendMediaUpdate(controller)
                    
                    // Register callback for this controller
                    controller.registerCallback(object : MediaController.Callback() {
                        override fun onPlaybackStateChanged(state: PlaybackState?) {
                            sendMediaUpdate(controller)
                        }
                        override fun onMetadataChanged(metadata: MediaMetadata?) {
                            sendMediaUpdate(controller)
                        }
                    })
                }
            }
            
            mediaSessionManager?.addOnActiveSessionsChangedListener(sessionListener!!, componentName)
            
            // Initial check for active sessions
            mediaSessionManager?.getActiveSessions(componentName)?.firstOrNull()?.let { controller ->
                sendMediaUpdate(controller)
            }
        } catch (e: Exception) {
            Log.e("NotifListener", "Error setting up media session listener", e)
        }
    }

    private fun sendMediaUpdate(controller: MediaController) {
        try {
            val metadata = controller.metadata
            val playbackState = controller.playbackState
            
            val title = metadata?.getString(MediaMetadata.METADATA_KEY_TITLE) ?: ""
            val artist = metadata?.getString(MediaMetadata.METADATA_KEY_ARTIST) 
                ?: metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST) ?: ""
            val album = metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM) ?: ""
            val duration = metadata?.getLong(MediaMetadata.METADATA_KEY_DURATION) ?: 0L
            val position = playbackState?.position ?: 0L
            val isPlaying = playbackState?.state == PlaybackState.STATE_PLAYING
            val pkg = controller.packageName ?: ""

            var artBase64: String? = null
            try {
                val bitmap = metadata?.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)
                    ?: metadata?.getBitmap(MediaMetadata.METADATA_KEY_ART)
                if (bitmap != null) {
                    val baos = ByteArrayOutputStream()
                    // Compress to reduce size
                    val scaled = Bitmap.createScaledBitmap(bitmap, 300, 300, true)
                    scaled.compress(Bitmap.CompressFormat.JPEG, 80, baos)
                    val bytes = baos.toByteArray()
                    artBase64 = Base64.encodeToString(bytes, Base64.NO_WRAP)
                }
            } catch (e: Exception) {
                Log.e("NotifListener", "Error getting album art", e)
            }

            val intent = Intent("com.kakasey.mystandclock.MEDIA_NOTIFICATION")
            intent.putExtra("title", title)
            intent.putExtra("artist", artist)
            intent.putExtra("album", album)
            intent.putExtra("package", pkg)
            intent.putExtra("duration", duration)
            intent.putExtra("position", position)
            intent.putExtra("isPlaying", isPlaying)
            if (artBase64 != null) intent.putExtra("art", artBase64)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                sendBroadcast(intent, null)
            } else {
                sendBroadcast(intent)
            }
            
            Log.d("NotifListener", "Sent media update: $title - $artist, playing=$isPlaying")
        } catch (e: Exception) {
            Log.e("NotifListener", "Error sending media update", e)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        try {
            val n: Notification = sbn.notification
            val extras = n.extras
            val category = n.category
            val hasMediaSession = extras.containsKey(Notification.EXTRA_MEDIA_SESSION)
            val packageName = sbn.packageName ?: ""
            
            // Handle media notifications
            if (category == Notification.CATEGORY_TRANSPORT || hasMediaSession) {
                val componentName = ComponentName(this, MediaNotificationListener::class.java)
                mediaSessionManager?.getActiveSessions(componentName)?.firstOrNull()?.let { controller ->
                    sendMediaUpdate(controller)
                }
                return
            }
            
            // Skip media apps for general notifications
            if (isMediaApp(packageName)) return
            
            // Forward general notification to Flutter
            sendGeneralNotification(sbn)
            
        } catch (e: Exception) {
            Log.e("NotifListener", "error reading notification", e)
        }
    }

    private fun sendGeneralNotification(sbn: StatusBarNotification) {
        try {
            val n = sbn.notification
            val extras = n.extras
            val packageName = sbn.packageName ?: ""
            
            val appName = try {
                packageManager.getApplicationLabel(
                    packageManager.getApplicationInfo(packageName, 0)
                ).toString()
            } catch (e: Exception) { packageName }
            
            val title = extras?.getString(Notification.EXTRA_TITLE) ?: 
                        extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
            val text = extras?.getString(Notification.EXTRA_TEXT) ?: 
                       extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
            val timestamp = sbn.postTime

            // Get app icon as base64
            var iconBase64: String? = null
            try {
                val icon = packageManager.getApplicationIcon(packageName)
                if (icon is BitmapDrawable) {
                    val baos = ByteArrayOutputStream()
                    val bitmap = icon.bitmap
                    val scaled = Bitmap.createScaledBitmap(bitmap, 48, 48, true)
                    scaled.compress(Bitmap.CompressFormat.PNG, 100, baos)
                    iconBase64 = Base64.encodeToString(baos.toByteArray(), Base64.NO_WRAP)
                } else {
                    // Convert to bitmap
                    val bitmap = Bitmap.createBitmap(48, 48, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bitmap)
                    icon.setBounds(0, 0, 48, 48)
                    icon.draw(canvas)
                    val baos = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
                    iconBase64 = Base64.encodeToString(baos.toByteArray(), Base64.NO_WRAP)
                }
            } catch (e: Exception) { 
                Log.e("NotifListener", "Error getting icon", e)
            }

            val intent = Intent("com.kakasey.mystandclock.GENERAL_NOTIFICATION")
            intent.putExtra("packageName", packageName)
            intent.putExtra("appName", appName)
            intent.putExtra("title", title)
            intent.putExtra("text", text)
            intent.putExtra("timestamp", timestamp)
            if (iconBase64 != null) intent.putExtra("icon", iconBase64)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                sendBroadcast(intent, null)
            } else {
                sendBroadcast(intent)
            }
            
            Log.d("NotifListener", "Sent notification: $appName - $title")
        } catch (e: Exception) {
            Log.e("NotifListener", "Error sending notification", e)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        try {
            val n: Notification = sbn.notification
            val category = n.category
            val hasMediaSession = n.extras.containsKey(Notification.EXTRA_MEDIA_SESSION)
            
            if (category == Notification.CATEGORY_TRANSPORT || hasMediaSession) {
                val intent = Intent("com.kakasey.mystandclock.MEDIA_NOTIFICATION")
                intent.putExtra("cleared", true)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    sendBroadcast(intent, null)
                } else {
                    sendBroadcast(intent)
                }
            }
        } catch (e: Exception) {
            Log.e("NotifListener", "error on notification removed", e)
        }
    }
}
