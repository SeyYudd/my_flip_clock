import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class WeatherState extends Equatable {
  final String description;
  final double temperatureC;
  final bool loading;

  const WeatherState({
    required this.description,
    required this.temperatureC,
    required this.loading,
  });

  WeatherState copyWith({
    String? description,
    double? temperatureC,
    bool? loading,
  }) => WeatherState(
    description: description ?? this.description,
    temperatureC: temperatureC ?? this.temperatureC,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [description, temperatureC, loading];
}

abstract class WeatherEvent {}

class LoadWeather extends WeatherEvent {
  final double lat;
  final double lon;
  LoadWeather(this.lat, this.lon);
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc()
    : super(
        const WeatherState(description: '-', temperatureC: 0.0, loading: false),
      ) {
    on<LoadWeather>(_onLoad);
  }

  Future<void> _onLoad(LoadWeather e, Emitter<WeatherState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      // Use open-meteo free API (no key) for quick demo
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${e.lat}&longitude=${e.lon}&current_weather=true&temperature_unit=celsius',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final current = body['current_weather'] as Map<String, dynamic>?;
        if (current != null) {
          final temp = (current['temperature'] as num).toDouble();
          final desc = 'Clear/Clouds';
          emit(
            state.copyWith(
              description: desc,
              temperatureC: temp,
              loading: false,
            ),
          );
          return;
        }
      }
    } catch (_) {}
    emit(state.copyWith(description: 'N/A', temperatureC: 0.0, loading: false));
  }
}
