import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import '../widgets/connectivity_widget.dart';
import '../widgets/gif_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Slot widget keys - now lists for carousel
  List<String> topWidgets = [];
  List<String> bottomWidgets = [];

  // Grid settings
  double _topRatio = 0.5;
  double _innerPadding = 8.0;
  double _outerPadding = 12.0;
  double _borderRadius = 16.0;
  bool _autoRotate = true;

  // Tab visibility
  bool _showTabs = true;
  Timer? _hideTabsTimer;

  // Bottom nav bar visibility
  bool _showBottomNav = false;

  bool _isLoading = true;

  // All available widgets
  final Map<String, String> widgetOptions = {
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

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      final topJson = p.getString('top_widgets');
      final bottomJson = p.getString('bottom_widgets');

      setState(() {
        topWidgets = topJson != null
            ? List<String>.from(jsonDecode(topJson))
            : [];
        bottomWidgets = bottomJson != null
            ? List<String>.from(jsonDecode(bottomJson))
            : [];
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
    await p.setString('top_widgets', jsonEncode(topWidgets));
    await p.setString('bottom_widgets', jsonEncode(bottomWidgets));
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

    return Stack(
      children: [
        // Main content with grids
        Padding(
          padding: EdgeInsets.all(_outerPadding),
          child: isLandscape ? _buildHorizontalGrid() : _buildVerticalGrid(),
        ),

        // Bottom Navigation Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => setState(() => _showBottomNav = !_showBottomNav),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showBottomNav ? 100 : 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: _showBottomNav
                  ? _buildExpandedBottomNav()
                  : _buildCollapsedBottomNav(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedBottomNav() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildExpandedBottomNav() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(
                  icon: Icons.tune,
                  label: 'Settings',
                  onTap: _showGridSettings,
                ),
                _buildNavButton(
                  icon: Icons.rotate_right,
                  label: _autoRotate ? 'Auto ON' : 'Auto OFF',
                  onTap: () {
                    setState(() {
                      _autoRotate = !_autoRotate;
                      _applyRotationSettings();
                    });
                    _saveSettings();
                  },
                  isActive: _autoRotate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.withOpacity(0.2) : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.blue : Colors.white70,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.white70,
              fontSize: 10,
            ),
          ),
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
            child: _buildSlotContent(topWidgets, isTop: true),
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
            child: _buildSlotContent(bottomWidgets, isTop: false),
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
            child: _buildSlotContent(topWidgets, isTop: true),
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
            child: _buildSlotContent(bottomWidgets, isTop: false),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotContent(List<String> widgets, {required bool isTop}) {
    if (widgets.isEmpty) {
      return _buildEmptySlot(isTop: isTop);
    }

    if (widgets.length == 1) {
      return Stack(
        children: [
          _widgetFor(widgets.first),
          Positioned(top: 8, left: 8, child: _buildAddButton(isTop: isTop)),
        ],
      );
    }

    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: widgets.length,
          itemBuilder: (context, index, realIndex) {
            return _widgetFor(widgets[index]);
          },
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            enableInfiniteScroll: widgets.length > 1,
            autoPlay: false,
          ),
        ),
        Positioned(top: 8, left: 8, child: _buildAddButton(isTop: isTop)),
        // Page indicator
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widgets.asMap().entries.map((entry) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlot({required bool isTop}) {
    return GestureDetector(
      onTap: () => _showWidgetSelector(isTop: isTop),
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade900,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white70, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih Widget',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              isTop ? 'Slot Atas' : 'Slot Bawah',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({required bool isTop}) {
    return GestureDetector(
      onTap: () => _showWidgetSelector(isTop: isTop),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.edit, color: Colors.white70, size: 18),
      ),
    );
  }

  void _showWidgetSelector({required bool isTop}) {
    final currentWidgets = isTop ? topWidgets : bottomWidgets;
    final selectedWidgets = List<String>.from(currentWidgets);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isTop ? 'Pilih Widget Atas' : 'Pilih Widget Bawah',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih beberapa untuk carousel',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 16),
                // Widget list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widgetOptions.length,
                    itemBuilder: (context, index) {
                      final entry = widgetOptions.entries.elementAt(index);
                      final isSelected = selectedWidgets.contains(entry.key);
                      final orderIndex = selectedWidgets.indexOf(entry.key);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.withOpacity(0.15)
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.blue, width: 1.5)
                              : null,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getWidgetIcon(entry.key),
                              color: isSelected ? Colors.blue : Colors.white70,
                              size: 20,
                            ),
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
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${orderIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedWidgets.remove(entry.key);
                              } else {
                                selectedWidgets.add(entry.key);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setModalState(() => selectedWidgets.clear());
                          },
                          child: const Text(
                            'Hapus Semua',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isTop) {
                                topWidgets = selectedWidgets;
                              } else {
                                bottomWidgets = selectedWidgets;
                              }
                            });
                            _saveSettings();
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            'Simpan (${selectedWidgets.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
      case 'connectivity':
        return Icons.wifi;
      case 'gif':
        return Icons.gif_box;
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
      case 'connectivity':
        return const ConnectivityWidget();
      case 'gif':
        return const GifWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}
