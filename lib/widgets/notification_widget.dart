import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NotificationItem {
  final String packageName;
  final String appName;
  final String title;
  final String text;
  final int timestamp;
  final Uint8List? icon;

  NotificationItem({
    required this.packageName,
    required this.appName,
    required this.title,
    required this.text,
    required this.timestamp,
    this.icon,
  });

  factory NotificationItem.fromMap(Map<dynamic, dynamic> map) {
    Uint8List? iconBytes;
    if (map['icon'] != null && map['icon'] is String) {
      try {
        iconBytes = base64Decode(map['icon']);
      } catch (_) {}
    }

    return NotificationItem(
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? 'Unknown',
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] is int) ? map['timestamp'] : 0,
      icon: iconBytes,
    );
  }
}

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  static const _eventChannel = EventChannel('notification_event_channel');
  static const _methodChannel = MethodChannel('notification_control');

  List<NotificationItem> _notifications = [];
  StreamSubscription? _subscription;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    try {
      final result = await _methodChannel.invokeMethod(
        'isNotificationAccessGranted',
      );
      if (mounted) {
        setState(() {
          _hasPermission = result == true;
        });
      }
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
    }
  }

  Future<void> _openSettings() async {
    try {
      await _methodChannel.invokeMethod('openNotificationAccessSettings');
      // Recheck after returning
      Future.delayed(const Duration(seconds: 2), _checkPermission);
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  void _startListening() {
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          final notification = NotificationItem.fromMap(event);
          if (mounted) {
            setState(() {
              // Add to top, remove duplicates
              _notifications.removeWhere(
                (n) =>
                    n.packageName == notification.packageName &&
                    n.title == notification.title,
              );
              _notifications.insert(0, notification);
              // Keep max 20
              if (_notifications.length > 20) {
                _notifications = _notifications.sublist(0, 20);
              }
            });
          }
        } else if (event is List) {
          // Initial list of notifications
          final items = event
              .whereType<Map>()
              .map((m) => NotificationItem.fromMap(m))
              .toList();
          if (mounted) {
            setState(() {
              _notifications = items;
            });
          }
        }
      },
      onError: (e) {
        debugPrint('Notification stream error: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade900, Colors.black],
        ),
      ),
      child: _notifications.isEmpty ? _buildEmpty() : _buildNotificationList(),
    );
  }

  Widget _buildPermissionRequest() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade900, Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Notification Access Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Grant access to display notifications',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _checkPermission,
              child: Text(
                'Refresh',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.notifications,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                '${_notifications.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationCard(_notifications[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final time = DateTime.fromMillisecondsSinceEpoch(notification.timestamp);
    final now = DateTime.now();
    final diff = now.difference(time);

    String timeStr;
    if (diff.inMinutes < 1) {
      timeStr = 'Just now';
    } else if (diff.inHours < 1) {
      timeStr = '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      timeStr = '${diff.inHours}h ago';
    } else {
      timeStr = DateFormat('MMM d').format(time);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: notification.icon != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      notification.icon!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildDefaultIcon(notification.appName),
                    ),
                  )
                : _buildDefaultIcon(notification.appName),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.appName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (notification.title.isNotEmpty)
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (notification.text.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    notification.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon(String appName) {
    return Center(
      child: Text(
        appName.isNotEmpty ? appName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
