import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AmbientType { rain, waves, fireplace, stars, bubbles, aurora }

class AmbientWidget extends StatefulWidget {
  const AmbientWidget({super.key});

  @override
  State<AmbientWidget> createState() => _AmbientWidgetState();
}

class _AmbientWidgetState extends State<AmbientWidget>
    with TickerProviderStateMixin {
  AmbientType _currentType = AmbientType.rain;
  bool _showControls = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadSettings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('ambient_type') ?? 0;
    setState(() {
      _currentType =
          AmbientType.values[index.clamp(0, AmbientType.values.length - 1)];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ambient_type', _currentType.index);
  }

  void _nextType() {
    setState(() {
      final nextIndex = (_currentType.index + 1) % AmbientType.values.length;
      _currentType = AmbientType.values[nextIndex];
    });
    _saveSettings();
  }

  void _prevType() {
    setState(() {
      final prevIndex =
          (_currentType.index - 1 + AmbientType.values.length) %
          AmbientType.values.length;
      _currentType = AmbientType.values[prevIndex];
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            _prevType();
          } else {
            _nextType();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient animation
          _buildAmbient(),

          // Controls
          if (_showControls)
            Container(
              color: Colors.black26,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getTypeName(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _prevType,
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                      IconButton(
                        onPressed: _nextType,
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getTypeName() {
    switch (_currentType) {
      case AmbientType.rain:
        return '🌧️ Rain';
      case AmbientType.waves:
        return '🌊 Waves';
      case AmbientType.fireplace:
        return '🔥 Fireplace';
      case AmbientType.stars:
        return '✨ Starfield';
      case AmbientType.bubbles:
        return '🫧 Bubbles';
      case AmbientType.aurora:
        return '🌌 Aurora';
    }
  }

  Widget _buildAmbient() {
    switch (_currentType) {
      case AmbientType.rain:
        return _RainAnimation(controller: _controller);
      case AmbientType.waves:
        return _WavesAnimation(controller: _controller);
      case AmbientType.fireplace:
        return _FireplaceAnimation(controller: _controller);
      case AmbientType.stars:
        return _StarfieldAnimation(controller: _controller);
      case AmbientType.bubbles:
        return _BubblesAnimation(controller: _controller);
      case AmbientType.aurora:
        return _AuroraAnimation(controller: _controller);
    }
  }
}

// ============ RAIN ANIMATION ============
class _RainAnimation extends StatelessWidget {
  final AnimationController controller;
  const _RainAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade900,
            Colors.blueGrey.shade800,
            Colors.grey.shade900,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RainPainter(controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  final double progress;
  final Random random = Random(42);

  _RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final speed = 0.5 + random.nextDouble() * 0.5;
      final y =
          ((progress * speed * 2 + i / 150) % 1.0) * size.height * 1.2 - 20;
      final length = 10 + random.nextDouble() * 15;

      canvas.drawLine(Offset(x, y), Offset(x - 2, y + length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============ WAVES ANIMATION ============
class _WavesAnimation extends StatelessWidget {
  final AnimationController controller;
  const _WavesAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade300,
            Colors.orange.shade400,
            Colors.blue.shade600,
            Colors.blue.shade900,
          ],
          stops: const [0, 0.3, 0.5, 1],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavesPainter(controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final double progress;
  _WavesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int layer = 0; layer < 4; layer++) {
      final paint = Paint()
        ..color = Colors.blue.shade800.withOpacity(0.3 + layer * 0.1)
        ..style = PaintingStyle.fill;

      final path = Path();
      final waveHeight = 15.0 + layer * 5;
      final baseY = size.height * 0.5 + layer * 30;
      final phase = progress * 2 * pi + layer * 0.5;

      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 5) {
        final y = baseY + sin((x / 50) + phase) * waveHeight;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============ FIREPLACE ANIMATION ============
class _FireplaceAnimation extends StatelessWidget {
  final AnimationController controller;
  const _FireplaceAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.brown.shade900, Colors.black],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _FirePainter(controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _FirePainter extends CustomPainter {
  final double progress;
  final Random random = Random(42);

  _FirePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.85;

    // Draw flames
    for (int i = 0; i < 30; i++) {
      final xOffset = (random.nextDouble() - 0.5) * 150;
      final height = 50 + random.nextDouble() * 150;
      final phase = progress * 2 * pi + i * 0.3;
      final flicker = sin(phase) * 10;

      final gradient = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 1.5,
        colors: [
          Colors.yellow.withOpacity(0.8),
          Colors.orange.withOpacity(0.6),
          Colors.red.withOpacity(0.3),
          Colors.transparent,
        ],
      );

      final rect = Rect.fromCenter(
        center: Offset(centerX + xOffset + flicker, baseY - height / 2),
        width: 40 + random.nextDouble() * 30,
        height: height,
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawOval(rect, paint);
    }

    // Glow at base
    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(Offset(centerX, baseY), 100, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============ STARFIELD ANIMATION ============
class _StarfieldAnimation extends StatelessWidget {
  final AnimationController controller;
  const _StarfieldAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [Colors.indigo.shade900, Colors.black],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _StarfieldPainter(controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final double progress;
  final Random random = Random(42);

  _StarfieldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 200; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 0.2 + random.nextDouble() * 0.8;
      final maxDist =
          sqrt(size.width * size.width + size.height * size.height) / 2;
      final dist = ((progress * speed + i / 200) % 1.0) * maxDist;

      final x = center.dx + cos(angle) * dist;
      final y = center.dy + sin(angle) * dist;

      final starSize = 1.0 + (dist / maxDist) * 3;
      final opacity = (dist / maxDist).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============ BUBBLES ANIMATION ============
class _BubblesAnimation extends StatelessWidget {
  final AnimationController controller;
  const _BubblesAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.cyan.shade700,
            Colors.blue.shade900,
            Colors.indigo.shade900,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BubblesPainter(controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  final double progress;
  final Random random = Random(42);

  _BubblesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final startY = random.nextDouble();
      final y =
          size.height - ((progress * speed + startY) % 1.0) * size.height * 1.2;
      final radius = 5 + random.nextDouble() * 25;
      final wobble = sin(progress * 2 * pi * 2 + i) * 10;

      final paint = Paint()
        ..color = Colors.white.withOpacity(0.1 + random.nextDouble() * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(x + wobble, y), radius, paint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(x + wobble - radius * 0.3, y - radius * 0.3),
        radius * 0.2,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============ AURORA ANIMATION ============
class _AuroraAnimation extends StatelessWidget {
  final AnimationController controller;
  const _AuroraAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0a0a20), Color(0xFF1a1a40), Color(0xFF0a0a20)],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _AuroraPainter(controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  _AuroraPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int layer = 0; layer < 5; layer++) {
      final phase = progress * 2 * pi + layer * 0.5;
      final baseY = size.height * 0.3 + layer * 40;

      final path = Path();
      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += 10) {
        final y =
            baseY +
            sin((x / 100) + phase) * 30 +
            sin((x / 50) + phase * 2) * 15;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();

      final colors = [
        [Colors.green, Colors.cyan],
        [Colors.cyan, Colors.blue],
        [Colors.blue, Colors.purple],
        [Colors.purple, Colors.pink],
        [Colors.green, Colors.teal],
      ];

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[layer][0].withOpacity(0.2),
          colors[layer][1].withOpacity(0.05),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawPath(path, paint);
    }

    // Stars
    final starPaint = Paint()..color = Colors.white;
    final random = Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.5;
      final twinkle = 0.3 + sin(progress * 2 * pi * 3 + i) * 0.7;
      starPaint.color = Colors.white.withOpacity(twinkle.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), 1 + random.nextDouble(), starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
