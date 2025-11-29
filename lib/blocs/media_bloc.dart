import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MediaState extends Equatable {
  final String title;
  final String artist;
  final String album;
  final String packageName;
  final String? artBase64;
  final int duration; // in milliseconds
  final int position; // in milliseconds
  final bool isPlaying;

  const MediaState({
    this.title = '',
    this.artist = '',
    this.album = '',
    this.packageName = '',
    this.artBase64,
    this.duration = 0,
    this.position = 0,
    this.isPlaying = false,
  });

  MediaState copyWith({
    String? title,
    String? artist,
    String? album,
    String? packageName,
    String? artBase64,
    int? duration,
    int? position,
    bool? isPlaying,
  }) => MediaState(
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    packageName: packageName ?? this.packageName,
    artBase64: artBase64 ?? this.artBase64,
    duration: duration ?? this.duration,
    position: position ?? this.position,
    isPlaying: isPlaying ?? this.isPlaying,
  );

  @override
  List<Object?> get props => [
    title,
    artist,
    album,
    packageName,
    artBase64,
    duration,
    position,
    isPlaying,
  ];

  // Check if same media track (ignoring position)
  bool isSameTrack(MediaState other) =>
      title == other.title &&
      artist == other.artist &&
      packageName == other.packageName;
}

abstract class MediaEvent {}

class _NativeMediaUpdate extends MediaEvent {
  final Map data;
  _NativeMediaUpdate(this.data);
}

class ClearMedia extends MediaEvent {}

class UpdatePosition extends MediaEvent {
  final int position;
  UpdatePosition(this.position);
}

class SeekTo extends MediaEvent {
  final int position;
  SeekTo(this.position);
}

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  static const _channel = EventChannel('media_notifications');
  StreamSubscription? _sub;
  Timer? _positionTimer;
  String? _lastArtBase64; // Cache art to avoid unnecessary rebuilds

  MediaBloc() : super(const MediaState()) {
    on<_NativeMediaUpdate>((e, emit) {
      final map = e.data;

      // Check if cleared
      if (map['cleared'] == true) {
        emit(const MediaState());
        _stopPositionTimer();
        _lastArtBase64 = null;
        return;
      }

      final title = map['title']?.toString() ?? '';
      final artist = map['artist']?.toString() ?? map['text']?.toString() ?? '';
      final album = map['album']?.toString() ?? '';
      final pkg = map['package']?.toString() ?? '';
      final art = map['art']?.toString();
      final duration = (map['duration'] as num?)?.toInt() ?? 0;
      final position = (map['position'] as num?)?.toInt() ?? 0;
      final isPlaying = map['isPlaying'] == true;

      // Only update art if it changed (to prevent unnecessary rebuilds)
      final newArt = (art != null && art != _lastArtBase64)
          ? art
          : state.artBase64;
      if (art != null) _lastArtBase64 = art;

      // Only emit if something meaningful changed
      final bool titleChanged = title != state.title;
      final bool artistChanged = artist != state.artist;
      final bool playingChanged = isPlaying != state.isPlaying;
      final bool durationChanged = duration != state.duration;
      final bool artChanged = newArt != state.artBase64;
      // Position changes handled by timer, only sync if big difference
      final bool positionDrift = (position - state.position).abs() > 3000;

      if (titleChanged ||
          artistChanged ||
          playingChanged ||
          durationChanged ||
          artChanged ||
          positionDrift) {
        emit(
          state.copyWith(
            title: title,
            artist: artist,
            album: album,
            packageName: pkg,
            artBase64: newArt,
            duration: duration,
            position: position,
            isPlaying: isPlaying,
          ),
        );
      }

      // Start/stop position timer based on playing state
      if (isPlaying) {
        _startPositionTimer();
      } else {
        _stopPositionTimer();
      }
    });

    on<ClearMedia>((e, emit) {
      _stopPositionTimer();
      emit(const MediaState());
    });

    on<UpdatePosition>((e, emit) {
      if (state.isPlaying && e.position <= state.duration) {
        emit(state.copyWith(position: e.position));
      }
    });

    on<SeekTo>((e, emit) {
      emit(state.copyWith(position: e.position));
    });

    _sub = _channel.receiveBroadcastStream().listen(
      (dynamic event) {
        print('MediaBloc received event: $event');
        if (event is Map) {
          add(_NativeMediaUpdate(event));
        }
      },
      onError: (e) {
        print('MediaBloc stream error: $e');
      },
      onDone: () {
        print('MediaBloc stream done');
      },
    );
    print('MediaBloc: Stream subscription started');
  }

  void _startPositionTimer() {
    _stopPositionTimer();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPlaying && state.position < state.duration) {
        add(UpdatePosition(state.position + 1000));
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _stopPositionTimer();
    return super.close();
  }
}
