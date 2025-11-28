import 'package:flutter/material.dart';

class MediaPlaceholder extends StatelessWidget {
  const MediaPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Now Playing', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Icon(Icons.music_note, size: 48),
            SizedBox(height: 8),
            Text('Media integration placeholder'),
          ],
        ),
      ),
    );
  }
}
