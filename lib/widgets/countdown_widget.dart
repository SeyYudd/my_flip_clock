import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with TickerProviderStateMixin {
  DateTime? _targetDate;
  String _eventName = 'New Year 2026';
  Timer? _timer;
  late AnimationController _pulseController;

  Duration _remaining = Duration.zero;
  bool _showEditButton = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadSettings();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final targetMs = prefs.getInt('countdown_target');
    final name = prefs.getString('countdown_name') ?? 'New Year 2026';

    setState(() {
      _eventName = name;
      if (targetMs != null) {
        _targetDate = DateTime.fromMillisecondsSinceEpoch(targetMs);
      } else {
        // Default: New Year
        _targetDate = DateTime(DateTime.now().year + 1, 1, 1);
      }
      _updateRemaining();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_targetDate != null) {
      await prefs.setInt(
        'countdown_target',
        _targetDate!.millisecondsSinceEpoch,
      );
    }
    await prefs.setString('countdown_name', _eventName);
  }

  void _updateRemaining() {
    if (_targetDate == null) return;
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        if (_targetDate!.isAfter(now)) {
          _remaining = _targetDate!.difference(now);
        } else {
          _remaining = Duration.zero;
        }
      });
    }
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: _eventName);
    DateTime selectedDate =
        _targetDate ?? DateTime.now().add(const Duration(days: 30));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'Set Countdown',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Time: ${selectedTime.format(ctx)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.access_time,
                    color: Colors.white70,
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedTime = time;
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _eventName = nameController.text;
                  _targetDate = selectedDate;
                  _updateRemaining();
                });
                _saveSettings();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    final isComplete = _remaining == Duration.zero && _targetDate != null;

    return GestureDetector(
      onTap: () => setState(() => _showEditButton = !_showEditButton),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isComplete
                ? [Colors.green.shade800, Colors.teal.shade900]
                : [
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                    Colors.black,
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles/stars effect
            ...List.generate(20, (i) => _buildStar(i)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Event name
                  Text(
                    _eventName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Target date
                  if (_targetDate != null)
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(_targetDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  const SizedBox(height: 24),

                  if (isComplete)
                    _buildCompleteView()
                  else
                    _buildCountdownView(days, hours, minutes, seconds),
                ],
              ),
            ),

            // Edit button
            if (_showEditButton)
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: _showEditDialog,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(int index) {
    final random = (index * 7) % 100;
    final left = (random * 3.7) % 100;
    final top = (random * 2.3) % 100;
    final size = 2.0 + (random % 3);
    final delay = (random % 5) * 0.2;

    return Positioned(
      left: left * MediaQuery.of(context).size.width / 100,
      top: top * MediaQuery.of(context).size.height / 100,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final value = ((_pulseController.value + delay) % 1.0);
          return Opacity(
            opacity: 0.3 + value * 0.7,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: size * 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompleteView() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + _pulseController.value * 0.1,
          child: Column(
            children: [
              const Icon(Icons.celebration, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                '🎉 Event Time! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownView(int days, int hours, int minutes, int seconds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBlock(days.toString().padLeft(2, '0'), 'DAYS'),
        _buildSeparator(),
        _buildTimeBlock(hours.toString().padLeft(2, '0'), 'HRS'),
        _buildSeparator(),
        _buildTimeBlock(minutes.toString().padLeft(2, '0'), 'MIN'),
        _buildSeparator(),
        _buildTimeBlock(seconds.toString().padLeft(2, '0'), 'SEC'),
      ],
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Opacity(
            opacity: 0.5 + _pulseController.value * 0.5,
            child: const Text(
              ':',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
