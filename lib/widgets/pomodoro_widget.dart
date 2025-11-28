import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/pomodoro_bloc.dart';

class PomodoroWidget extends StatelessWidget {
  const PomodoroWidget({super.key});

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pomodoro',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<PomodoroBloc, PomodoroState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Text(state.phase.toString().split('.').last),
                    Text(
                      _fmt(state.remaining),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.read<PomodoroBloc>().add(StartPomodoro()),
                  child: const Text('Start'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.read<PomodoroBloc>().add(PausePomodoro()),
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.read<PomodoroBloc>().add(ResetPomodoro()),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
