import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_stand_clock/screens/page_empty.dart';
import '../blocs/weather_bloc.dart';

class WeatherWidget extends StatelessWidget {
  final double lat;
  final double lon;
  const WeatherWidget({super.key, this.lat = -6.2, this.lon = 106.8});

  @override
  Widget build(BuildContext context) {
    return PageEmpty(
      icon: Icons.cloud,
      title: 'Weather Widget',
      message: '',
      widget: Column(
        children: [
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state.loading) return const CircularProgressIndicator();
              return Column(
                children: [
                  Text(state.description),
                  Text(
                    '${state.temperatureC.toStringAsFixed(1)} °C',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.read<WeatherBloc>().add(LoadWeather()),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
