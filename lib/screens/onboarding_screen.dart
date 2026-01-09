import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  bool _notifAccess = false;
  bool _postNotif = false;
  bool _calendarGranted = false;
  final MethodChannel _mediaControl = const MethodChannel('media_control');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    try {
      final notif = await _mediaControl.invokeMethod<bool>(
        'isNotificationAccessGranted',
      );
      _notifAccess = notif == true;
    } catch (_) {
      _notifAccess = false;
    }
    final calBasic = await Permission.calendar.status;
    final calFull = await Permission.calendarFullAccess.status;
    final post = await Permission.notification.status;
    setState(() {
      _calendarGranted = calBasic.isGranted || calFull.isGranted;
      _postNotif = post.isGranted;
    });
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _mediaControl.invokeMethod('openNotificationAccessSettings');
      await Future.delayed(const Duration(milliseconds: 800));
      await _checkAllPermissions();
    } catch (_) {}
  }

  Future<void> _requestPostNotification() async {
    final status = await Permission.notification.request();
    setState(() => _postNotif = status.isGranted);
  }

  Future<void> _requestCalendar() async {
    var status = await Permission.calendarFullAccess.request();
    if (!status.isGranted) {
      status = await Permission.calendar.request();
    }
    await _checkAllPermissions();
  }

  void _exitApp() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon/logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.access_time_filled,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selamat Datang!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'My Stand Clock',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // Permission section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Izin Aplikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aktifkan izin berikut agar aplikasi berjalan dengan baik.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),

                        // Permission tiles
                        _PermissionTile(
                          icon: _notifAccess
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          iconColor: _notifAccess ? Colors.green : Colors.grey,
                          title: 'Akses Notifikasi Media',
                          subtitle: 'Untuk kontrol playback musik',
                          enabled: _notifAccess,
                          onEnable: _openNotificationSettings,
                          buttonLabel: 'Buka Settings',
                        ),
                        const Divider(),
                        _PermissionTile(
                          icon: _postNotif
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          iconColor: _postNotif ? Colors.green : Colors.grey,
                          title: 'Izin Notifikasi',
                          subtitle: 'Untuk mengirim notifikasi',
                          enabled: _postNotif,
                          onEnable: _requestPostNotification,
                          buttonLabel: 'Aktifkan',
                        ),
                        const Divider(),
                        _PermissionTile(
                          icon: _calendarGranted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          iconColor: _calendarGranted
                              ? Colors.green
                              : Colors.grey,
                          title: 'Akses Kalender',
                          subtitle: 'Untuk menampilkan event',
                          enabled: _calendarGranted,
                          onEnable: _requestCalendar,
                          buttonLabel: 'Aktifkan',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _exitApp,
                        child: const Text('Keluar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed:
                            (_notifAccess && _postNotif && _calendarGranted)
                            ? () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('initial_setup_done', true);
                                if (mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const HomeScreen(),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: const Text('Lanjutkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onEnable;
  final String buttonLabel;

  const _PermissionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onEnable,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (enabled)
            Chip(
              label: const Text('Aktif'),
              backgroundColor: Colors.green.shade100,
              labelStyle: TextStyle(color: Colors.green.shade800),
            )
          else
            ElevatedButton(
              onPressed: onEnable,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(buttonLabel),
            ),
        ],
      ),
    );
  }
}
