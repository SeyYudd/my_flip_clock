import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_stand_clock/screens/page_empty.dart';
import '../blocs/media_bloc.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({super.key});

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  final MethodChannel _mediaControl = const MethodChannel('media_control');
  bool _notificationAccess = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationAccess();
  }

  Future<void> _checkNotificationAccess() async {
    try {
      final granted = await _mediaControl.invokeMethod<bool>(
        'isNotificationAccessGranted',
      );
      if (mounted) setState(() => _notificationAccess = granted == true);
    } catch (_) {
      if (mounted) setState(() => _notificationAccess = false);
    }
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _mediaControl.invokeMethod('openNotificationAccessSettings');
      await Future.delayed(const Duration(milliseconds: 800));
      await _checkNotificationAccess();
    } catch (_) {}
  }

  Future<void> _sendCommand(String command, String packageName) async {
    try {
      await _mediaControl.invokeMethod('transport', {
        'package': packageName,
        'command': command,
      });
    } catch (e) {
      debugPrint('Media control error: $e');
    }
  }

  Future<void> _seekTo(int position, String packageName) async {
    try {
      await _mediaControl.invokeMethod('transport', {
        'package': packageName,
        'command': 'seekTo',
        'position': position,
      });
    } catch (e) {
      debugPrint('Seek error: $e');
    }
  }

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressBar(MediaState parentState) {
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) {
        // Only rebuild for position changes when on the same track
        return previous.position != current.position ||
            previous.duration != current.duration;
      },
      builder: (context, state) {
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: state.position.toDouble().clamp(
                  0,
                  state.duration.toDouble(),
                ),
                min: 0,
                max: state.duration.toDouble(),
                onChanged: (value) {
                  // Update local position immediately for smooth UI
                  context.read<MediaBloc>().add(SeekTo(value.toInt()));
                },
                onChangeEnd: (value) {
                  // Actually seek when user releases
                  _seekTo(value.toInt(), state.packageName);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      buildWhen: (previous, current) {
        // Only rebuild when non-position properties change
        return previous.title != current.title ||
            previous.artist != current.artist ||
            previous.album != current.album ||
            previous.artBase64 != current.artBase64 ||
            previous.isPlaying != current.isPlaying ||
            previous.duration != current.duration ||
            previous.packageName != current.packageName ||
            // Also rebuild when transitioning from/to empty state
            (previous.title.isEmpty != current.title.isEmpty);
      },
      builder: (context, state) {
        // No media playing
        if (state.title.isEmpty) {
          return Center(
            child: PageEmpty(
              title: 'No Music Playing',
              icon: Icons.music_note,
              message: _notificationAccess
                  ? 'Start playing music on your device'
                  : 'Enable notification access to control media',
              widget: !_notificationAccess
                  ? ElevatedButton(
                      onPressed: _openNotificationSettings,
                      child: const Text('Enable Access'),
                    )
                  : null,
            ),
          );
        }

        // Decode album art
        Uint8List? artBytes;
        try {
          if (state.artBase64 != null) {
            artBytes = base64Decode(state.artBase64!);
          }
        } catch (_) {}

        return _buildPlayerCard(state, artBytes);
      },
    );
  }

  Widget _buildPlayerCard(MediaState state, Uint8List? artBytes) {
    final controlsEnabled = _notificationAccess && state.packageName.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      child: Stack(
        children: [
          // Background with album art
          if (artBytes != null)
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Image.memory(
                  artBytes,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.5),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple.shade800, Colors.black],
                  ),
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album art and info
                    Row(
                      children: [
                        // Album art
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: artBytes != null
                              ? Image.memory(artBytes, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 40,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        // Title and artist
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.artist,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (state.album.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  state.album,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress bar with its own BlocBuilder for position updates
                    if (state.duration > 0) ...[_buildProgressBar(state)],

                    const SizedBox(height: 8),

                    // Playback controls
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Previous
                          IconButton(
                            onPressed: controlsEnabled
                                ? () => _sendCommand(
                                    'previous',
                                    state.packageName,
                                  )
                                : null,
                            icon: const Icon(Icons.skip_previous_rounded),
                            iconSize: 36,
                            color: Colors.white,
                            disabledColor: Colors.white38,
                          ),
                          const SizedBox(width: 8),
                          // Play/Pause
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: controlsEnabled
                                  ? () => _sendCommand(
                                      state.isPlaying ? 'pause' : 'play',
                                      state.packageName,
                                    )
                                  : null,
                              icon: Icon(
                                state.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              iconSize: 40,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Next
                          IconButton(
                            onPressed: controlsEnabled
                                ? () => _sendCommand('next', state.packageName)
                                : null,
                            icon: const Icon(Icons.skip_next_rounded),
                            iconSize: 36,
                            color: Colors.white,
                            disabledColor: Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
