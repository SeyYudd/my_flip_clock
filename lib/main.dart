import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'core/theme/app_theme.dart';
import 'core/constants/storage_keys.dart';
import 'core/utils/orientation_converter.dart';
import 'core/services/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  ErrorHandler.initialize();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('⚠️ .env file not found, using defaults');
  }

  final prefs = await SharedPreferences.getInstance();
  final isOnboarded = prefs.getBool(StorageKeys.initialSetupDone) ?? false;

  // Load dan apply settings yang tersimpan
  await _applyPersistedSettings(prefs);

  runApp(MyApp(isOnboarded: isOnboarded));
}

/// Apply persisted settings at app startup
/// Uses centralized StorageKeys and OrientationConverter - NO MAGIC STRINGS! ✨
Future<void> _applyPersistedSettings(SharedPreferences prefs) async {
  // Apply fullscreen setting
  final fullscreen = prefs.getBool(StorageKeys.fullscreen) ?? false;
  if (fullscreen) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } else {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // Apply keep screen on setting
  final keepScreenOn = prefs.getBool(StorageKeys.keepScreenOn) ?? false;
  if (keepScreenOn) {
    await WakelockPlus.enable();
  } else {
    await WakelockPlus.disable();
  }

  // Apply orientation setting - using OrientationConverter (DRY!) 🎯
  final orientationList = prefs.getStringList(StorageKeys.orientations);
  if (orientationList != null && orientationList.isNotEmpty) {
    final orientations = OrientationConverter.listFromString(orientationList);
    await SystemChrome.setPreferredOrientations(orientations);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isOnboarded});

  final bool isOnboarded;

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
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: isOnboarded ? const HomeScreen() : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
