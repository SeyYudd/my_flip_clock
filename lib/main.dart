import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/clock_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'blocs/stopwatch_bloc.dart';
import 'blocs/pomodoro_bloc.dart';
import 'blocs/quote_bloc.dart';
import 'blocs/weather_bloc.dart';
import 'blocs/media_bloc.dart';
import 'blocs/calendar_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isOnboarded = prefs.getBool('initial_setup_done') ?? false;
  runApp(MyApp(isOnboarded: isOnboarded));
}

class MyApp extends StatelessWidget {
  final bool isOnboarded;
  const MyApp({super.key, required this.isOnboarded});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc()),
        BlocProvider(create: (_) => ClockBloc()),
        BlocProvider(create: (_) => StopwatchBloc()),
        BlocProvider(create: (_) => PomodoroBloc()),
        BlocProvider(create: (_) => QuoteBloc()..add(LoadQuotes())),
        BlocProvider(create: (_) => MediaBloc()),
        BlocProvider(create: (_) => CalendarBloc()),
        BlocProvider(create: (_) => WeatherBloc()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Stand Clock',
            builder: (context, child) => child!,
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            darkTheme: ThemeData.dark(),
            home: isOnboarded ? const HomeScreen() : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
