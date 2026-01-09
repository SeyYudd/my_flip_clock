/// Storage keys for SharedPreferences
/// Centralized to avoid magic strings and typos
class StorageKeys {
  // Settings
  static const String fontFamily = 'settings_font_family';
  static const String fontSize = 'settings_font_size';
  static const String fontColor = 'settings_font_color';
  static const String keepScreenOn = 'settings_keep_screen_on';
  static const String fullscreen = 'settings_fullscreen';
  static const String layoutMode = 'settings_layout_mode';
  static const String themeDark = 'settings_theme_dark';
  static const String burnInProtection = 'settings_burn_in_protection';
  static const String burnInMode = 'settings_burn_in_mode';
  static const String orientations = 'settings_orientations';

  // Widget settings
  static const String widgetColors = 'widget_colors';
  static const String topWidgets = 'top_widgets';
  static const String bottomWidgets = 'bottom_widgets';

  // Grid settings
  static const String gridTopRatio = 'grid_top_ratio';
  static const String gridInnerPadding = 'grid_inner_padding';
  static const String gridOuterPadding = 'grid_outer_padding';
  static const String gridBorderRadius = 'grid_border_radius';

  // App settings
  static const String autoRotate = 'auto_rotate';
  static const String initialSetupDone = 'initial_setup_done';
}
