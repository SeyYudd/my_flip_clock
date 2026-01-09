/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'My Stand Clock';
  static const String appVersion = '2.0.0';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Layout
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 16.0;
  static const double largeBorderRadius = 24.0;

  // Timer
  static const Duration tabHideDelay = Duration(seconds: 3);
  static const Duration burnInInterval = Duration(seconds: 10);
}
