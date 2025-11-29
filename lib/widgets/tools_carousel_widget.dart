import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../blocs/calendar_bloc.dart';
import '../blocs/stopwatch_bloc.dart';
import '../blocs/pomodoro_bloc.dart';
import '../blocs/weather_bloc.dart';

class ToolsCarouselWidget extends StatefulWidget {
  const ToolsCarouselWidget({super.key});

  @override
  State<ToolsCarouselWidget> createState() => _ToolsCarouselWidgetState();
}

class _ToolsCarouselWidgetState extends State<ToolsCarouselWidget> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        scrollDirection: Axis.vertical,
        viewportFraction: 1.0,
        enableInfiniteScroll: true,
        onPageChanged: (index, reason) {
          setState(() => currentIndex = index);
        },
      ),
      items: [
        _CalendarView(),
        _StopwatchView(),
        _PomodoroView(),
        _WeatherView(),
      ],
    );
  }
}

// ============ CALENDAR VIEW ============
class _CalendarView extends StatefulWidget {
  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _autoLoadIfGranted();
  }

  Future<void> _autoLoadIfGranted() async {
    final status = await Permission.calendar.status;
    if (status.isGranted && !_checked) {
      _checked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<CalendarBloc>().add(LoadCalendar());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final day = DateFormat('dd').format(now);
    final month = DateFormat('MMMM').format(now);
    final year = DateFormat('yyyy').format(now);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo.shade900, Colors.black],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day name
          Text(
            dayName,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          // Day number
          Text(
            day,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          Text(
            month,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            year,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          // Upcoming events preview
          BlocBuilder<CalendarBloc, CalendarState>(
            builder: (context, state) {
              if (state.loading) {
                return const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
                  ),
                );
              }
              if (state.events.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'No upcoming events',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                );
              }
              final nextEvent = state.events.first;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      nextEvent['title'] ?? 'Event',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
class _StopwatchView extends StatelessWidget {
  String _formatTime(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(
      2,
      '0',
    );

    if (d.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds.$ms';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade900, Colors.black],
        ),
      ),
      child: BlocBuilder<StopwatchBloc, StopwatchState>(
        builder: (context, state) {
          final isRunning = state.running;
          final hasTime = state.elapsed.inMilliseconds > 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Label
              Text(
                'STOPWATCH',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),
              // Time display
              Text(
                _formatTime(state.elapsed),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 32),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  if (hasTime && !isRunning)
                    _buildCircleButton(
                      icon: Icons.refresh,
                      color: Colors.grey.shade700,
                      onTap: () =>
                          context.read<StopwatchBloc>().add(ResetStopwatch()),
                    ),
                  if (hasTime && !isRunning) const SizedBox(width: 24),
                  // Start/Stop button
                  _buildCircleButton(
                    icon: isRunning ? Icons.pause : Icons.play_arrow,
                    color: isRunning ? Colors.orange : Colors.teal,
                    size: 64,
                    iconSize: 32,
                    onTap: () {
                      if (isRunning) {
                        context.read<StopwatchBloc>().add(StopStopwatch());
                      } else {
                        context.read<StopwatchBloc>().add(StartStopwatch());
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 48,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

class _PomodoroView extends StatelessWidget {
  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getPhaseLabel(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return 'FOCUS TIME';
      case PomodoroPhase.breakShort:
        return 'SHORT BREAK';
      case PomodoroPhase.breakLong:
        return 'LONG BREAK';
      case PomodoroPhase.stopped:
        return 'READY';
    }
  }

  Color _getPhaseColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return Colors.red.shade700;
      case PomodoroPhase.breakShort:
        return Colors.green.shade700;
      case PomodoroPhase.breakLong:
        return Colors.blue.shade700;
      case PomodoroPhase.stopped:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        final phaseColor = _getPhaseColor(state.phase);
        final isRunning = state.running;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [phaseColor, Colors.black],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phase label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPhaseLabel(state.phase),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Timer display
              Text(
                _formatTime(state.remaining),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 32),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  if (!isRunning)
                    _buildCircleButton(
                      icon: Icons.refresh,
                      color: Colors.grey.shade700,
                      onTap: () =>
                          context.read<PomodoroBloc>().add(ResetPomodoro()),
                    ),
                  if (!isRunning) const SizedBox(width: 24),
                  // Start/Pause button
                  _buildCircleButton(
                    icon: isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    iconColor: phaseColor,
                    size: 64,
                    iconSize: 32,
                    onTap: () {
                      if (isRunning) {
                        context.read<PomodoroBloc>().add(PausePomodoro());
                      } else {
                        context.read<PomodoroBloc>().add(StartPomodoro());
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color? iconColor,
    double size = 48,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: iconSize),
      ),
    );
  }
}

class _WeatherView extends StatelessWidget {
  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('rain') || desc.contains('drizzle')) {
      return Icons.water_drop;
    } else if (desc.contains('cloud')) {
      return Icons.cloud;
    } else if (desc.contains('clear') || desc.contains('sun')) {
      return Icons.wb_sunny;
    } else if (desc.contains('snow')) {
      return Icons.ac_unit;
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return Icons.flash_on;
    } else if (desc.contains('fog') || desc.contains('mist')) {
      return Icons.blur_on;
    }
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.black],
        ),
      ),
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Weather icon
              Icon(
                _getWeatherIcon(state.description),
                size: 64,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 16),
              // Temperature
              Text(
                '${state.temperatureC.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                state.description.isEmpty ? 'Weather' : state.description,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 24),
              // Refresh button
              GestureDetector(
                onTap: () =>
                    context.read<WeatherBloc>().add(LoadWeather(-6.2, 106.8)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
