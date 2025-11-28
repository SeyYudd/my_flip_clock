import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock/wakelock.dart';
import '../blocs/settings_bloc.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Row(
                      children: [
                        const Text('Layout:'),
                        const SizedBox(width: 8),
                        DropdownButton<LayoutMode>(
                          value: state.layoutMode,
                          items: const [
                            DropdownMenuItem(
                              value: LayoutMode.single,
                              child: Text('Single'),
                            ),
                            DropdownMenuItem(
                              value: LayoutMode.grid2,
                              child: Text('2 Grid'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null)
                              context.read<SettingsBloc>().add(
                                UpdateLayoutMode(v),
                              );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Keep screen on'),
                        const Spacer(),
                        Switch(
                          value: state.keepScreenOn,
                          onChanged: (v) async {
                            context.read<SettingsBloc>().add(
                              UpdateKeepScreenOn(v),
                            );
                            if (v)
                              await Wakelock.enable();
                            else
                              await Wakelock.disable();
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Fullscreen'),
                        const Spacer(),
                        Switch(
                          value: state.fullscreen,
                          onChanged: (v) async {
                            context.read<SettingsBloc>().add(
                              UpdateFullscreen(v),
                            );
                            if (v) {
                              await SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.immersiveSticky,
                              );
                            } else {
                              await SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Orientation'),
                        const Spacer(),
                        PopupMenuButton<int>(
                          onSelected: (v) async {
                            if (v == 0) {
                              await SystemChrome.setPreferredOrientations([]);
                              context.read<SettingsBloc>().add(
                                UpdateOrientations([]),
                              );
                            } else if (v == 1) {
                              await SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.landscapeRight,
                              ]);
                              context.read<SettingsBloc>().add(
                                UpdateOrientations([
                                  DeviceOrientation.landscapeLeft,
                                  DeviceOrientation.landscapeRight,
                                ]),
                              );
                            } else {
                              await SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitUp,
                                DeviceOrientation.portraitDown,
                              ]);
                              context.read<SettingsBloc>().add(
                                UpdateOrientations([
                                  DeviceOrientation.portraitUp,
                                  DeviceOrientation.portraitDown,
                                ]),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 0, child: Text('Auto')),
                            PopupMenuItem(value: 1, child: Text('Landscape')),
                            PopupMenuItem(value: 2, child: Text('Portrait')),
                          ],
                          child: const Icon(Icons.swap_vert),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
