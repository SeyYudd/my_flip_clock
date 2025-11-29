import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../blocs/calendar_bloc.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _autoLoadIfGranted();
  }

  Future<void> _autoLoadIfGranted() async {
    final status = await Permission.calendar.status;
    if (status.isGranted) {
      // Only trigger once
      if (!_checked) {
        _checked = true;
        // trigger load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.read<CalendarBloc>().add(LoadCalendar());
        });
      }
    }
  }

  Future<void> _requestAndLoad() async {
    final status = await Permission.calendar.request();
    if (status.isGranted) {
      context.read<CalendarBloc>().add(LoadCalendar());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendar permission denied.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Calendar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
                if (state.loading) return const CircularProgressIndicator();
                if (state.error != null) return Text('Error: ${state.error}');
                if (state.events.isEmpty)
                  return Column(
                    children: [
                      const Text('No upcoming events'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _requestAndLoad,
                        child: const Text('Enable & Load events'),
                      ),
                    ],
                  );
                return Column(
                  children: [
                    for (final ev in state.events)
                      ListTile(
                        title: Text(ev['title'] ?? ''),
                        subtitle: Text(
                          '${DateTime.fromMillisecondsSinceEpoch(ev['start']).toLocal()} - ${DateTime.fromMillisecondsSinceEpoch(ev['end']).toLocal()}',
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<CalendarBloc>().add(LoadCalendar()),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
