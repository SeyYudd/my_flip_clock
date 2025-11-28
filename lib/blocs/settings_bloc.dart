import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LayoutMode { single, grid2 }

class SettingsState extends Equatable {
  final List<DeviceOrientation> orientations;
  final bool keepScreenOn;
  final bool fullscreen;
  final LayoutMode layoutMode;

  const SettingsState({
    required this.orientations,
    required this.keepScreenOn,
    required this.fullscreen,
    required this.layoutMode,
  });

  SettingsState copyWith({
    List<DeviceOrientation>? orientations,
    bool? keepScreenOn,
    bool? fullscreen,
    LayoutMode? layoutMode,
  }) {
    return SettingsState(
      orientations: orientations ?? this.orientations,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      fullscreen: fullscreen ?? this.fullscreen,
      layoutMode: layoutMode ?? this.layoutMode,
    );
  }

  @override
  List<Object?> get props => [
    orientations,
    keepScreenOn,
    fullscreen,
    layoutMode,
  ];
}

abstract class SettingsEvent {}

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

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
    : super(
        const SettingsState(
          orientations: [],
          keepScreenOn: false,
          fullscreen: false,
          layoutMode: LayoutMode.single,
        ),
      ) {
    on<UpdateOrientations>(
      (e, emit) => emit(state.copyWith(orientations: e.orientations)),
    );
    on<UpdateKeepScreenOn>(
      (e, emit) => emit(state.copyWith(keepScreenOn: e.keepOn)),
    );
    on<UpdateFullscreen>(
      (e, emit) => emit(state.copyWith(fullscreen: e.fullscreen)),
    );
    on<UpdateLayoutMode>((e, emit) => emit(state.copyWith(layoutMode: e.mode)));
  }
}
