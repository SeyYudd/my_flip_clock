import 'package:flutter/material.dart';

/// Defines a complete template/preset for the clock display
class ClockTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final TemplateStyle style;
  final List<WidgetConfig> topWidgets;
  final List<WidgetConfig> bottomWidgets;
  final LayoutConfig layout;

  const ClockTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.style,
    required this.topWidgets,
    required this.bottomWidgets,
    required this.layout,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconCodePoint': icon.codePoint,
    'style': style.toJson(),
    'topWidgets': topWidgets.map((e) => e.toJson()).toList(),
    'bottomWidgets': bottomWidgets.map((e) => e.toJson()).toList(),
    'layout': layout.toJson(),
  };

  factory ClockTemplate.fromJson(Map<String, dynamic> json) => ClockTemplate(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
    style: TemplateStyle.fromJson(json['style']),
    topWidgets: (json['topWidgets'] as List)
        .map((e) => WidgetConfig.fromJson(e))
        .toList(),
    bottomWidgets: (json['bottomWidgets'] as List)
        .map((e) => WidgetConfig.fromJson(e))
        .toList(),
    layout: LayoutConfig.fromJson(json['layout']),
  );
}

/// Widget configuration within a template
class WidgetConfig {
  final String widgetKey;
  final Map<String, dynamic>? customSettings;

  const WidgetConfig({required this.widgetKey, this.customSettings});

  Map<String, dynamic> toJson() => {
    'widgetKey': widgetKey,
    'customSettings': customSettings,
  };

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => WidgetConfig(
    widgetKey: json['widgetKey'],
    customSettings: json['customSettings'],
  );
}

/// Layout configuration
class LayoutConfig {
  final double topRatio;
  final double innerPadding;
  final double outerPadding;
  final double borderRadius;

  const LayoutConfig({
    required this.topRatio,
    required this.innerPadding,
    required this.outerPadding,
    required this.borderRadius,
  });

  Map<String, dynamic> toJson() => {
    'topRatio': topRatio,
    'innerPadding': innerPadding,
    'outerPadding': outerPadding,
    'borderRadius': borderRadius,
  };

  factory LayoutConfig.fromJson(Map<String, dynamic> json) => LayoutConfig(
    topRatio: json['topRatio'],
    innerPadding: json['innerPadding'],
    outerPadding: json['outerPadding'],
    borderRadius: json['borderRadius'],
  );
}

/// Visual style configuration
class TemplateStyle {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColor;
  final ThemeMode themeMode;

  const TemplateStyle({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.themeMode,
  });

  Map<String, dynamic> toJson() => {
    'primaryColor': primaryColor.value,
    'accentColor': accentColor.value,
    'backgroundColor': backgroundColor.value,
    'textColor': textColor.value,
    'themeMode': themeMode.name,
  };

  factory TemplateStyle.fromJson(Map<String, dynamic> json) => TemplateStyle(
    primaryColor: Color(json['primaryColor']),
    accentColor: Color(json['accentColor']),
    backgroundColor: Color(json['backgroundColor']),
    textColor: Color(json['textColor']),
    themeMode: ThemeMode.values.firstWhere(
      (e) => e.name == json['themeMode'],
      orElse: () => ThemeMode.dark,
    ),
  );
}
