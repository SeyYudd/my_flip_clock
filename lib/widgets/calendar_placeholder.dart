import 'package:flutter/material.dart';

class CalendarPlaceholder extends StatelessWidget {
  const CalendarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Icon(Icons.calendar_today, size: 48),
            SizedBox(height: 8),
            Text('Calendar placeholder'),
          ],
        ),
      ),
    );
  }
}
