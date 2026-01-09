import 'package:flutter/material.dart';
import '../models/clock_template.dart';

/// Predefined modern templates
class TemplatePresets {
  TemplatePresets._();

  static final List<ClockTemplate> all = [
    minimalist,
    cyberpunk,
    elegance,
    vibrant,
    retro,
    professional,
    zen,
  ];

  /// 1. Minimalist Modern
  static final ClockTemplate minimalist = ClockTemplate(
    id: 'minimalist',
    name: 'Minimalist',
    description: 'Clean, simple, and elegant design with focus on time',
    icon: Icons.circle_outlined,
    style: const TemplateStyle(
      primaryColor: Colors.white,
      accentColor: Color(0xFF6366F1), // Indigo
      backgroundColor: Color(0xFF0F0F0F),
      textColor: Colors.white,
      themeMode: ThemeMode.dark,
    ),
    topWidgets: const [WidgetConfig(widgetKey: 'clock')],
    bottomWidgets: const [WidgetConfig(widgetKey: 'quote')],
    layout: const LayoutConfig(
      topRatio: 0.65,
      innerPadding: 12.0,
      outerPadding: 20.0,
      borderRadius: 24.0,
    ),
  );

  /// 2. Cyberpunk Edge
  static final ClockTemplate cyberpunk = ClockTemplate(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    description: 'Edgy neon aesthetic with bold contrasts',
    icon: Icons.flash_on,
    style: const TemplateStyle(
      primaryColor: Color(0xFF00FFFF), // Cyan
      accentColor: Color(0xFFFF00FF), // Magenta
      backgroundColor: Color(0xFF000510),
      textColor: Color(0xFF00FFFF),
      themeMode: ThemeMode.dark,
    ),
    topWidgets: const [
      WidgetConfig(widgetKey: 'clock'),
      WidgetConfig(widgetKey: 'gif'),
    ],
    bottomWidgets: const [
      WidgetConfig(widgetKey: 'now_playing'),
      WidgetConfig(widgetKey: 'battery'),
    ],
    layout: const LayoutConfig(
      topRatio: 0.5,
      innerPadding: 8.0,
      outerPadding: 16.0,
      borderRadius: 16.0,
    ),
  );

  /// 3. Elegant Sophistication
  static final ClockTemplate elegance = ClockTemplate(
    id: 'elegance',
    name: 'Elegance',
    description: 'Sophisticated and refined aesthetic',
    icon: Icons.diamond_outlined,
    style: const TemplateStyle(
      primaryColor: Color(0xFFD4AF37), // Gold
      accentColor: Color(0xFF8B7355), // Bronze
      backgroundColor: Color(0xFF1A1410),
      textColor: Color(0xFFF5F5DC), // Beige
      themeMode: ThemeMode.dark,
    ),
    topWidgets: const [WidgetConfig(widgetKey: 'clock')],
    bottomWidgets: const [
      WidgetConfig(widgetKey: 'quote'),
      WidgetConfig(widgetKey: 'photo'),
    ],
    layout: const LayoutConfig(
      topRatio: 0.6,
      innerPadding: 16.0,
      outerPadding: 24.0,
      borderRadius: 20.0,
    ),
  );

  /// 4. Vibrant Energy
  static final ClockTemplate vibrant = ClockTemplate(
    id: 'vibrant',
    name: 'Vibrant',
    description: 'Colorful and energetic display',
    icon: Icons.color_lens,
    style: const TemplateStyle(
      primaryColor: Color(0xFFFF6B35), // Orange
      accentColor: Color(0xFF00D9FF), // Bright Blue
      backgroundColor: Color(0xFF120008),
      textColor: Colors.white,
      themeMode: ThemeMode.dark,
    ),
    topWidgets: const [
      WidgetConfig(widgetKey: 'clock'),
      WidgetConfig(widgetKey: 'ambient'),
    ],
    bottomWidgets: const [
      WidgetConfig(widgetKey: 'tools'),
      WidgetConfig(widgetKey: 'now_playing'),
    ],
    layout: const LayoutConfig(
      topRatio: 0.5,
      innerPadding: 10.0,
      outerPadding: 18.0,
      borderRadius: 18.0,
    ),
  );

  /// 5. Retro Classic
  static final ClockTemplate retro = ClockTemplate(
    id: 'retro',
    name: 'Retro',
    description: 'Nostalgic throwback to classic designs',
    icon: Icons.radio,
    style: const TemplateStyle(
      primaryColor: Color(0xFFFFB300), // Amber
      accentColor: Color(0xFFFF6F00), // Orange
      backgroundColor: Color(0xFF0A0500),
      textColor: Color(0xFFFFB300),
      themeMode: ThemeMode.dark,
    ),
    topWidgets: const [WidgetConfig(widgetKey: 'clock')],
    bottomWidgets: const [
      WidgetConfig(widgetKey: 'now_playing'),
      WidgetConfig(widgetKey: 'quote'),
    ],
    layout: const LayoutConfig(
      topRatio: 0.55,
      innerPadding: 12.0,
      outerPadding: 16.0,
      borderRadius: 12.0,
    ),
  );

  /// 6. Professional Focus
  static final ClockTemplate professional = ClockTemplate(
    id: 'professional',
    name: 'Professional',
    description: 'Business-ready with productivity tools',
    icon: Icons.business_center,
    style: const TemplateStyle(
      primaryColor: Color(0xFF2563EB), // Blue
      accentColor: Color(0xFF10B981), // Green
      backgroundColor: Color(0xFF0A0A0A),
      textColor: Colors.white,
      themeMode: ThemeMode.dark,
    ),
    topWidgets: const [
      WidgetConfig(widgetKey: 'clock'),
      WidgetConfig(widgetKey: 'countdown'),
    ],
    bottomWidgets: const [
      WidgetConfig(widgetKey: 'tools'),
      WidgetConfig(widgetKey: 'notification'),
    ],
    layout: const LayoutConfig(
      topRatio: 0.5,
      innerPadding: 10.0,
      outerPadding: 16.0,
      borderRadius: 16.0,
    ),
  );

  /// 7. Zen Tranquility
  static final ClockTemplate zen = ClockTemplate(
    id: 'zen',
    name: 'Zen',
    description: 'Peaceful and calming minimal design',
    icon: Icons.spa_outlined,
    style: const TemplateStyle(
      primaryColor: Color(0xFF94A3B8), // Slate
      accentColor: Color(0xFF64748B), // Slate 500
      backgroundColor: Color(0xFF0F172A), // Slate 900
      textColor: Color(0xFFE2E8F0), // Slate 200
      themeMode: ThemeMode.dark,
    ),
    topWidgets: const [WidgetConfig(widgetKey: 'clock')],
    bottomWidgets: const [
      WidgetConfig(widgetKey: 'ambient'),
      WidgetConfig(widgetKey: 'quote'),
    ],
    layout: const LayoutConfig(
      topRatio: 0.7,
      innerPadding: 20.0,
      outerPadding: 28.0,
      borderRadius: 28.0,
    ),
  );
}
