import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clock style types - simplified to 2 types
enum ClockStyle { analog, digital }

class ClockState extends Equatable {
  final DateTime now;
  final ClockStyle style;
  // Digital theme index
  final int digitalThemeIndex;
  // Analog individual colors
  final int analogHourColor;
  final int analogMinuteColor;
  final int analogSecondColor;
  final int analogBackgroundColor;

  const ClockState({
    required this.now,
    this.style = ClockStyle.analog,
    this.digitalThemeIndex = 0,
    this.analogHourColor = 0xFFFFFFFF,
    this.analogMinuteColor = 0xFFFFFFFF,
    this.analogSecondColor = 0xFFFF5722,
    this.analogBackgroundColor = 0xFF000000,
  });

  ClockState copyWith({
    DateTime? now,
    ClockStyle? style,
    int? digitalThemeIndex,
    int? analogHourColor,
    int? analogMinuteColor,
    int? analogSecondColor,
    int? analogBackgroundColor,
  }) => ClockState(
    now: now ?? this.now,
    style: style ?? this.style,
    digitalThemeIndex: digitalThemeIndex ?? this.digitalThemeIndex,
    analogHourColor: analogHourColor ?? this.analogHourColor,
    analogMinuteColor: analogMinuteColor ?? this.analogMinuteColor,
    analogSecondColor: analogSecondColor ?? this.analogSecondColor,
    analogBackgroundColor: analogBackgroundColor ?? this.analogBackgroundColor,
  );

  @override
  List<Object?> get props => [
    now,
    style,
    digitalThemeIndex,
    analogHourColor,
    analogMinuteColor,
    analogSecondColor,
    analogBackgroundColor,
  ];
}

abstract class ClockEvent {}

class Tick extends ClockEvent {}

class ChangeClockStyle extends ClockEvent {
  final ClockStyle style;
  ChangeClockStyle(this.style);
}

class UpdateDigitalTheme extends ClockEvent {
  final int themeIndex;
  UpdateDigitalTheme(this.themeIndex);
}

class UpdateAnalogHourColor extends ClockEvent {
  final int color;
  UpdateAnalogHourColor(this.color);
}

class UpdateAnalogMinuteColor extends ClockEvent {
  final int color;
  UpdateAnalogMinuteColor(this.color);
}

class UpdateAnalogSecondColor extends ClockEvent {
  final int color;
  UpdateAnalogSecondColor(this.color);
}

class UpdateAnalogBackgroundColor extends ClockEvent {
  final int color;
  UpdateAnalogBackgroundColor(this.color);
}

class LoadClockSettings extends ClockEvent {}

class ClockBloc extends Bloc<ClockEvent, ClockState> {
  Timer? _timer;

  ClockBloc() : super(ClockState(now: DateTime.now())) {
    on<Tick>((e, emit) => emit(state.copyWith(now: DateTime.now())));
    on<ChangeClockStyle>(_onChangeStyle);
    on<UpdateDigitalTheme>(_onUpdateDigitalTheme);
    on<UpdateAnalogHourColor>(_onUpdateAnalogHour);
    on<UpdateAnalogMinuteColor>(_onUpdateAnalogMinute);
    on<UpdateAnalogSecondColor>(_onUpdateAnalogSecond);
    on<UpdateAnalogBackgroundColor>(_onUpdateAnalogBackground);
    on<LoadClockSettings>(_onLoadSettings);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(Tick()));
    add(LoadClockSettings());
  }

  Future<void> _onLoadSettings(
    LoadClockSettings e,
    Emitter<ClockState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final styleIndex = prefs.getInt('clock_style') ?? 0;
    final digitalTheme = prefs.getInt('clock_digital_theme') ?? 0;
    final hourColor = prefs.getInt('clock_analog_hour') ?? 0xFFFFFFFF;
    final minuteColor = prefs.getInt('clock_analog_minute') ?? 0xFFFFFFFF;
    final secondColor = prefs.getInt('clock_analog_second') ?? 0xFFFF5722;
    final bgColor = prefs.getInt('clock_analog_background') ?? 0xFF000000;

    emit(
      state.copyWith(
        style: ClockStyle
            .values[styleIndex.clamp(0, ClockStyle.values.length - 1)],
        digitalThemeIndex: digitalTheme,
        analogHourColor: hourColor,
        analogMinuteColor: minuteColor,
        analogSecondColor: secondColor,
        analogBackgroundColor: bgColor,
      ),
    );
  }

  Future<void> _onChangeStyle(
    ChangeClockStyle e,
    Emitter<ClockState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clock_style', e.style.index);
    emit(state.copyWith(style: e.style));
  }

  Future<void> _onUpdateDigitalTheme(
    UpdateDigitalTheme e,
    Emitter<ClockState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clock_digital_theme', e.themeIndex);
    emit(state.copyWith(digitalThemeIndex: e.themeIndex));
  }

  Future<void> _onUpdateAnalogHour(
    UpdateAnalogHourColor e,
    Emitter<ClockState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clock_analog_hour', e.color);
    emit(state.copyWith(analogHourColor: e.color));
  }

  Future<void> _onUpdateAnalogMinute(
    UpdateAnalogMinuteColor e,
    Emitter<ClockState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clock_analog_minute', e.color);
    emit(state.copyWith(analogMinuteColor: e.color));
  }

  Future<void> _onUpdateAnalogSecond(
    UpdateAnalogSecondColor e,
    Emitter<ClockState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clock_analog_second', e.color);
    emit(state.copyWith(analogSecondColor: e.color));
  }

  Future<void> _onUpdateAnalogBackground(
    UpdateAnalogBackgroundColor e,
    Emitter<ClockState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clock_analog_background', e.color);
    emit(state.copyWith(analogBackgroundColor: e.color));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
