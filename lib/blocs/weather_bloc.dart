import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../core/services/cache_service.dart';
import '../core/services/error_handler.dart';
import '../core/services/location_service.dart';

class WeatherState extends Equatable {
  final String description;
  final double temperatureC;
  final bool loading;
  final String? error;

  const WeatherState({
    required this.description,
    required this.temperatureC,
    required this.loading,
    this.error,
  });

  WeatherState copyWith({
    String? description,
    double? temperatureC,
    bool? loading,
    String? error,
  }) => WeatherState(
    description: description ?? this.description,
    temperatureC: temperatureC ?? this.temperatureC,
    loading: loading ?? this.loading,
    error: error,
  );

  @override
  List<Object?> get props => [description, temperatureC, loading, error];
}

abstract class WeatherEvent {}

class LoadWeather extends WeatherEvent {}

class LoadWeatherWithCoordinates extends WeatherEvent {
  final double lat;
  final double lon;
  LoadWeatherWithCoordinates(this.lat, this.lon);
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc()
    : super(
        const WeatherState(description: '-', temperatureC: 0.0, loading: false),
      ) {
    on<LoadWeather>(_onLoad);
    on<LoadWeatherWithCoordinates>(_onLoadWithCoordinates);
  }

  Future<void> _onLoad(LoadWeather e, Emitter<WeatherState> emit) async {
    emit(state.copyWith(loading: true));

    try {
      // Try to get user's location
      final coords = await LocationService().getCoordinates();
      final lat = coords['latitude']!;
      final lon = coords['longitude']!;

      await _fetchWeather(lat, lon, emit);
    } catch (e, stack) {
      ErrorHandler().handleApiError('Weather', e, stackTrace: stack);
      // Try to load from cache
      await _loadFromCache(emit);
    }
  }

  Future<void> _onLoadWithCoordinates(
    LoadWeatherWithCoordinates e,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    await _fetchWeather(e.lat, e.lon, emit);
  }

  Future<void> _fetchWeather(
    double lat,
    double lon,
    Emitter<WeatherState> emit,
  ) async {
    try {
      // Use open-meteo free API (no key) for quick demo
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&temperature_unit=celsius',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final current = body['current_weather'] as Map<String, dynamic>?;
        if (current != null) {
          final temp = (current['temperature'] as num).toDouble();
          final desc = 'Clear/Clouds';

          // Cache the result
          await CacheService().cache('weather', {
            'description': desc,
            'temperature': temp,
            'lat': lat,
            'lon': lon,
          }, expiry: const Duration(minutes: 30));

          emit(
            state.copyWith(
              description: desc,
              temperatureC: temp,
              loading: false,
              error: null,
            ),
          );
          return;
        }
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e, stack) {
      ErrorHandler().handleApiError('Weather', e, stackTrace: stack);
      await _loadFromCache(emit);
    }
  }

  Future<void> _loadFromCache(Emitter<WeatherState> emit) async {
    final cached = await CacheService().get('weather');
    if (cached != null) {
      emit(
        state.copyWith(
          description: cached['description'] as String,
          temperatureC: (cached['temperature'] as num).toDouble(),
          loading: false,
          error: 'Using cached data',
        ),
      );
    } else {
      emit(
        state.copyWith(
          description: 'N/A',
          temperatureC: 0.0,
          loading: false,
          error: 'Unable to load weather',
        ),
      );
    }
  }
}
