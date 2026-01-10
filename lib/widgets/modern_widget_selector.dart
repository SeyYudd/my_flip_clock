import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ModernWidgetSelector extends StatefulWidget {
  final List<String> currentWidgets;
  final Map<String, String> widgetOptions;
  final bool isTop;
  final Function(List<String>) onSave;

  const ModernWidgetSelector({
    super.key,
    required this.currentWidgets,
    required this.widgetOptions,
    required this.isTop,
    required this.onSave,
  });

  @override
  State<ModernWidgetSelector> createState() => _ModernWidgetSelectorState();
}

class _ModernWidgetSelectorState extends State<ModernWidgetSelector> {
  late List<String> selectedWidgets;

  @override
  void initState() {
    super.initState();
    selectedWidgets = List<String>.from(widget.currentWidgets);
  }

  IconData _getWidgetIcon(String key) {
    switch (key) {
      case 'calendar':
        return Icons.calendar_today;
      case 'clock':
        return Icons.access_time;
      case 'connectivity':
        return Icons.wifi;
      case 'countdown':
        return Icons.timer;
      case 'gif':
        return Icons.gif_box;
      case 'now_playing':
        return Icons.music_note;
      case 'notification':
        return Icons.notifications;
      case 'photo':
        return Icons.photo;
      case 'pomodoro':
        return Icons.local_cafe;
      case 'quote':
        return Icons.format_quote;
      case 'stopwatch':
        return Icons.timelapse;
      case 'tools':
        return Icons.build;
      case 'weather':
        return Icons.wb_sunny;
      default:
        return Icons.widgets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        gradient: AppTheme.darkGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  widget.isTop ? 'Top Widget Slot' : 'Bottom Widget Slot',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    selectedWidgets.isEmpty
                        ? 'Select widgets'
                        : selectedWidgets.length == 1
                        ? '1 widget selected'
                        : '${selectedWidgets.length} widgets • Carousel mode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Widget grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.widgetOptions.length,
              itemBuilder: (context, index) {
                final entry = widget.widgetOptions.entries.elementAt(index);
                final isSelected = selectedWidgets.contains(entry.key);
                final orderIndex = selectedWidgets.indexOf(entry.key);

                return _WidgetCard(
                  widgetKey: entry.key,
                  label: entry.value,
                  icon: _getWidgetIcon(entry.key),
                  isSelected: isSelected,
                  orderIndex: orderIndex + 1,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedWidgets.remove(entry.key);
                      } else {
                        selectedWidgets.add(entry.key);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[700]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(selectedWidgets);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  final String widgetKey;
  final String label;
  final IconData icon;
  final bool isSelected;
  final int orderIndex;
  final VoidCallback onTap;

  const _WidgetCard({
    required this.widgetKey,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.orderIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected
            ? AppTheme.neonGlow(
                color: const Color(0xFF6366F1),
                borderRadius: 20,
                blurRadius: 12,
              )
            : AppTheme.modernCard(borderRadius: 20),
        child: Stack(
          children: [
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Order badge
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$orderIndex',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                left: 8,
                child: Icon(
                  Icons.check_circle,
                  color: const Color(0xFF10B981),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
