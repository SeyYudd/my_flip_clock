import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryWidget extends StatefulWidget {
  const BatteryWidget({super.key});

  @override
  State<BatteryWidget> createState() => _BatteryWidgetState();
}

class _BatteryWidgetState extends State<BatteryWidget>
    with TickerProviderStateMixin {
  static const _channel = MethodChannel('battery_channel');

  int _batteryLevel = 100;
  bool _isCharging = false;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Cute face expressions
  String _expression = 'happy';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _getBatteryLevel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _getBatteryLevel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _getBatteryLevel() async {
    try {
      final result = await _channel.invokeMethod('getBatteryInfo');
      if (mounted) {
        setState(() {
          _batteryLevel = result['level'] ?? 100;
          _isCharging = result['isCharging'] ?? false;
          _updateExpression();
        });
        _bounceController.forward(from: 0);
      }
    } catch (e) {
      // Fallback - use random for demo
      if (mounted) {
        setState(() {
          _batteryLevel = 50 + Random().nextInt(50);
          _updateExpression();
        });
      }
    }
  }

  void _updateExpression() {
    if (_isCharging) {
      _expression = 'charging';
    } else if (_batteryLevel <= 10) {
      _expression = 'dying';
    } else if (_batteryLevel <= 20) {
      _expression = 'worried';
    } else if (_batteryLevel <= 40) {
      _expression = 'tired';
    } else if (_batteryLevel <= 60) {
      _expression = 'neutral';
    } else if (_batteryLevel <= 80) {
      _expression = 'happy';
    } else {
      _expression = 'excited';
    }
  }

  Color _getBatteryColor() {
    if (_isCharging) return Colors.green.shade400;
    if (_batteryLevel <= 10) return Colors.red.shade600;
    if (_batteryLevel <= 20) return Colors.orange.shade600;
    if (_batteryLevel <= 40) return Colors.amber.shade600;
    return Colors.green.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade900,
            Colors.purple.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cute Battery Character
              _buildBatteryCharacter(),
              const SizedBox(height: 16),
              // Percentage
              Text(
                '$_batteryLevel%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getBatteryColor(),
                  shadows: [
                    Shadow(
                      color: _getBatteryColor().withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Status text
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              if (_isCharging) ...[
                const SizedBox(height: 8),
                _buildChargingIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryCharacter() {
    final color = _getBatteryColor();
    final fillHeight = 80 * (_batteryLevel / 100);

    return SizedBox(
      width: 100,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Battery body
          Positioned(
            top: 20,
            child: Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 3),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Fill level
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final pulse = _isCharging
                          ? 1.0 + _pulseController.value * 0.1
                          : 1.0;
                      return Transform.scale(
                        scale: pulse,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          height: fillHeight,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Battery cap (top)
          Positioned(
            top: 8,
            child: Container(
              width: 30,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
          ),
          // Face
          Positioned(top: 50, child: _buildFace()),
          // Arms
          if (_expression == 'excited' || _expression == 'charging') ...[
            // Left arm waving
            Positioned(
              left: 0,
              top: 60,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -0.3 + _pulseController.value * 0.3,
                    child: Container(
                      width: 15,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Right arm waving
            Positioned(
              right: 0,
              top: 60,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: 0.3 - _pulseController.value * 0.3,
                    child: Container(
                      width: 15,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          // Lightning bolt when charging
          if (_isCharging)
            Positioned(
              top: 75,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.5 + _pulseController.value * 0.5,
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.yellow,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFace() {
    switch (_expression) {
      case 'dying':
        return _buildDyingFace();
      case 'worried':
        return _buildWorriedFace();
      case 'tired':
        return _buildTiredFace();
      case 'neutral':
        return _buildNeutralFace();
      case 'happy':
        return _buildHappyFace();
      case 'excited':
      case 'charging':
        return _buildExcitedFace();
      default:
        return _buildHappyFace();
    }
  }

  Widget _buildDyingFace() {
    return Column(
      children: [
        // X_X eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'X',
              style: TextStyle(fontSize: 16, color: Colors.red.shade300),
            ),
            const SizedBox(width: 12),
            Text(
              'X',
              style: TextStyle(fontSize: 16, color: Colors.red.shade300),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Wavy mouth
        Text('~', style: TextStyle(fontSize: 20, color: Colors.red.shade300)),
      ],
    );
  }

  Widget _buildWorriedFace() {
    return Column(
      children: [
        // O_O eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Worried mouth
        Container(
          width: 20,
          height: 8,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.orange.shade300, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTiredFace() {
    return Column(
      children: [
        // -_- eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 3, color: Colors.amber.shade300),
            const SizedBox(width: 12),
            Container(width: 12, height: 3, color: Colors.amber.shade300),
          ],
        ),
        const SizedBox(height: 8),
        // Neutral mouth
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.amber.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildNeutralFace() {
    return Column(
      children: [
        // o_o eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Neutral mouth
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildHappyFace() {
    return Column(
      children: [
        // ^_^ eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: const Size(12, 8), painter: _SmileEyePainter()),
            const SizedBox(width: 14),
            CustomPaint(size: const Size(12, 8), painter: _SmileEyePainter()),
          ],
        ),
        const SizedBox(height: 6),
        // Smile
        CustomPaint(
          size: const Size(24, 12),
          painter: _SmilePainter(Colors.white),
        ),
      ],
    );
  }

  Widget _buildExcitedFace() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Column(
          children: [
            // Star eyes
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.8 + _pulseController.value * 0.2,
                  child: const Icon(Icons.star, color: Colors.yellow, size: 16),
                ),
                const SizedBox(width: 10),
                Transform.scale(
                  scale: 0.8 + _pulseController.value * 0.2,
                  child: const Icon(Icons.star, color: Colors.yellow, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Big smile
            CustomPaint(
              size: const Size(28, 14),
              painter: _SmilePainter(Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChargingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Icon(
              Icons.bolt,
              color: Colors.yellow.withOpacity(
                0.5 + _pulseController.value * 0.5,
              ),
              size: 20,
            );
          },
        ),
        const SizedBox(width: 4),
        Text(
          'Charging...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.green.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    if (_isCharging) return 'Feeling energized!';
    if (_batteryLevel <= 10) return 'Help me... I\'m dying!';
    if (_batteryLevel <= 20) return 'Need charge soon!';
    if (_batteryLevel <= 40) return 'Getting tired...';
    if (_batteryLevel <= 60) return 'Doing okay~';
    if (_batteryLevel <= 80) return 'Feeling good!';
    return 'Full power! 💪';
  }
}

class _SmileEyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SmilePainter extends CustomPainter {
  final Color color;
  _SmilePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
