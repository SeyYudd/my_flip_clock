import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager for burn-in protection logic
class BurnInManager {
  Timer? _burnInTimer;
  double _burnInOffsetX = 0;
  double _burnInOffsetY = 0;
  double _overlayPosition = 0;
  final Random _random = Random();

  String _burnInMode = 'shift'; // shift, overlay, none
  int _burnInInterval = 30;

  double get offsetX => _burnInOffsetX;
  double get offsetY => _burnInOffsetY;
  double get overlayPosition => _overlayPosition;
  String get mode => _burnInMode;

  /// Load burn-in settings from preferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _burnInMode = prefs.getString('burn_in_mode') ?? 'shift';
    _burnInInterval = prefs.getInt('burn_in_interval') ?? 30;
  }

  /// Start burn-in protection
  void start(Function() onUpdate) {
    if (_burnInMode == 'none') return;

    _burnInTimer?.cancel();
    _burnInTimer = Timer.periodic(Duration(seconds: _burnInInterval), (_) {
      if (_burnInMode == 'shift') {
        _burnInOffsetX = (_random.nextDouble() - 0.5) * 20;
        _burnInOffsetY = (_random.nextDouble() - 0.5) * 20;
      } else if (_burnInMode == 'overlay') {
        _overlayPosition = (_overlayPosition + 0.1) % 1.0;
      }
      onUpdate();
    });
  }

  /// Stop burn-in protection
  void stop() {
    _burnInTimer?.cancel();
    _burnInTimer = null;
  }

  /// Update mode and restart if active
  void updateMode(String mode, Function() onUpdate) {
    _burnInMode = mode;
    if (_burnInTimer != null) {
      stop();
      start(onUpdate);
    }
  }

  /// Save settings
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('burn_in_mode', _burnInMode);
    await prefs.setInt('burn_in_interval', _burnInInterval);
  }

  void dispose() {
    stop();
  }
}
