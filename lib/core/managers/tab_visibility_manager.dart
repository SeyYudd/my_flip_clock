import 'dart:async';

/// Manager for tab visibility timing
class TabVisibilityManager {
  Timer? _hideTabsTimer;
  bool _showTabs = true;
  final Function() _onUpdate;

  TabVisibilityManager(this._onUpdate);

  bool get showTabs => _showTabs;

  /// Start timer to auto-hide tabs
  void startHideTimer() {
    _hideTabsTimer?.cancel();
    _hideTabsTimer = Timer(const Duration(seconds: 3), () {
      _showTabs = false;
      _onUpdate();
    });
  }

  /// Show tabs temporarily (3 seconds)
  void showTemporarily() {
    _showTabs = true;
    _onUpdate();
    startHideTimer();
  }

  /// Toggle tab visibility
  void toggle() {
    _showTabs = !_showTabs;
    _onUpdate();
    if (_showTabs) {
      startHideTimer();
    }
  }

  /// Permanently show tabs
  void show() {
    _showTabs = true;
    _onUpdate();
  }

  /// Permanently hide tabs
  void hide() {
    _hideTabsTimer?.cancel();
    _showTabs = false;
    _onUpdate();
  }

  void dispose() {
    _hideTabsTimer?.cancel();
  }
}
