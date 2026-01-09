import 'package:shared_preferences/shared_preferences.dart';

/// Manager for grid layout settings
class GridLayoutManager {
  double topRatio = 0.5;
  double innerPadding = 8.0;
  double outerPadding = 12.0;
  double borderRadius = 16.0;
  bool autoRotate = true;

  /// Load grid settings from preferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    topRatio = prefs.getDouble('top_ratio') ?? 0.5;
    innerPadding = prefs.getDouble('inner_padding') ?? 8.0;
    outerPadding = prefs.getDouble('outer_padding') ?? 12.0;
    borderRadius = prefs.getDouble('border_radius') ?? 16.0;
    autoRotate = prefs.getBool('auto_rotate') ?? true;
  }

  /// Save grid settings to preferences
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('top_ratio', topRatio);
    await prefs.setDouble('inner_padding', innerPadding);
    await prefs.setDouble('outer_padding', outerPadding);
    await prefs.setDouble('border_radius', borderRadius);
    await prefs.setBool('auto_rotate', autoRotate);
  }

  /// Update top ratio (0.0 to 1.0)
  void updateTopRatio(double value) {
    topRatio = value.clamp(0.1, 0.9);
  }

  /// Update inner padding
  void updateInnerPadding(double value) {
    innerPadding = value.clamp(0.0, 32.0);
  }

  /// Update outer padding
  void updateOuterPadding(double value) {
    outerPadding = value.clamp(0.0, 32.0);
  }

  /// Update border radius
  void updateBorderRadius(double value) {
    borderRadius = value.clamp(0.0, 48.0);
  }

  /// Toggle auto-rotate
  void toggleAutoRotate() {
    autoRotate = !autoRotate;
  }
}
