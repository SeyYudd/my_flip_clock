import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StopwatchState extends Equatable {
  final Duration elapsed;
  final bool running;

  const StopwatchState({required this.elapsed, required this.running});

  StopwatchState copyWith({Duration? elapsed, bool? running}) => StopwatchState(
    elapsed: elapsed ?? this.elapsed,
    running: running ?? this.running,
  );

  @override
  List<Object?> get props => [elapsed, running];
}

abstract class StopwatchEvent {}

class StartStopwatch extends StopwatchEvent {}

class StopStopwatch extends StopwatchEvent {}

class ResetStopwatch extends StopwatchEvent {}

class _Tick extends StopwatchEvent {
  final Duration elapsed;
  _Tick(this.elapsed);
}

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  StopwatchBloc()
    : super(const StopwatchState(elapsed: Duration.zero, running: false)) {
    on<StartStopwatch>(_onStart);
    on<StopStopwatch>(_onStop);
    on<ResetStopwatch>(_onReset);
    on<_Tick>(_onTick);
  }

  void _onStart(StartStopwatch e, Emitter<StopwatchState> emit) {
    if (_timer != null) return;
    emit(state.copyWith(running: true));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _elapsed += const Duration(milliseconds: 100);
      add(_Tick(_elapsed));
    });
  }

  void _onStop(StopStopwatch e, Emitter<StopwatchState> emit) {
    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(running: false));
  }

  void _onReset(ResetStopwatch e, Emitter<StopwatchState> emit) {
    _elapsed = Duration.zero;
    emit(state.copyWith(elapsed: Duration.zero, running: false));
  }

  void _onTick(_Tick e, Emitter<StopwatchState> emit) {
    emit(state.copyWith(elapsed: e.elapsed));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
