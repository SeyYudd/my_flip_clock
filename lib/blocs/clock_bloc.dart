import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ClockMode { digital, analog }

class ClockState extends Equatable {
  final DateTime now;
  final ClockMode mode;

  const ClockState({required this.now, required this.mode});

  ClockState copyWith({DateTime? now, ClockMode? mode}) =>
      ClockState(now: now ?? this.now, mode: mode ?? this.mode);

  @override
  List<Object?> get props => [now, mode];
}

abstract class ClockEvent {}

class Tick extends ClockEvent {}

class ToggleMode extends ClockEvent {}

class ClockBloc extends Bloc<ClockEvent, ClockState> {
  Timer? _timer;

  ClockBloc()
    : super(ClockState(now: DateTime.now(), mode: ClockMode.digital)) {
    on<Tick>((e, emit) => emit(state.copyWith(now: DateTime.now())));
    on<ToggleMode>(
      (e, emit) => emit(
        state.copyWith(
          mode: state.mode == ClockMode.digital
              ? ClockMode.analog
              : ClockMode.digital,
        ),
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(Tick()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
