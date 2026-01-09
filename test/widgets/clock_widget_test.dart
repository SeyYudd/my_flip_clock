import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_stand_clock/widgets/clock_widget.dart';
import 'package:my_stand_clock/blocs/clock_bloc.dart';

void main() {
  group('ClockWidget', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => ClockBloc(),
            child: const Scaffold(body: ClockWidget()),
          ),
        ),
      );

      expect(find.byType(ClockWidget), findsOneWidget);
    });

    testWidgets('displays time elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => ClockBloc(),
            child: const Scaffold(body: ClockWidget()),
          ),
        ),
      );

      await tester.pump();

      // Should have some text elements for time display
      expect(find.byType(Text), findsWidgets);
    });
  });
}
