import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:analog_clock/analog_clock.dart';
import '../blocs/clock_bloc.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  bool _showControls = false;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Predefined colors for analog clock elements
  static const List<Color> availableColors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];

  // Predefined digital themes
  static const List<DigitalTheme> digitalThemes = [
    DigitalTheme(
      name: 'Classic White',
      primaryColor: Colors.white,
      backgroundColor: Colors.black,
    ),
    DigitalTheme(
      name: 'Neon Green',
      primaryColor: Color(0xFF00FF00),
      backgroundColor: Color(0xFF001100),
    ),
    DigitalTheme(
      name: 'Retro Amber',
      primaryColor: Color(0xFFFFB300),
      backgroundColor: Color(0xFF1A1000),
    ),
    DigitalTheme(
      name: 'Ocean Blue',
      primaryColor: Color(0xFF00BFFF),
      backgroundColor: Color(0xFF001020),
    ),
    DigitalTheme(
      name: 'Hot Pink',
      primaryColor: Color(0xFFFF1493),
      backgroundColor: Color(0xFF100010),
    ),
    DigitalTheme(
      name: 'Cyber Purple',
      primaryColor: Color(0xFF8A2BE2),
      backgroundColor: Color(0xFF0A000A),
    ),
    DigitalTheme(
      name: 'Fire Red',
      primaryColor: Color(0xFFFF4500),
      backgroundColor: Color(0xFF100500),
    ),
    DigitalTheme(
      name: 'Matrix',
      primaryColor: Color(0xFF00FF41),
      backgroundColor: Colors.black,
    ),
    DigitalTheme(
      name: 'Sunset',
      primaryColor: Color(0xFFFF6B35),
      backgroundColor: Color(0xFF1A0A05),
    ),
    DigitalTheme(
      name: 'Ice Blue',
      primaryColor: Color(0xFF87CEEB),
      backgroundColor: Color(0xFF050A10),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, ClockState>(
      buildWhen: (prev, curr) =>
          prev.style != curr.style ||
          prev.now.second != curr.now.second ||
          prev.digitalThemeIndex != curr.digitalThemeIndex ||
          prev.analogHourColor != curr.analogHourColor ||
          prev.analogMinuteColor != curr.analogMinuteColor ||
          prev.analogSecondColor != curr.analogSecondColor ||
          prev.analogBackgroundColor != curr.analogBackgroundColor,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Main carousel
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1.0,
                    scrollDirection: Axis.vertical,
                    enableInfiniteScroll: true,
                    initialPage: state.style.index,
                    onPageChanged: (index, reason) {
                      context.read<ClockBloc>().add(
                        ChangeClockStyle(ClockStyle.values[index]),
                      );
                    },
                  ),
                  items: [_buildAnalogClock(state), _buildDigitalClock(state)],
                ),
                // Edit button overlay
                if (_showControls)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => _showEditDialog(context, state),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                // Style indicator
                if (_showControls)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.style.index == index
                                ? Colors.white
                                : Colors.white30,
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalogClock(ClockState state) {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(state.analogBackgroundColor),
        ),
        child: AnalogClock(
          datetime: state.now,
          isLive: false,
          showDigitalClock: false,
          showNumbers: true,
          showAllNumbers: true,
          showTicks: true,
          hourHandColor: Color(state.analogHourColor),
          minuteHandColor: Color(state.analogMinuteColor),
          secondHandColor: Color(state.analogSecondColor),
          numberColor: Color(state.analogHourColor),
          tickColor: Color(state.analogMinuteColor),
        ),
      ),
    );
  }

  Widget _buildDigitalClock(ClockState state) {
    final theme = digitalThemes[state.digitalThemeIndex];
    final hour = state.now.hour.toString().padLeft(2, '0');
    final minute = state.now.minute.toString().padLeft(2, '0');
    final second = state.now.second.toString().padLeft(2, '0');

    return Container(
      color: theme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hour:$minute',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                fontFamily: 'monospace',
                letterSpacing: 4,
              ),
            ),
            Text(
              second,
              style: TextStyle(
                fontSize: 32,
                color: theme.primaryColor.withOpacity(0.7),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ClockState state) {
    if (state.style == ClockStyle.analog) {
      _showAnalogEditDialog(context, state);
    } else {
      _showDigitalEditDialog(context, state);
    }
  }

  void _showDigitalEditDialog(BuildContext context, ClockState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Pilih Tema Digital',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: digitalThemes.length,
            itemBuilder: (context, index) {
              final theme = digitalThemes[index];
              final isSelected = state.digitalThemeIndex == index;
              return GestureDetector(
                onTap: () {
                  context.read<ClockBloc>().add(UpdateDigitalTheme(index));
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '12:34',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        theme.name,
                        style: TextStyle(
                          color: theme.primaryColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle, color: theme.primaryColor),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAnalogEditDialog(BuildContext context, ClockState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Pengaturan Analog',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorRow(
                  context: context,
                  label: 'Jam',
                  selectedColor: state.analogHourColor,
                  onColorSelected: (color) {
                    context.read<ClockBloc>().add(UpdateAnalogHourColor(color));
                  },
                ),
                const SizedBox(height: 16),
                _buildColorRow(
                  context: context,
                  label: 'Menit',
                  selectedColor: state.analogMinuteColor,
                  onColorSelected: (color) {
                    context.read<ClockBloc>().add(
                      UpdateAnalogMinuteColor(color),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildColorRow(
                  context: context,
                  label: 'Detik',
                  selectedColor: state.analogSecondColor,
                  onColorSelected: (color) {
                    context.read<ClockBloc>().add(
                      UpdateAnalogSecondColor(color),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildColorRow(
                  context: context,
                  label: 'Background',
                  selectedColor: state.analogBackgroundColor,
                  onColorSelected: (color) {
                    context.read<ClockBloc>().add(
                      UpdateAnalogBackgroundColor(color),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow({
    required BuildContext context,
    required String label,
    required int selectedColor,
    required Function(int) onColorSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = color.value == selectedColor;
              return GestureDetector(
                onTap: () => onColorSelected(color.value),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DigitalTheme {
  final String name;
  final Color primaryColor;
  final Color backgroundColor;

  const DigitalTheme({
    required this.name,
    required this.primaryColor,
    required this.backgroundColor,
  });
}
