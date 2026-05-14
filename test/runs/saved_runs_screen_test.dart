import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/routing/go_router.dart' as app_router;
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/saved_runs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../run_clubs/run_clubs_test_helpers.dart' as club_test;
import 'runs_test_helpers.dart';

void main() {
  group('SavedRunsScreen', () {
    testWidgets('shows an empty state when there are no saved runs', (
      tester,
    ) async {
      await _pumpSavedRuns(
        tester,
        savedRuns: const [],
        child: const SavedRunsScreen(),
      );

      expect(find.text('No saved runs yet'), findsOneWidget);
      expect(
        find.text('Save runs you want to revisit before booking.'),
        findsOneWidget,
      );
    });

    testWidgets('orders upcoming saved runs before past saved runs', (
      tester,
    ) async {
      final now = DateTime.now();
      final future = buildRun(
        id: 'future-run',
        startTime: now.add(const Duration(days: 1)),
        meetingPoint: 'Future Park',
      );
      final past = buildRun(
        id: 'past-run',
        startTime: now.subtract(const Duration(days: 1)),
        meetingPoint: 'Past Park',
      );

      await _pumpSavedRuns(
        tester,
        savedRuns: [past, future],
        child: const SavedRunsScreen(),
      );
      await tester.pump();

      expect(find.text('Runs you saved'), findsOneWidget);
      expect(find.text('Stride Social'), findsAtLeastNWidgets(1));
      expect(find.text('SAVED'), findsOneWidget);
      expect(find.text('PAST'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Future Park')).dy,
        lessThan(tester.getTopLeft(find.text('Past Park')).dy),
      );
    });

    testWidgets('opens saved run detail from the list', (tester) async {
      final run = buildRun(
        id: 'run-1',
        runClubId: 'club-1',
        startTime: DateTime.now().add(const Duration(days: 1)),
        meetingPoint: 'Future Park',
      );
      final router = GoRouter(
        initialLocation: app_router.Routes.savedRunsScreen.path,
        routes: [
          GoRoute(
            path: app_router.Routes.savedRunsScreen.path,
            builder: (_, _) => const SavedRunsScreen(),
          ),
          GoRoute(
            path: app_router.Routes.savedRunDetailScreen.path,
            builder: (context, state) => Scaffold(
              body: Text(
                'Run detail ${state.pathParameters['runClubId']}/${state.pathParameters['runId']}',
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await _pumpSavedRuns(
        tester,
        savedRuns: [run],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );

      await tester.tap(find.text('Future Park'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Run detail club-1/run-1'), findsOneWidget);
    });
  });
}

Future<void> _pumpSavedRuns(
  WidgetTester tester, {
  required List<Run> savedRuns,
  required Widget child,
}) async {
  final wrapped = child is MaterialApp || child is WidgetsApp
      ? child
      : MaterialApp(theme: AppTheme.light, home: child);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
        runClubsRepositoryProvider.overrideWith(
          (ref) =>
              club_test.FakeRunClubsRepository()
                ..clubsById['club-1'] = buildRunClub(id: 'club-1'),
        ),
        watchSavedRunDetailsForUserProvider(
          'runner-1',
        ).overrideWithValue(AsyncData<List<Run>>(savedRuns)),
      ],
      child: wrapped,
    ),
  );
  await tester.pump();
}
