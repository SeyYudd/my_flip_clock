import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/clock_widget.dart';
import '../widgets/media_placeholder.dart';
import '../widgets/calendar_placeholder.dart';
import '../widgets/stopwatch_widget.dart';
import '../widgets/pomodoro_widget.dart';
import '../widgets/weather_widget.dart';
import '../widgets/quote_widget.dart';
import '../widgets/settings_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Stand Clock')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final tiles = <Widget>[
              const ClockWidget(),
              const MediaPlaceholder(),
              const CalendarPlaceholder(),
              const StopwatchWidget(),
              const PomodoroWidget(),
              const WeatherWidget(),
              const QuoteWidget(),
              const SettingsWidget(),
            ];

            if (state.layoutMode == LayoutMode.single) {
              // show a vertical list (single column)
              return ListView.separated(
                itemCount: tiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => tiles[i],
              );
            }

            // 2-grid layout
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: tiles,
            );
          },
        ),
      ),
    );
  }
}
