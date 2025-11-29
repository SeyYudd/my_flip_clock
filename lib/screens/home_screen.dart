import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/clock_widget.dart';
import '../widgets/media_widget.dart';
import '../widgets/tools_carousel_widget.dart';
import '../widgets/quote_widget.dart';
import '../widgets/settings_widget.dart';
import '../widgets/battery_widget.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/photo_frame_widget.dart';
import '../widgets/ambient_widget.dart';
import '../widgets/notification_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Slot widget keys
  String slot1 = 'clock';
  String slot2 = 'now_playing';

  // Grid settings
  double _topRatio = 0.5;
  double _innerPadding = 8.0;
  double _outerPadding = 12.0;
  double _borderRadius = 16.0;
  bool _autoRotate = true;

  // Tab visibility
  bool _showTabs = true;
  Timer? _hideTabsTimer;

  // Controls visibility for 2 grid
  bool _showGridControls = false;
  Timer? _hideControlsTimer;

  bool _isLoading = true;

  final Map<String, String> widgetOptions = {
    'clock': 'Clock',
    'now_playing': 'Now Playing',
    'tools': 'Tools (Calendar/Timer/Weather)',
    'quote': 'Quote',
    'battery': 'Battery Status',
    'countdown': 'Countdown',
    'photo': 'Photo Frame',
    'ambient': 'Ambient Animation',
    'notification': 'Notifications',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    _loadSettings();
    _startHideTabsTimer();
  }

  void _startHideTabsTimer() {
    _hideTabsTimer?.cancel();
    _hideTabsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showTabs = false);
    });
  }

  void _showTabsTemporarily() {
    setState(() => _showTabs = true);
    _startHideTabsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showGridControls = false);
    });
  }

  void _showControlsTemporarily() {
    setState(() => _showGridControls = true);
    _startHideControlsTimer();
  }

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        slot1 = p.getString('slot_1') ?? 'clock';
        slot2 = p.getString('slot_2') ?? 'now_playing';
        _topRatio = (p.getDouble('grid_top_ratio') ?? 0.5).clamp(0.4, 0.6);
        _innerPadding = p.getDouble('grid_inner_padding') ?? 8.0;
        _outerPadding = p.getDouble('grid_outer_padding') ?? 12.0;
        _borderRadius = p.getDouble('grid_border_radius') ?? 16.0;
        _autoRotate = p.getBool('auto_rotate') ?? true;
        _isLoading = false;
      });
      _applyRotationSettings();
    }
  }

  Future<void> _saveSettings() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('slot_1', slot1);
    await p.setString('slot_2', slot2);
    await p.setDouble('grid_top_ratio', _topRatio);
    await p.setDouble('grid_inner_padding', _innerPadding);
    await p.setDouble('grid_outer_padding', _outerPadding);
    await p.setDouble('grid_border_radius', _borderRadius);
    await p.setBool('auto_rotate', _autoRotate);
  }

  void _applyRotationSettings() {
    if (_autoRotate) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hideTabsTimer?.cancel();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragStart: (_) => _showTabsTemporarily(),
          onHorizontalDragStart: (_) => _showTabsTemporarily(),
          child: Column(
            children: [
              // Animated Tab bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showTabs ? 48 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showTabs ? 1.0 : 0.0,
                  child: Material(
                    color: Colors.black87,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      indicatorColor: Colors.blue,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      onTap: (_) => _startHideTabsTimer(),
                      tabs: const [
                        Tab(icon: Icon(Icons.settings, size: 20)),
                        Tab(text: '2 Grid'),
                        Tab(text: 'Clock'),
                        Tab(text: 'Music'),
                        Tab(text: 'Quote'),
                      ],
                    ),
                  ),
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const SingleChildScrollView(
                      padding: EdgeInsets.all(12.0),
                      child: SettingsWidget(),
                    ),
                    _buildTwoGridTab(),
                    const ClockWidget(),
                    const MediaWidget(),
                    const QuoteWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTwoGridTab() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: _showControlsTemporarily,
      child: Stack(
        children: [
          // Main content with grids
          Padding(
            padding: EdgeInsets.all(_outerPadding),
            child: isLandscape ? _buildHorizontalGrid() : _buildVerticalGrid(),
          ),

          // Control buttons overlay
          if (_showGridControls) ...[
            // First slot add button (top-left for portrait, left side for landscape)
            Positioned(
              top: _outerPadding + 8,
              left: _outerPadding + 8,
              child: _buildControlButton(
                icon: Icons.add,
                onTap: () => _showWidgetSelector(isTop: true),
              ),
            ),
            // Second slot add button
            Positioned(
              top: isLandscape
                  ? _outerPadding + 8
                  : _outerPadding +
                        (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom -
                                (_showTabs ? 48 : 0) -
                                _outerPadding * 2) *
                            _topRatio +
                        _innerPadding +
                        8,
              left: isLandscape
                  ? _outerPadding +
                        (MediaQuery.of(context).size.width -
                                _outerPadding * 2) *
                            _topRatio +
                        _innerPadding +
                        8
                  : _outerPadding + 8,
              child: _buildControlButton(
                icon: Icons.add,
                onTap: () => _showWidgetSelector(isTop: false),
              ),
            ),
            // Settings button (bottom-left)
            Positioned(
              bottom: _outerPadding + 8,
              left: _outerPadding + 8,
              child: _buildControlButton(
                icon: Icons.tune,
                onTap: _showGridSettings,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalGrid() {
    return Column(
      children: [
        Expanded(
          flex: (_topRatio * 100).toInt(),
          child: Container(
            margin: EdgeInsets.only(bottom: _innerPadding / 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: _widgetFor(slot1),
          ),
        ),
        Expanded(
          flex: ((1 - _topRatio) * 100).toInt(),
          child: Container(
            margin: EdgeInsets.only(top: _innerPadding / 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: _widgetFor(slot2),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalGrid() {
    return Row(
      children: [
        Expanded(
          flex: (_topRatio * 100).toInt(),
          child: Container(
            margin: EdgeInsets.only(right: _innerPadding / 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: _widgetFor(slot1),
          ),
        ),
        Expanded(
          flex: ((1 - _topRatio) * 100).toInt(),
          child: Container(
            margin: EdgeInsets.only(left: _innerPadding / 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: _widgetFor(slot2),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  void _showWidgetSelector({required bool isTop}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          isTop ? 'Pilih Widget Atas' : 'Pilih Widget Bawah',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widgetOptions.length,
            itemBuilder: (context, index) {
              final entry = widgetOptions.entries.elementAt(index);
              final isSelected = isTop
                  ? slot1 == entry.key
                  : slot2 == entry.key;
              return ListTile(
                leading: Icon(
                  _getWidgetIcon(entry.key),
                  color: isSelected ? Colors.blue : Colors.white70,
                ),
                title: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    if (isTop) {
                      slot1 = entry.key;
                    } else {
                      slot2 = entry.key;
                    }
                  });
                  _saveSettings();
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getWidgetIcon(String key) {
    switch (key) {
      case 'clock':
        return Icons.access_time;
      case 'now_playing':
        return Icons.music_note;
      case 'tools':
        return Icons.build;
      case 'quote':
        return Icons.format_quote;
      case 'battery':
        return Icons.battery_full;
      case 'countdown':
        return Icons.timer;
      case 'photo':
        return Icons.photo_library;
      case 'ambient':
        return Icons.animation;
      case 'notification':
        return Icons.notifications;
      default:
        return Icons.widgets;
    }
  }

  void _showGridSettings() {
    double tempTopRatio = _topRatio;
    double tempInnerPadding = _innerPadding;
    double tempOuterPadding = _outerPadding;
    double tempBorderRadius = _borderRadius;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Grid Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _buildSliderRow(
                label: 'Area Atas/Bawah',
                value: tempTopRatio,
                min: 0.4,
                max: 0.6,
                displayValue:
                    '${(tempTopRatio * 100).toInt()}% / ${((1 - tempTopRatio) * 100).toInt()}%',
                onChanged: (v) {
                  setModalState(() => tempTopRatio = v);
                  setState(() => _topRatio = v);
                },
              ),
              const SizedBox(height: 16),

              _buildSliderRow(
                label: 'Padding Dalam',
                value: tempInnerPadding,
                min: 0,
                max: 40,
                displayValue: '${tempInnerPadding.toInt()}',
                onChanged: (v) {
                  setModalState(() => tempInnerPadding = v);
                  setState(() => _innerPadding = v);
                },
              ),
              const SizedBox(height: 16),

              _buildSliderRow(
                label: 'Padding Luar',
                value: tempOuterPadding,
                min: 0,
                max: 40,
                displayValue: '${tempOuterPadding.toInt()}',
                onChanged: (v) {
                  setModalState(() => tempOuterPadding = v);
                  setState(() => _outerPadding = v);
                },
              ),
              const SizedBox(height: 16),

              _buildSliderRow(
                label: 'Border Radius',
                value: tempBorderRadius,
                min: 0,
                max: 70,
                displayValue: '${tempBorderRadius.toInt()}',
                onChanged: (v) {
                  setModalState(() => tempBorderRadius = v);
                  setState(() => _borderRadius = v);
                },
              ),
              const SizedBox(height: 24),

              // Auto-rotate toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Rotate',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        'Otomatis putar layar',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  Switch(
                    value: _autoRotate,
                    activeColor: Colors.blue,
                    onChanged: (v) {
                      setModalState(() {});
                      setState(() {
                        _autoRotate = v;
                        _applyRotationSettings();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _saveSettings();
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.grey[700],
            thumbColor: Colors.white,
            overlayColor: Colors.blue.withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _widgetFor(String key) {
    switch (key) {
      case 'clock':
        return const ClockWidget();
      case 'now_playing':
        return const MediaWidget();
      case 'tools':
        return const ToolsCarouselWidget();
      case 'quote':
        return const QuoteWidget();
      case 'battery':
        return const BatteryWidget();
      case 'countdown':
        return const CountdownWidget();
      case 'photo':
        return const PhotoFrameWidget();
      case 'ambient':
        return const AmbientWidget();
      case 'notification':
        return const NotificationWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}
