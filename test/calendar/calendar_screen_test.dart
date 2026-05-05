import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  group('CalendarScreen', () {
    testWidgets('shows a loading state while booked runs are loading', (
      tester,
    ) async {
      final runsController = StreamController<List<Run>>();
      addTearDown(runsController.close);

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpRunsProvider(
            'runner-1',
          ).overrideWith((ref) => runsController.stream),
        ],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No booked runs yet'), findsNothing);
    });

    testWidgets('shows the empty calendar when the user has no booked runs', (
      tester,
    ) async {
      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpRunsProvider(
            'runner-1',
          ).overrideWithValue(const AsyncData<List<Run>>([])),
        ],
      );

      expect(find.text('No booked runs yet'), findsOneWidget);
      expect(
        find.text('Runs you book will show up here by day and time.'),
        findsOneWidget,
      );
      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('shows an error state when booked runs fail to load', (
      tester,
    ) async {
      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpRunsProvider('runner-1').overrideWithValue(
            AsyncError<List<Run>>(Exception('boom'), StackTrace.empty),
          ),
        ],
      );

      expect(find.text('Calendar unavailable'), findsOneWidget);
      expect(
        find.text('Your booked runs could not be loaded.'),
        findsOneWidget,
      );
      expect(find.text('No booked runs yet'), findsNothing);
    });

    testWidgets('renders agenda stats and booked run details', (tester) async {
      final runs = [
        buildRun(
          id: 'run-late',
          startTime: DateTime(2026, 5, 8, 18, 30),
          meetingPoint: 'Juhu Beach Gate',
          distanceKm: 8,
          pace: PaceLevel.moderate,
          signedUpUserIds: const ['runner-1', 'runner-2'],
          capacityLimit: 12,
        ),
        buildRun(
          id: 'run-early',
          startTime: DateTime(2026, 5, 7, 7, 15),
          meetingPoint: 'Carter Road Promenade',
          distanceKm: 5,
          pace: PaceLevel.easy,
          signedUpUserIds: const ['runner-1'],
          capacityLimit: 20,
        ),
      ];

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpRunsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Run>>(runs)),
        ],
      );

      expect(find.text('May 2026'), findsOneWidget);
      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('13 km'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('07:15'), findsAtLeastNWidgets(1));

      expect(find.text('THU · 7 MAY'), findsOneWidget);
      expect(find.text('FRI · 8 MAY'), findsOneWidget);
      expect(find.text('Carter Road Promenade'), findsOneWidget);
      expect(find.text('Juhu Beach Gate'), findsOneWidget);
      expect(find.text('5km · Easy · 1/20'), findsOneWidget);
      expect(find.text('8km · Moderate · 2/12'), findsOneWidget);
    });

    testWidgets('switches from agenda to day timeline', (tester) async {
      final run = buildRun(
        id: 'run-1',
        startTime: DateTime(2026, 5, 7, 7, 15),
        meetingPoint: 'Carter Road Promenade',
        distanceKm: 5,
        pace: PaceLevel.easy,
      );

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpRunsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Run>>([run])),
        ],
      );

      expect(find.text('Day timeline'), findsNothing);

      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();

      expect(find.text('Day timeline'), findsOneWidget);
      expect(find.text('Carter Road Promenade'), findsOneWidget);
      expect(find.text('5km · Easy'), findsOneWidget);
    });
  });
}

Future<void> _pumpCalendar(
  WidgetTester tester, {
  required Iterable overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
        ...overrides,
      ],
      child: MaterialApp(theme: AppTheme.light, home: const CalendarScreen()),
    ),
  );
  await tester.pump();
}
