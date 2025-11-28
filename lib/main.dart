import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/clock_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'blocs/stopwatch_bloc.dart';
import 'blocs/pomodoro_bloc.dart';
import 'blocs/quote_bloc.dart';
import 'blocs/weather_bloc.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc()),
        BlocProvider(create: (_) => ClockBloc()),
        BlocProvider(create: (_) => StopwatchBloc()),
        BlocProvider(create: (_) => PomodoroBloc()),
        BlocProvider(create: (_) => QuoteBloc()..add(LoadQuotes())),
        BlocProvider(create: (_) => WeatherBloc()),
      ],
      child: MaterialApp(
        title: 'My Stand Clock',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
