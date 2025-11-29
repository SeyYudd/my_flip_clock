import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFontFamily = 'settings_font_family';
const _kFontSize = 'settings_font_size';
const _kFontColor = 'settings_font_color';
const _kKeepScreenOn = 'settings_keep_screen_on';
const _kFullscreen = 'settings_fullscreen';
const _kLayoutMode = 'settings_layout_mode';
const _kThemeDark = 'settings_theme_dark';

enum LayoutMode { single, grid2 }

class SettingsState extends Equatable {
  final List<DeviceOrientation> orientations;
  final bool keepScreenOn;
  final bool fullscreen;

  const SettingsState({
    required this.orientations,
    required this.keepScreenOn,
    required this.fullscreen,
  });

  SettingsState copyWith({
    List<DeviceOrientation>? orientations,
    bool? keepScreenOn,
    bool? fullscreen,
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
    );
  }

  @override
  List<Object?> get props => [
    orientations,
    keepScreenOn,
    fullscreen,
  ];
}

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

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
    : super(
        const SettingsState(
          orientations: [],
          keepScreenOn: false,
          fullscreen: false,
        ),
      ) {
    // load persisted settings
    on<LoadSettings>(_onLoadSettings);
    on<UpdateOrientations>(
      (e, emit) => emit(state.copyWith(orientations: e.orientations)),
    );
    on<UpdateKeepScreenOn>(_onUpdateKeepScreenOn);
    on<UpdateFullscreen>(_onUpdateFullscreen);
    on<UpdateLayoutMode>(_onUpdateLayoutMode);
    on<UpdateFontFamily>(_onUpdateFontFamily);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateFontColor>(_onUpdateFontColor);
    on<UpdateWidgetColor>(_onUpdateWidgetColor);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateBackgroundColor>(
      (e, emit) => emit(state.copyWith(backgroundColorValue: e.colorValue)),
    );

    add(LoadSettings());
  }

  Future<void> _onLoadSettings(
    LoadSettings e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final family = prefs.getString(_kFontFamily) ?? 'Roboto';
    final size = prefs.getDouble(_kFontSize) ?? 36.0;
    final color = prefs.getInt(_kFontColor) ?? 0xFF000000;
    final keepOn = prefs.getBool(_kKeepScreenOn) ?? false;
    final full = prefs.getBool(_kFullscreen) ?? false;
    final layoutIdx = prefs.getInt(_kLayoutMode) ?? 0;
    final layout = layoutIdx == 1 ? LayoutMode.grid2 : LayoutMode.single;
    final dark = prefs.getBool(_kThemeDark) ?? false;
    // load per-widget colors
    final widgetColorsJson = prefs.getString('widget_colors');
    Map<String, int> widgetColors = {};
    if (widgetColorsJson != null) {
      try {
        final decoded = json.decode(widgetColorsJson) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          if (v is int)
            widgetColors[k] = v;
          else if (v is String)
            widgetColors[k] = int.tryParse(v) ?? 0;
        });
      } catch (_) {}
    }
    emit(
      state.copyWith(
        fontFamily: family,
        fontSize: size,
        fontColorValue: color,
        keepScreenOn: keepOn,
        fullscreen: full,
        layoutMode: layout,
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
    await prefs.setBool(_kKeepScreenOn, e.keepOn);
    emit(state.copyWith(keepScreenOn: e.keepOn));
  }

  Future<void> _onUpdateFullscreen(
    UpdateFullscreen e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFullscreen, e.fullscreen);
    emit(state.copyWith(fullscreen: e.fullscreen));
  }

  Future<void> _onUpdateLayoutMode(
    UpdateLayoutMode e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLayoutMode, e.mode == LayoutMode.grid2 ? 1 : 0);
    emit(state.copyWith(layoutMode: e.mode));
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kThemeDark, e.dark);
    emit(state.copyWith(darkMode: e.dark));
  }

  Future<void> _onUpdateFontFamily(
    UpdateFontFamily e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontFamily, e.family);
    emit(state.copyWith(fontFamily: e.family));
  }

  Future<void> _onUpdateFontSize(
    UpdateFontSize e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSize, e.size);
    emit(state.copyWith(fontSize: e.size));
  }

  Future<void> _onUpdateFontColor(
    UpdateFontColor e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFontColor, e.colorValue);
    emit(state.copyWith(fontColorValue: e.colorValue));
  }

  Future<void> _onUpdateWidgetColor(
    UpdateWidgetColor e,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('widget_colors');
    Map<String, dynamic> map = {};
    if (jsonStr != null) {
      try {
        map = json.decode(jsonStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[e.widgetKey] = e.colorValue;
    await prefs.setString('widget_colors', json.encode(map));
    // create typed map
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
}
