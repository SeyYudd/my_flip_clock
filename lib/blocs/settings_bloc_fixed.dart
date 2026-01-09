import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/orientation_converter.dart';

enum LayoutMode { single, grid2 }

enum BurnInMode {
  off, // Disabled
  shift, // Shift screen content
  overlay, // Moving overlay layer
}

/// Complete Settings State with ALL properties
/// No more schizophrenic state with phantom properties! 👻
class SettingsState extends Equatable {
  // Display settings
  final List<DeviceOrientation> orientations;
  final bool keepScreenOn;
  final bool fullscreen;

  // Burn-in protection
  final bool burnInProtection;
  final BurnInMode burnInMode;

  // Layout settings
  final LayoutMode layoutMode;

  // Font settings
  final String fontFamily;
  final double fontSize;
  final int fontColorValue;

  // Theme settings
  final bool darkMode;
  final int backgroundColorValue;

  // Widget colors
  final Map<String, int> widgetColors;

  const SettingsState({
    required this.orientations,
    required this.keepScreenOn,
    required this.fullscreen,
    required this.burnInProtection,
    required this.burnInMode,
    required this.layoutMode,
    required this.fontFamily,
    required this.fontSize,
    required this.fontColorValue,
    required this.darkMode,
    required this.backgroundColorValue,
    required this.widgetColors,
  });

  /// Factory constructor for default settings
  factory SettingsState.initial() {
    return const SettingsState(
      orientations: [],
      keepScreenOn: false,
      fullscreen: false,
      burnInProtection: false,
      burnInMode: BurnInMode.off,
      layoutMode: LayoutMode.single,
      fontFamily: 'Roboto',
      fontSize: 36.0,
      fontColorValue: 0xFF000000,
      darkMode: false,
      backgroundColorValue: 0xFF000000,
      widgetColors: {},
    );
  }

  /// Now copyWith makes sense! All properties are real!
  SettingsState copyWith({
    List<DeviceOrientation>? orientations,
    bool? keepScreenOn,
    bool? fullscreen,
    bool? burnInProtection,
    BurnInMode? burnInMode,
    LayoutMode? layoutMode,
    String? fontFamily,
    double? fontSize,
    int? fontColorValue,
    int? backgroundColorValue,
    bool? darkMode,
    Map<String, int>? widgetColors,
  }) {
    return SettingsState(
      orientations: orientations ?? this.orientations,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      fullscreen: fullscreen ?? this.fullscreen,
      burnInProtection: burnInProtection ?? this.burnInProtection,
      burnInMode: burnInMode ?? this.burnInMode,
      layoutMode: layoutMode ?? this.layoutMode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontColorValue: fontColorValue ?? this.fontColorValue,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      darkMode: darkMode ?? this.darkMode,
      widgetColors: widgetColors ?? this.widgetColors,
    );
  }

  /// Equatable now tracks ALL properties correctly! 🎯
  @override
  List<Object?> get props => [
    orientations,
    keepScreenOn,
    fullscreen,
    burnInProtection,
    burnInMode,
    layoutMode,
    fontFamily,
    fontSize,
    fontColorValue,
    backgroundColorValue,
    darkMode,
    widgetColors,
  ];
}

// Events remain the same
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateFontFamily extends SettingsEvent {
  final String family;
  UpdateFontFamily(this.family);
}

class UpdateFontSize extends SettingsEvent {
  final double size;
  UpdateFontSize(this.size);
}

class UpdateFontColor extends SettingsEvent {
  final int colorValue;
  UpdateFontColor(this.colorValue);
}

class UpdateWidgetColor extends SettingsEvent {
  final String widgetKey;
  final int colorValue;
  UpdateWidgetColor(this.widgetKey, this.colorValue);
}

class UpdateOrientations extends SettingsEvent {
  final List<DeviceOrientation> orientations;
  UpdateOrientations(this.orientations);
}

class UpdateKeepScreenOn extends SettingsEvent {
  final bool keepOn;
  UpdateKeepScreenOn(this.keepOn);
}

class UpdateFullscreen extends SettingsEvent {
  final bool fullscreen;
  UpdateFullscreen(this.fullscreen);
}

class UpdateLayoutMode extends SettingsEvent {
  final LayoutMode mode;
  UpdateLayoutMode(this.mode);
}

class UpdateThemeMode extends SettingsEvent {
  final bool dark;
  UpdateThemeMode(this.dark);
}

class UpdateBackgroundColor extends SettingsEvent {
  final int colorValue;
  UpdateBackgroundColor(this.colorValue);
}

class UpdateBurnInProtection extends SettingsEvent {
  final bool enabled;
  UpdateBurnInProtection(this.enabled);
}

class UpdateBurnInMode extends SettingsEvent {
  final BurnInMode mode;
  UpdateBurnInMode(this.mode);
}

/// Fixed SettingsBloc with proper state management
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateOrientations>(_onUpdateOrientations);
    on<UpdateKeepScreenOn>(_onUpdateKeepScreenOn);
    on<UpdateFullscreen>(_onUpdateFullscreen);
    on<UpdateLayoutMode>(_onUpdateLayoutMode);
    on<UpdateFontFamily>(_onUpdateFontFamily);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateFontColor>(_onUpdateFontColor);
    on<UpdateWidgetColor>(_onUpdateWidgetColor);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateBurnInProtection>(_onUpdateBurnInProtection);
    on<UpdateBurnInMode>(_onUpdateBurnInMode);
    on<UpdateBackgroundColor>(_onUpdateBackgroundColor);

    add(LoadSettings());
  }

  Future<void> _onLoadSettings(
    LoadSettings e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Load all settings - NO PHANTOM PROPERTIES!
    final family = prefs.getString(StorageKeys.fontFamily) ?? 'Roboto';
    final size = prefs.getDouble(StorageKeys.fontSize) ?? 36.0;
    final color = prefs.getInt(StorageKeys.fontColor) ?? 0xFF000000;
    final keepOn = prefs.getBool(StorageKeys.keepScreenOn) ?? false;
    final full = prefs.getBool(StorageKeys.fullscreen) ?? false;
    final burnIn = prefs.getBool(StorageKeys.burnInProtection) ?? false;
    final burnInModeIdx = prefs.getInt(StorageKeys.burnInMode) ?? 0;
    final burnInMode =
        BurnInMode.values[burnInModeIdx.clamp(0, BurnInMode.values.length - 1)];
    final layoutIdx = prefs.getInt(StorageKeys.layoutMode) ?? 0;
    final layout = layoutIdx == 1 ? LayoutMode.grid2 : LayoutMode.single;
    final dark = prefs.getBool(StorageKeys.themeDark) ?? false;
    final bgColor = prefs.getInt('background_color') ?? 0xFF000000;

    // Load orientations using converter - NO DUPLICATION!
    final orientationList = prefs.getStringList(StorageKeys.orientations);
    final orientations = orientationList != null
        ? OrientationConverter.listFromString(orientationList)
        : <DeviceOrientation>[];

    // Load widget colors
    final widgetColorsJson = prefs.getString(StorageKeys.widgetColors);
    Map<String, int> widgetColors = {};
    if (widgetColorsJson != null) {
      try {
        final decoded = json.decode(widgetColorsJson) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          if (v is int) {
            widgetColors[k] = v;
          } else if (v is String) {
            widgetColors[k] = int.tryParse(v) ?? 0;
          }
        });
      } catch (_) {}
    }

    emit(
      SettingsState(
        orientations: orientations,
        keepScreenOn: keepOn,
        fullscreen: full,
        burnInProtection: burnIn,
        burnInMode: burnInMode,
        layoutMode: layout,
        fontFamily: family,
        fontSize: size,
        fontColorValue: color,
        backgroundColorValue: bgColor,
        darkMode: dark,
        widgetColors: widgetColors,
      ),
    );
  }

  Future<void> _onUpdateKeepScreenOn(
    UpdateKeepScreenOn e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.keepScreenOn, e.keepOn);
    emit(state.copyWith(keepScreenOn: e.keepOn));
  }

  Future<void> _onUpdateFullscreen(
    UpdateFullscreen e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.fullscreen, e.fullscreen);
    emit(state.copyWith(fullscreen: e.fullscreen));
  }

  Future<void> _onUpdateLayoutMode(
    UpdateLayoutMode e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      StorageKeys.layoutMode,
      e.mode == LayoutMode.grid2 ? 1 : 0,
    );
    emit(state.copyWith(layoutMode: e.mode));
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.themeDark, e.dark);
    emit(state.copyWith(darkMode: e.dark));
  }

  Future<void> _onUpdateFontFamily(
    UpdateFontFamily e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.fontFamily, e.family);
    emit(state.copyWith(fontFamily: e.family));
  }

  Future<void> _onUpdateFontSize(
    UpdateFontSize e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(StorageKeys.fontSize, e.size);
    emit(state.copyWith(fontSize: e.size));
  }

  Future<void> _onUpdateFontColor(
    UpdateFontColor e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.fontColor, e.colorValue);
    emit(state.copyWith(fontColorValue: e.colorValue));
  }

  Future<void> _onUpdateBackgroundColor(
    UpdateBackgroundColor e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('background_color', e.colorValue);
    emit(state.copyWith(backgroundColorValue: e.colorValue));
  }

  Future<void> _onUpdateWidgetColor(
    UpdateWidgetColor e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(StorageKeys.widgetColors);
    Map<String, dynamic> map = {};
    if (jsonStr != null) {
      try {
        map = json.decode(jsonStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[e.widgetKey] = e.colorValue;
    await prefs.setString(StorageKeys.widgetColors, json.encode(map));

    final typed = Map<String, int>.fromEntries(
      map.entries.map(
        (kv) => MapEntry(
          kv.key,
          (kv.value is int)
              ? kv.value as int
              : int.tryParse(kv.value.toString()) ?? 0,
        ),
      ),
    );
    emit(state.copyWith(widgetColors: typed));
  }

  Future<void> _onUpdateBurnInProtection(
    UpdateBurnInProtection e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.burnInProtection, e.enabled);
    emit(state.copyWith(burnInProtection: e.enabled));
  }

  Future<void> _onUpdateBurnInMode(
    UpdateBurnInMode e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.burnInMode, e.mode.index);
    final enabled = e.mode != BurnInMode.off;
    await prefs.setBool(StorageKeys.burnInProtection, enabled);
    emit(state.copyWith(burnInMode: e.mode, burnInProtection: enabled));
  }

  Future<void> _onUpdateOrientations(
    UpdateOrientations e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // Use converter - NO DUPLICATION!
    final orientationStrings = OrientationConverter.listToString(
      e.orientations,
    );
    await prefs.setStringList(StorageKeys.orientations, orientationStrings);
    emit(state.copyWith(orientations: e.orientations));
  }
}
