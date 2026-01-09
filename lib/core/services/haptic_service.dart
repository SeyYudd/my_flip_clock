import 'package:flutter/services.dart';

/// Haptic feedback service for consistent haptics across app
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _enabled = true;

  void enable() => _enabled = true;
  void disable() => _enabled = false;

  /// Light haptic for subtle feedback
  Future<void> light() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic for button presses
  Future<void> medium() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic for important actions
  Future<void> heavy() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic for pickers/sliders
  Future<void> selection() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Success vibration pattern
  Future<void> success() async {
    if (!_enabled) return;
    await medium();
    await Future.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Error vibration pattern
  Future<void> error() async {
    if (!_enabled) return;
    await heavy();
    await Future.delayed(const Duration(milliseconds: 100));
    await heavy();
  }
}
