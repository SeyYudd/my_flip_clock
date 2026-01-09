import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:my_stand_clock/blocs/settings_bloc.dart';
import 'package:flutter/services.dart';

void main() {
  group('SettingsBloc', () {
    late SettingsBloc settingsBloc;

    setUp(() {
      settingsBloc = SettingsBloc();
    });

    tearDown(() {
      settingsBloc.close();
    });

    test('initial state has default values', () {
      expect(settingsBloc.state.fullscreen, false);
      expect(settingsBloc.state.keepScreenOn, false);
      expect(settingsBloc.state.orientations, isEmpty);
    });

    blocTest<SettingsBloc, SettingsState>(
      'toggles fullscreen when UpdateFullscreen is added',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(UpdateFullscreen(true)),
      verify: (bloc) {
        expect(bloc.state.fullscreen, true);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'toggles keep screen on when UpdateKeepScreenOn is added',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(UpdateKeepScreenOn(true)),
      verify: (bloc) {
        expect(bloc.state.keepScreenOn, true);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'updates orientation when UpdateOrientations is added',
      build: () => settingsBloc,
      act: (bloc) =>
          bloc.add(UpdateOrientations([DeviceOrientation.portraitUp])),
      verify: (bloc) {
        expect(bloc.state.orientations, contains(DeviceOrientation.portraitUp));
      },
    );
  });
}
