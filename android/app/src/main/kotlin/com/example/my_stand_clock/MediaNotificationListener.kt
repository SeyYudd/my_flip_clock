package com.example.my_stand_clock

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

class MediaNotificationListener : NotificationListenerService() {
    
    private var mediaSessionManager: MediaSessionManager? = null
    private var sessionListener: MediaSessionManager.OnActiveSessionsChangedListener? = null

    override fun onCreate() {
        super.onCreate()
        setupMediaSessionListener()
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
            Log.e("MediaListener", "Error setting up media session listener", e)
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
                Log.e("MediaListener", "Error getting album art", e)
            }

            val intent = Intent("com.example.my_stand_clock.MEDIA_NOTIFICATION")
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
            
            Log.d("MediaListener", "Sent update: $title - $artist, playing=$isPlaying, pos=$position/$duration")
        } catch (e: Exception) {
            Log.e("MediaListener", "Error sending media update", e)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        try {
            val n: Notification = sbn.notification
            val extras = n.extras
            val category = n.category
            val hasMediaSession = extras.containsKey(Notification.EXTRA_MEDIA_SESSION)
            
            if (category != Notification.CATEGORY_TRANSPORT && !hasMediaSession) {
                return
            }

            // Trigger a session check when media notification appears
            val componentName = ComponentName(this, MediaNotificationListener::class.java)
            mediaSessionManager?.getActiveSessions(componentName)?.firstOrNull()?.let { controller ->
                sendMediaUpdate(controller)
            }
        } catch (e: Exception) {
            Log.e("MediaListener", "error reading notification", e)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        try {
            val n: Notification = sbn.notification
            val category = n.category
            val hasMediaSession = n.extras.containsKey(Notification.EXTRA_MEDIA_SESSION)
            
            if (category == Notification.CATEGORY_TRANSPORT || hasMediaSession) {
                val intent = Intent("com.example.my_stand_clock.MEDIA_NOTIFICATION")
                intent.putExtra("cleared", true)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    sendBroadcast(intent, null)
                } else {
                    sendBroadcast(intent)
                }
            }
        } catch (e: Exception) {
            Log.e("MediaListener", "error on notification removed", e)
        }
    }

    override fun onDestroy() {
        sessionListener?.let { mediaSessionManager?.removeOnActiveSessionsChangedListener(it) }
        super.onDestroy()
    }
}
