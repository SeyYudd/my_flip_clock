import 'package:shared_preferences/shared_preferences.dart';

/// Manager for widget slot configuration
class WidgetSlotManager {
  List<String> topWidgets = [];
  List<String> bottomWidgets = [];

  final Map<String, String> availableWidgets = {
    'clock': 'Clock',
    'now_playing': 'Now Playing',
    'tools': 'Tools',
    'quote': 'Quote',
    'battery': 'Battery Status',
    'countdown': 'Countdown',
    'photo': 'Photo Frame',
    'ambient': 'Ambient Animation',
    'notification': 'Notifications',
    'connectivity': 'Connectivity',
    'gif': 'GIF Sticker',
  };

  /// Load widget configuration from preferences
  Future<void> loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();

    final topJson = prefs.getString('top_widgets');
    final bottomJson = prefs.getString('bottom_widgets');

    if (topJson != null && topJson.isNotEmpty) {
      topWidgets = topJson.split(',');
    } else {
      topWidgets = ['clock'];
    }

    if (bottomJson != null && bottomJson.isNotEmpty) {
      bottomWidgets = bottomJson.split(',');
    } else {
      bottomWidgets = ['now_playing'];
    }
  }

  /// Save widget configuration to preferences
  Future<void> saveConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('top_widgets', topWidgets.join(','));
    await prefs.setString('bottom_widgets', bottomWidgets.join(','));
  }

  /// Update top slot widgets
  void updateTopWidgets(List<String> widgets) {
    topWidgets = widgets;
  }

  /// Update bottom slot widgets
  void updateBottomWidgets(List<String> widgets) {
    bottomWidgets = widgets;
  }

  /// Check if widget is in use
  bool isWidgetInUse(String widgetKey) {
    return topWidgets.contains(widgetKey) || bottomWidgets.contains(widgetKey);
  }
}
