import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarEvent {}

class LoadCalendar extends CalendarEvent {}

class CalendarState extends Equatable {
  final List<Map<String, dynamic>> events;
  final bool loading;
  final String? error;

  const CalendarState({
    this.events = const [],
    this.loading = false,
    this.error,
  });

  CalendarState copyWith({
    List<Map<String, dynamic>>? events,
    bool? loading,
    String? error,
  }) => CalendarState(
    events: events ?? this.events,
    loading: loading ?? this.loading,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [events, loading, error];
}

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  static const _channel = MethodChannel('calendar_channel');

  CalendarBloc() : super(const CalendarState()) {
    on<LoadCalendar>((e, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final res = await _channel.invokeMethod('getEvents');
        if (res is List) {
          final list = res
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          emit(state.copyWith(events: list, loading: false));
        } else {
          emit(
            state.copyWith(
              events: [],
              loading: false,
              error: 'unexpected_result',
            ),
          );
        }
      } catch (err) {
        emit(state.copyWith(events: [], loading: false, error: err.toString()));
      }
    });
  }
}
