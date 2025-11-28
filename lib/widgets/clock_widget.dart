import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/clock_bloc.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clock',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => context.read<ClockBloc>().add(ToggleMode()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<ClockBloc, ClockState>(
              builder: (context, state) {
                if (state.mode == ClockMode.digital) {
                  final t =
                      '${state.now.hour.toString().padLeft(2, '0')}:${state.now.minute.toString().padLeft(2, '0')}:${state.now.second.toString().padLeft(2, '0')}';
                  return Text(
                    t,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                return SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(painter: _AnalogPainter(state.now)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalogPainter extends CustomPainter {
  final DateTime now;
  _AnalogPainter(this.now);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    // hour hand
    final hourAngle =
        ((now.hour % 12) + now.minute / 60) * 30 * (math.pi / 180);
    final hourHand = Offset(
      center.dx + radius * 0.5 * -math.sin(hourAngle),
      center.dy + radius * 0.5 * -math.cos(hourAngle),
    );
    canvas.drawLine(center, hourHand, tickPaint..strokeWidth = 4);
    // minute hand
    final minAngle = (now.minute + now.second / 60) * 6 * (math.pi / 180);
    final minHand = Offset(
      center.dx + radius * 0.7 * -math.sin(minAngle),
      center.dy + radius * 0.7 * -math.cos(minAngle),
    );
    canvas.drawLine(center, minHand, tickPaint..strokeWidth = 3);
    // second hand
    final secAngle = now.second * 6 * (math.pi / 180);
    final secHand = Offset(
      center.dx + radius * 0.8 * -math.sin(secAngle),
      center.dy + radius * 0.8 * -math.cos(secAngle),
    );
    canvas.drawLine(
      center,
      secHand,
      tickPaint
        ..color = Colors.red
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
