import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_stand_clock/screens/page_empty.dart';
import 'package:my_stand_clock/widgets/button/icon_button_wiget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../blocs/settings_bloc.dart';
import '../core/theme/app_theme.dart';
import '../screens/about_screen.dart';
import '../widgets/button/slider_row_widget.dart';
import '../widgets/button/toggle_row_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/clock_widget.dart';
import '../widgets/media_widget.dart';
import '../widgets/stopwatch_widget.dart';
import '../widgets/tools_carousel_widget.dart';
import '../widgets/quote_widget.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/photo_frame_widget.dart';
import '../widgets/notification_widget.dart';
import '../widgets/connectivity_widget.dart';
import '../widgets/gif_widget.dart';
import '../widgets/modern_widget_selector.dart';
import '../widgets/weather_widget.dart';

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

  bool _isLoading = true;

  // Burn-in protection
  Timer? _burnInTimer;
  double _burnInOffsetX = 0;
  double _burnInOffsetY = 0;
  double _overlayPosition = 0; // For overlay mode
  final Random _random = Random();

  // All available widgets
  final Map<String, String> widgetOptions = {
    'calendar': 'Calendar',
    'clock': 'Clock',
    'connectivity': 'Connectivity',
    'countdown': 'Countdown',
    'gif': 'GIF',
    'now_playing': 'Now Playing',
    'notification': 'Notification',
    'photo': 'Photo Frame',
    'pomodoro': 'Pomodoro',
    'quote': 'Quote',
    'stopwatch': 'Stopwatch',
    'tools': 'Tools Carousel',
    'weather': 'Weather',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    _loadSettings();
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
    _burnInTimer?.cancel();
    super.dispose();
  }

  void _startBurnInProtection(BurnInMode mode) {
    _burnInTimer?.cancel();
    if (mode == BurnInMode.shift) {
      // Shift content every 10 seconds with random offset (-5 to +5 pixels)
      _burnInTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted) {
          setState(() {
            _burnInOffsetX = (_random.nextDouble() * 10) - 5; // -5 to +5
            _burnInOffsetY = (_random.nextDouble() * 10) - 5; // -5 to +5
          });
        }
      });
    } else if (mode == BurnInMode.overlay) {
      // Move overlay every 10 seconds
      _burnInTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted) {
          setState(() {
            _overlayPosition = _random.nextDouble(); // 0.0 to 1.0
          });
        }
      });
    }
  }

  void _stopBurnInProtection() {
    _burnInTimer?.cancel();
    _burnInTimer = null;
    if (mounted) {
      setState(() {
        _burnInOffsetX = 0;
        _burnInOffsetY = 0;
        _overlayPosition = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.watch_later_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Loading your clock...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (prev, curr) => prev.burnInMode != curr.burnInMode,
      listener: (context, state) {
        if (state.burnInMode != BurnInMode.off) {
          _startBurnInProtection(state.burnInMode);
        } else {
          _stopBurnInProtection();
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (prev, curr) => prev.burnInMode != curr.burnInMode,
        builder: (context, settingsState) {
          // Start timer on first build if enabled
          if (settingsState.burnInMode != BurnInMode.off &&
              _burnInTimer == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startBurnInProtection(settingsState.burnInMode);
            });
          }

          return Scaffold(          
            body: Stack(
              children: [
                // Main content with optional shift
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  transform: Matrix4.translationValues(
                    settingsState.burnInMode == BurnInMode.shift
                        ? _burnInOffsetX
                        : 0,
                    settingsState.burnInMode == BurnInMode.shift
                        ? _burnInOffsetY
                        : 0,
                    0,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTwoGridTab(),
                      const ClockWidget(),
                      const MediaWidget(),
                      const QuoteWidget(),
                      const AboutScreen(),
                    ],
                  ),
                ),
                // Overlay layer for burn-in protection
                if (settingsState.burnInMode == BurnInMode.overlay)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                              -1 + (_overlayPosition * 2),
                              -1 + (_overlayPosition * 2),
                            ),
                            end: Alignment(
                              1 - (_overlayPosition * 2),
                              1 - (_overlayPosition * 2),
                            ),
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.03),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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
        Positioned(
          right: 0,
          top: 0,
          child: IconButtonWiget(
            iconData: const Icon(Icons.settings, size: 20),
            onTap: () => _showGridSettings(),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalGrid() {
    return Column(
      children: [
        Expanded(
          flex: (_topRatio * 100).toInt(),
          child: Container(
            margin: EdgeInsets.only(bottom: _innerPadding / 2),
            decoration: AppTheme.modernCard(borderRadius: _borderRadius),
            clipBehavior: Clip.antiAlias,
            child: _buildSlotContent(topWidgets, isTop: true),
          ),
        ),
        Expanded(
          flex: ((1 - _topRatio) * 100).toInt(),
          child: Container(
            margin: EdgeInsets.only(top: _innerPadding / 2),
            decoration: AppTheme.modernCard(borderRadius: _borderRadius),
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
            decoration: AppTheme.modernCard(borderRadius: _borderRadius),
            clipBehavior: Clip.antiAlias,
            child: _buildSlotContent(topWidgets, isTop: true),
          ),
        ),
        Expanded(
          flex: ((1 - _topRatio) * 100).toInt(),
          child: Container(
            margin: EdgeInsets.only(left: _innerPadding / 2),
            decoration: AppTheme.modernCard(borderRadius: _borderRadius),
            clipBehavior: Clip.antiAlias,
            child: _buildSlotContent(bottomWidgets, isTop: false),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotContent(List<String> widgets, {required bool isTop}) {
    if (widgets.isEmpty) {
      return GestureDetector(
        onTap: () => _showWidgetSelector(isTop: isTop),
        child: PageEmpty(),
      );
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
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton({required bool isTop}) {
    return IconButtonWiget(
      iconData: const Icon(Icons.add, color: Colors.white70, size: 18),
      onTap: () => _showWidgetSelector(isTop: isTop),
    );
  }

  void _showWidgetSelector({required bool isTop}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ModernWidgetSelector(
        currentWidgets: isTop ? topWidgets : bottomWidgets,
        widgetOptions: widgetOptions,
        isTop: isTop,
        onSave: (selected) {
          setState(() {
            if (isTop) {
              topWidgets = selected;
            } else {
              bottomWidgets = selected;
            }
          });
          _saveSettings();
        },
      ),
    );
  }

  void _showGridSettings() {
    double tempTopRatio = _topRatio;
    double tempInnerPadding = _innerPadding;
    double tempOuterPadding = _outerPadding;
    double tempBorderRadius = _borderRadius;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Grid Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Settings section
                _buildSettingsSection(
                  title: 'Layout',
                  children: [
                    BuildSliderRow(
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
                    BuildSliderRow(
                      label: 'Padding Dalam',
                      value: tempInnerPadding,
                      min: 0,
                      max: 40,
                      displayValue: '${tempInnerPadding.toInt()}px',
                      onChanged: (v) {
                        setModalState(() => tempInnerPadding = v);
                        setState(() => _innerPadding = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    BuildSliderRow(
                      label: 'Padding Luar',
                      value: tempOuterPadding,
                      min: 0,
                      max: 40,
                      displayValue: '${tempOuterPadding.toInt()}px',
                      onChanged: (v) {
                        setModalState(() => tempOuterPadding = v);
                        setState(() => _outerPadding = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    BuildSliderRow(
                      label: 'Border Radius',
                      value: tempBorderRadius,
                      min: 0,
                      max: 70,
                      displayValue: '${tempBorderRadius.toInt()}px',
                      onChanged: (v) {
                        setModalState(() => tempBorderRadius = v);
                        setState(() => _borderRadius = v);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Display settings
                _buildSettingsSection(
                  title: 'Display',
                  children: [
                    ToggleRowWidget(
                      title: 'Auto Rotate',
                      subtitle: 'Otomatis putar layar',
                      value: _autoRotate,
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

                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return _buildSettingsSection(
                      title: 'Advanced',
                      children: [
                        ToggleRowWidget(
                          title: 'Keep screen on',
                          subtitle: 'Layar selalu nyala',
                          value: state.keepScreenOn,
                          onChanged: (v) async {
                            context.read<SettingsBloc>().add(
                              UpdateKeepScreenOn(v),
                            );
                            if (v) {
                              await WakelockPlus.enable();
                            } else {
                              await WakelockPlus.disable();
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ToggleRowWidget(
                          title: 'Fullscreen',
                          subtitle: 'Sembunyikan status bar',
                          value: state.fullscreen,
                          onChanged: (v) async {
                            context.read<SettingsBloc>().add(
                              UpdateFullscreen(v),
                            );
                            if (v) {
                              await SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.immersiveSticky,
                              );
                            } else {
                              await SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Burn-in protection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Burn-in Protection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Cegah burn-in pada layar OLED',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<BurnInMode>(
                              onSelected: (mode) {
                                context.read<SettingsBloc>().add(
                                  UpdateBurnInMode(mode),
                                );
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: BurnInMode.off,
                                  child: Text('Off'),
                                ),
                                PopupMenuItem(
                                  value: BurnInMode.shift,
                                  child: Text('Shift'),
                                ),
                                PopupMenuItem(
                                  value: BurnInMode.overlay,
                                  child: Text('Overlay'),
                                ),
                              ],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.burnInMode == BurnInMode.off
                                        ? 'Off'
                                        : state.burnInMode == BurnInMode.shift
                                        ? 'Shift'
                                        : 'Overlay',
                                    style: TextStyle(
                                      color: state.burnInMode == BurnInMode.off
                                          ? Colors.grey
                                          : Colors.blue,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white60,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

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
      ),
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
      case 'weather':
        return const WeatherWidget();
      case 'countdown':
        return const CountdownWidget();
      case 'photo':
        return const PhotoFrameWidget();
      case 'notification':
        return const NotificationWidget();
      case 'calendar':
        return const CalendarWidget();
      case 'stopwatch':
        return const StopwatchWidget();
      case 'connectivity':
        return const ConnectivityWidget();
      case 'gif':
        return const GifWidget();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
