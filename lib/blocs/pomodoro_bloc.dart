import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PomodoroPhase { work, breakShort, breakLong, stopped }

class PomodoroState extends Equatable {
  final PomodoroPhase phase;
  final Duration remaining;
  final bool running;

  const PomodoroState({
    required this.phase,
    required this.remaining,
    required this.running,
  });

  PomodoroState copyWith({
    PomodoroPhase? phase,
    Duration? remaining,
    bool? running,
  }) => PomodoroState(
    phase: phase ?? this.phase,
    remaining: remaining ?? this.remaining,
    running: running ?? this.running,
  );

  @override
  List<Object?> get props => [phase, remaining, running];
}

abstract class PomodoroEvent {}

class StartPomodoro extends PomodoroEvent {}

class PausePomodoro extends PomodoroEvent {}

class ResetPomodoro extends PomodoroEvent {}

class _PomodoroTick extends PomodoroEvent {}

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 25);
  PomodoroPhase _phase = PomodoroPhase.stopped;

  PomodoroBloc()
    : super(
        const PomodoroState(
          phase: PomodoroPhase.stopped,
          remaining: Duration.zero,
          running: false,
        ),
      ) {
    on<StartPomodoro>(_onStart);
    on<PausePomodoro>(_onPause);
    on<ResetPomodoro>(_onReset);
    on<_PomodoroTick>((e, emit) => _onTick(emit));
  }

  void _onStart(StartPomodoro e, Emitter<PomodoroState> emit) {
    if (_timer != null) return;
    _phase = PomodoroPhase.work;
    _remaining = const Duration(minutes: 25);
    emit(PomodoroState(phase: _phase, remaining: _remaining, running: true));
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(_PomodoroTick()),
    );
  }

  void _onPause(PausePomodoro e, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(running: false));
  }

  void _onReset(ResetPomodoro e, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    _timer = null;
    _phase = PomodoroPhase.stopped;
    _remaining = Duration.zero;
    emit(PomodoroState(phase: _phase, remaining: _remaining, running: false));
  }

  void _onTick(Emitter<PomodoroState> emit) {
    if (_remaining.inSeconds <= 0) {
      _timer?.cancel();
      _timer = null;
      emit(state.copyWith(running: false));
      return;
    }
    _remaining = _remaining - const Duration(seconds: 1);
    emit(PomodoroState(phase: _phase, remaining: _remaining, running: true));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
