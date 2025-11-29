package com.kakasey.mystandclock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.os.BatteryManager
import android.content.pm.PackageManager
import android.Manifest
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat
import android.provider.CalendarContract
import android.provider.MediaStore
import android.database.Cursor
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import android.media.session.PlaybackState
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.MediaMetadata
import android.util.Base64
import android.util.Log
import java.util.HashMap
import android.provider.Settings
import android.content.ComponentName
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import java.io.ByteArrayOutputStream
import android.service.notification.StatusBarNotification
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager

class MainActivity : FlutterActivity() {
	private val CHANNEL = "media_notifications"
	private var events: EventChannel.EventSink? = null
	private var notificationEvents: EventChannel.EventSink? = null
	private var pendingCalendarResult: MethodChannel.Result? = null
	private val CALENDAR_CHANNEL = "calendar_channel"
	private val REQUEST_CALENDAR = 9001
	
	private var mediaSessionManager: MediaSessionManager? = null
	private var sessionListener: MediaSessionManager.OnActiveSessionsChangedListener? = null
	private var currentCallback: MediaController.Callback? = null
	private var currentController: MediaController? = null

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		val messenger = flutterEngine.dartExecutor.binaryMessenger

		EventChannel(messenger, CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
			override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
				events = eventSink
				Log.d("MainActivity", "EventChannel onListen - setting up media session listener")
				setupMediaSessionListener()
			}

			override fun onCancel(arguments: Any?) {
				Log.d("MainActivity", "EventChannel onCancel")
				cleanupMediaSessionListener()
				events = null
			}
		})

		// Media control method channel
		MethodChannel(messenger, "media_control").setMethodCallHandler { call, result ->
			try {
				when (call.method) {
					"transport" -> {
					val pkg = call.argument<String>("package") ?: ""
					val cmd = call.argument<String>("command") ?: ""
					val msm = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
					val controllers = msm.getActiveSessions(ComponentName(this, MediaNotificationListener::class.java))
					for (c in controllers) {
						if (c.packageName == pkg) {
							val tc = c.transportControls
							when (cmd) {
									"play" -> tc.play()
									"pause" -> tc.pause()
									"next" -> tc.skipToNext()
									"previous" -> tc.skipToPrevious()
									"toggle" -> {
									val state = c.playbackState?.state ?: PlaybackState.STATE_NONE
									if (state == PlaybackState.STATE_PLAYING) tc.pause() else tc.play()
								}
								"seekTo" -> {
									val pos = call.argument<Number>("position")?.toLong() ?: 0L
									tc.seekTo(pos)
								}
								else -> {}
							}
						}
					}
					result.success(true)
					}
					"isNotificationAccessGranted" -> {
						val enabledListeners = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: ""
						val myComponent = ComponentName(this, MediaNotificationListener::class.java).flattenToString()
						result.success(enabledListeners.contains(myComponent))
					}
					"openNotificationAccessSettings" -> {
						val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
						intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
						startActivity(intent)
						result.success(true)
					}
					else -> result.notImplemented()
				}
			} catch (e: Exception) {
				result.error("media_control_error", e.message, null)
			}
		}

		// Method channel for calendar queries
		MethodChannel(messenger, CALENDAR_CHANNEL).setMethodCallHandler { call, result ->
			if (call.method == "getEvents") {
				if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CALENDAR) != PackageManager.PERMISSION_GRANTED) {
					pendingCalendarResult = result
					ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_CALENDAR), REQUEST_CALENDAR)
					return@setMethodCallHandler
				}
				val list = fetchCalendarEvents()
				result.success(list)
			} else {
				result.notImplemented()
			}
		}

		// Battery channel
		MethodChannel(messenger, "battery_channel").setMethodCallHandler { call, result ->
			if (call.method == "getBatteryInfo") {
				val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
				val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
				val status = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_STATUS)
				val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING || 
								status == BatteryManager.BATTERY_STATUS_FULL
				result.success(mapOf("level" to level, "isCharging" to isCharging))
			} else {
				result.notImplemented()
			}
		}

		// Connectivity channel for Bluetooth status
		MethodChannel(messenger, "connectivity_channel").setMethodCallHandler { call, result ->
			when (call.method) {
				"isBluetoothEnabled" -> {
					try {
						val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
						val bluetoothAdapter = bluetoothManager.adapter
						result.success(bluetoothAdapter?.isEnabled == true)
					} catch (e: Exception) {
						result.success(false)
					}
				}
				else -> result.notImplemented()
			}
		}

		// Photo gallery channel
		MethodChannel(messenger, "photo_gallery_channel").setMethodCallHandler { call, result ->
			if (call.method == "getPhotos") {
				val limit = call.argument<Int>("limit") ?: 50
				val photos = fetchPhotos(limit)
				result.success(photos)
			} else {
				result.notImplemented()
			}
		}

		// Notification event channel for general notifications with broadcast receiver
		EventChannel(messenger, "notification_event_channel").setStreamHandler(object : EventChannel.StreamHandler {
			private var notifReceiver: BroadcastReceiver? = null
			
			override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
				notifReceiver = object : BroadcastReceiver() {
					override fun onReceive(context: Context?, intent: Intent?) {
						if (intent?.action == "com.kakasey.mystandclock.GENERAL_NOTIFICATION") {
							val map = HashMap<String, Any?>()
							map["packageName"] = intent.getStringExtra("packageName") ?: ""
							map["appName"] = intent.getStringExtra("appName") ?: ""
							map["title"] = intent.getStringExtra("title") ?: ""
							map["text"] = intent.getStringExtra("text") ?: ""
							map["timestamp"] = intent.getLongExtra("timestamp", 0L)
							intent.getStringExtra("icon")?.let { map["icon"] = it }
							eventSink?.success(map)
						}
					}
				}
				val filter = IntentFilter("com.kakasey.mystandclock.GENERAL_NOTIFICATION")
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
					registerReceiver(notifReceiver, filter, Context.RECEIVER_EXPORTED)
				} else {
					registerReceiver(notifReceiver, filter)
				}
			}
			
			override fun onCancel(arguments: Any?) {
				notifReceiver?.let { unregisterReceiver(it) }
				notifReceiver = null
			}
		})

		// Notification control channel
		MethodChannel(messenger, "notification_control").setMethodCallHandler { call, result ->
			when (call.method) {
				"isNotificationAccessGranted" -> {
					val enabledListeners = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: ""
					val myComponent = ComponentName(this, MediaNotificationListener::class.java).flattenToString()
					result.success(enabledListeners.contains(myComponent))
				}
				"openNotificationAccessSettings" -> {
					val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
					intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
					startActivity(intent)
					result.success(true)
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun fetchPhotos(limit: Int): List<String> {
		val photos = mutableListOf<String>()
		val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
		val projection = arrayOf(MediaStore.Images.Media.DATA)
		val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"
		
		try {
			contentResolver.query(uri, projection, null, null, sortOrder)?.use { cursor ->
				val columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
				var count = 0
				while (cursor.moveToNext() && count < limit) {
					val path = cursor.getString(columnIndex)
					if (path != null) {
						photos.add(path)
						count++
					}
				}
			}
		} catch (e: Exception) {
			Log.e("MainActivity", "Error fetching photos", e)
		}
		return photos
	}

	private fun sendExistingNotifications() {
		// This would be called from NotificationListener service
		// For now, we'll handle it via broadcast
	}

	fun onNotificationPosted(sbn: StatusBarNotification) {
		notificationEvents?.let { sink ->
			val notification = sbn.notification
			val extras = notification.extras
			
			val packageName = sbn.packageName ?: ""
			val appName = try {
				packageManager.getApplicationLabel(
					packageManager.getApplicationInfo(packageName, 0)
				).toString()
			} catch (e: Exception) { packageName }
			
			val title = extras?.getString("android.title") ?: ""
			val text = extras?.getString("android.text") ?: ""
			val timestamp = sbn.postTime

			// Get app icon as base64
			var iconBase64: String? = null
			try {
				val icon = packageManager.getApplicationIcon(packageName)
				if (icon is BitmapDrawable) {
					val baos = ByteArrayOutputStream()
					icon.bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
					iconBase64 = Base64.encodeToString(baos.toByteArray(), Base64.NO_WRAP)
				}
			} catch (e: Exception) { }

			val map = HashMap<String, Any?>()
			map["packageName"] = packageName
			map["appName"] = appName
			map["title"] = title
			map["text"] = text
			map["timestamp"] = timestamp
			if (iconBase64 != null) map["icon"] = iconBase64

			runOnUiThread { sink.success(map) }
		}
	}

	override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		if (requestCode == REQUEST_CALENDAR) {
			if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
				pendingCalendarResult?.success(fetchCalendarEvents())
			} else {
				pendingCalendarResult?.error("permission_denied", "Calendar permission denied", null)
			}
			pendingCalendarResult = null
		}
	}

	private fun fetchCalendarEvents(): List<Map<String, Any>> {
		val now = System.currentTimeMillis()
		val week = now + 7L * 24 * 60 * 60 * 1000
		val cr = contentResolver
		val uri = CalendarContract.Events.CONTENT_URI
		val selection = "(( ${CalendarContract.Events.DTSTART} >= ?) AND (${CalendarContract.Events.DTSTART} <= ?))"
		val cursor = cr.query(uri, arrayOf(CalendarContract.Events._ID, CalendarContract.Events.TITLE, CalendarContract.Events.DTSTART, CalendarContract.Events.DTEND, CalendarContract.Events.ALL_DAY), selection, arrayOf(now.toString(), week.toString()), "${CalendarContract.Events.DTSTART} ASC")
		val results = mutableListOf<Map<String, Any>>()
		cursor?.use { c ->
			while (c.moveToNext()) {
				val title = c.getString(1) ?: ""
				val start = c.getLong(2)
				val end = c.getLong(3)
				val allday = c.getInt(4) > 0
				results.add(mapOf("title" to title, "start" to start, "end" to end, "allDay" to allday))
			}
		}
		return results
	}

	private fun setupMediaSessionListener() {
		try {
			mediaSessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
			val componentName = ComponentName(this, MediaNotificationListener::class.java)
			
			sessionListener = MediaSessionManager.OnActiveSessionsChangedListener { controllers ->
				Log.d("MainActivity", "Active sessions changed, count: ${controllers?.size ?: 0}")
				controllers?.firstOrNull()?.let { controller ->
					registerControllerCallback(controller)
					sendMediaUpdate(controller)
				} ?: run {
					// No active sessions - send cleared
					val map = HashMap<String, Any?>()
					map["cleared"] = true
					runOnUiThread { events?.success(map) }
				}
			}
			
			mediaSessionManager?.addOnActiveSessionsChangedListener(sessionListener!!, componentName)
			
			// Initial check for active sessions
			val controllers = mediaSessionManager?.getActiveSessions(componentName)
			Log.d("MainActivity", "Initial active sessions: ${controllers?.size ?: 0}")
			controllers?.firstOrNull()?.let { controller ->
				registerControllerCallback(controller)
				sendMediaUpdate(controller)
			}
		} catch (e: Exception) {
			Log.e("MainActivity", "Error setting up media session listener", e)
		}
	}

	private fun registerControllerCallback(controller: MediaController) {
		// Unregister old callback
		currentCallback?.let { currentController?.unregisterCallback(it) }
		
		currentController = controller
		currentCallback = object : MediaController.Callback() {
			override fun onPlaybackStateChanged(state: PlaybackState?) {
				Log.d("MainActivity", "Playback state changed: ${state?.state}")
				sendMediaUpdate(controller)
			}
			override fun onMetadataChanged(metadata: MediaMetadata?) {
				Log.d("MainActivity", "Metadata changed: ${metadata?.getString(MediaMetadata.METADATA_KEY_TITLE)}")
				sendMediaUpdate(controller)
			}
		}
		controller.registerCallback(currentCallback!!)
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
					val scaled = Bitmap.createScaledBitmap(bitmap, 300, 300, true)
					scaled.compress(Bitmap.CompressFormat.JPEG, 80, baos)
					val bytes = baos.toByteArray()
					artBase64 = Base64.encodeToString(bytes, Base64.NO_WRAP)
				}
			} catch (e: Exception) {
				Log.e("MainActivity", "Error getting album art", e)
			}

			val map = HashMap<String, Any?>()
			map["title"] = title
			map["artist"] = artist
			map["album"] = album
			map["package"] = pkg
			map["duration"] = duration
			map["position"] = position
			map["isPlaying"] = isPlaying
			if (artBase64 != null) map["art"] = artBase64
			
			Log.d("MainActivity", "Sending media update: $title - $artist, playing=$isPlaying")
			runOnUiThread { events?.success(map) }
		} catch (e: Exception) {
			Log.e("MainActivity", "Error sending media update", e)
		}
	}

	private fun cleanupMediaSessionListener() {
		currentCallback?.let { currentController?.unregisterCallback(it) }
		currentCallback = null
		currentController = null
		sessionListener?.let { mediaSessionManager?.removeOnActiveSessionsChangedListener(it) }
		sessionListener = null
	}

	override fun onDestroy() {
		cleanupMediaSessionListener()
		super.onDestroy()
	}
}
