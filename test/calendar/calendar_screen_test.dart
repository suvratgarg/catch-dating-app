import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart' as app_router;
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_screen.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_agenda_list.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

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
      expect(find.text('No planned runs yet'), findsNothing);
    });

    testWidgets('shows the empty calendar when the user has no planned runs', (
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

      expect(find.text('No planned runs yet'), findsOneWidget);
      expect(
        find.text('Runs you book or save will show up here by day and time.'),
        findsOneWidget,
      );
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('shows an error state when planned runs fail to load', (
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
        find.text('Your planned runs could not be loaded.'),
        findsOneWidget,
      );
      expect(find.text('No planned runs yet'), findsNothing);
    });

    testWidgets('renders agenda stats and booked run details', (tester) async {
      final now = DateTime.now();
      final firstRunStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1, hours: 7, minutes: 15));
      final secondRunStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 2, hours: 18, minutes: 30));
      final runs = [
        buildRun(
          id: 'run-late',
          startTime: secondRunStart,
          meetingPoint: 'Juhu Beach Gate',
          distanceKm: 8,
          pace: PaceLevel.moderate,
          bookedCount: 2,
          capacityLimit: 12,
        ),
        buildRun(
          id: 'run-early',
          startTime: firstRunStart,
          meetingPoint: 'Carter Road Promenade',
          distanceKm: 5,
          pace: PaceLevel.easy,
          bookedCount: 1,
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

      expect(find.text(_monthYearLabel(firstRunStart)), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('13 km'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('07:15'), findsAtLeastNWidgets(1));

      await tester.scrollUntilVisible(
        find.text('Carter Road Promenade'),
        180,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text(_agendaDayLabel(firstRunStart, now)), findsOneWidget);
      expect(find.text('Carter Road Promenade'), findsOneWidget);
      expect(find.text('Juhu Beach Gate'), findsOneWidget);
      expect(find.text('5km · Easy · 1/20'), findsOneWidget);
      expect(find.text('8km · Moderate · 2/12'), findsOneWidget);
    });

    testWidgets('includes future saved runs as planned calendar rows', (
      tester,
    ) async {
      final now = DateTime.now();
      final signedUpRun = buildRun(
        id: 'signed-up-run',
        startTime: now.add(const Duration(days: 2)),
        meetingPoint: 'Booked Promenade',
        distanceKm: 5,
        bookedCount: 1,
      );
      final savedFutureRun = buildRun(
        id: 'saved-future-run',
        startTime: now.add(const Duration(days: 1)),
        meetingPoint: 'Saved Start',
        distanceKm: 8,
        bookedCount: 3,
      );
      final savedPastRun = buildRun(
        id: 'saved-past-run',
        startTime: now.subtract(const Duration(days: 1)),
        meetingPoint: 'Old Saved Start',
        distanceKm: 10,
      );

      await _pumpCalendar(
        tester,
        savedRuns: [savedFutureRun, savedPastRun],
        overrides: [
          watchSignedUpRunsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Run>>([signedUpRun])),
        ],
      );

      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('13 km'), findsOneWidget);
      expect(find.text('Old Saved Start'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Saved Start'),
        180,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text('Saved Start'), findsOneWidget);
      expect(find.text('Booked Promenade'), findsOneWidget);
      expect(find.text('SAVED'), findsOneWidget);
      expect(find.text('JOINED'), findsOneWidget);
    });

    testWidgets('anchors calendar summary to the next upcoming run', (
      tester,
    ) async {
      final now = DateTime.now();
      final pastRun = buildRun(
        id: 'past-run',
        startTime: now.subtract(const Duration(days: 4, hours: -6)),
        meetingPoint: 'Old Beach',
        distanceKm: 5,
        pace: PaceLevel.easy,
      );
      final futureRun = buildRun(
        id: 'future-run',
        startTime: now.add(const Duration(days: 3, hours: 2)),
        meetingPoint: 'Future Park',
        distanceKm: 8,
        pace: PaceLevel.moderate,
      );

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpRunsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Run>>([pastRun, futureRun])),
        ],
      );

      expect(find.text('Next'), findsOneWidget);
      expect(
        find.text(_timeLabel(futureRun.startTime)),
        findsAtLeastNWidgets(1),
      );
      expect(
        tester.getTopLeft(find.text('Future Park')).dy,
        lessThan(tester.getTopLeft(find.text('Old Beach')).dy),
      );
    });

    testWidgets(
      'falls back to the current week when there are no upcoming runs',
      (tester) async {
        final now = DateTime.now();
        final oldRun = buildRun(
          id: 'old-run',
          startTime: DateTime(
            now.year,
            now.month,
            1,
          ).subtract(const Duration(days: 4)).add(const Duration(hours: 7)),
          meetingPoint: 'Past Month Park',
          distanceKm: 5,
          pace: PaceLevel.easy,
        );

        await _pumpCalendar(
          tester,
          overrides: [
            watchSignedUpRunsProvider(
              'runner-1',
            ).overrideWithValue(AsyncData<List<Run>>([oldRun])),
          ],
        );

        expect(find.text(_monthYearLabel(now)), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
        expect(find.text('None'), findsOneWidget);
        expect(find.text('Past Month Park'), findsOneWidget);
      },
    );

    testWidgets('scrolls as one surface so later agenda runs are reachable', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 560);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.now();
      final runs = List.generate(
        8,
        (index) => buildRun(
          id: 'run-$index',
          startTime: now.add(Duration(days: index + 1)),
          meetingPoint: 'Future Run $index',
          distanceKm: 5,
          pace: PaceLevel.easy,
        ),
      );

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpRunsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Run>>(runs)),
        ],
      );

      expect(find.text('Future Run 7'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Future Run 7'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text('Future Run 7'), findsOneWidget);
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
      await pumpFeatureUi(tester);

      expect(find.text('Day timeline'), findsOneWidget);
      expect(find.text('Carter Road Promenade'), findsOneWidget);
      expect(find.text('5km · Easy'), findsOneWidget);
    });

    testWidgets(
      'opens a booked run from the agenda and back returns to calendar',
      (tester) async {
        final run = buildRun(
          id: 'run-1',
          runClubId: 'club-1',
          startTime: DateTime(2026, 5, 7, 7, 15),
          meetingPoint: 'Carter Road Promenade',
          distanceKm: 5,
          pace: PaceLevel.easy,
          bookedCount: 1,
        );
        final user = buildUser(uid: 'runner-1');
        final runClub = buildRunClub(id: 'club-1');
        final router = GoRouter(
          initialLocation: app_router.Routes.calendarScreen.path,
          routes: [
            GoRoute(
              path: app_router.Routes.calendarScreen.path,
              name: app_router.Routes.calendarScreen.name,
              builder: (context, state) => const CalendarScreen(),
            ),
            GoRoute(
              path: app_router.Routes.calendarRunDetailScreen.path,
              name: app_router.Routes.calendarRunDetailScreen.name,
              builder: (context, state) => RunDetailScreen(
                runClubId: state.pathParameters['runClubId']!,
                runId: state.pathParameters['runId']!,
              ),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uidProvider.overrideWithValue(
                const AsyncData<String?>('runner-1'),
              ),
              watchUserProfileProvider.overrideWithValue(AsyncData(user)),
              watchSignedUpRunsProvider(
                user.uid,
              ).overrideWithValue(AsyncData<List<Run>>([run])),
              watchSavedRunDetailsForUserProvider(
                user.uid,
              ).overrideWithValue(const AsyncData<List<Run>>([])),
              watchRunProvider(run.id).overrideWithValue(AsyncData(run)),
              watchSavedRunProvider(
                user.uid,
                run.id,
              ).overrideWithValue(const AsyncData(null)),
              watchRunParticipationProvider(run.id, user.uid).overrideWithValue(
                AsyncData(
                  _participation(
                    run: run,
                    uid: user.uid,
                    status: RunParticipationStatus.signedUp,
                  ),
                ),
              ),
              fetchRunClubProvider(
                runClub.id,
              ).overrideWithValue(AsyncData(runClub)),
              watchReviewsForRunProvider(
                run.id,
              ).overrideWithValue(const AsyncData([])),
              paymentRepositoryProvider.overrideWithValue(
                FakePaymentRepository(),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        );
        await _pumpRouterFrame(tester);

        expect(find.text('Calendar'), findsWidgets);
        expect(_routerPath(router), app_router.Routes.calendarScreen.path);

        await _scrollCalendarDown(tester);

        final runCard = find.byType(RunAgendaRunCard);
        expect(tester.widget<RunAgendaRunCard>(runCard).onTap, isNotNull);

        tester.widget<RunAgendaRunCard>(runCard).onTap!.call();
        expect(tester.takeException(), isNull);
        await _pumpRouterFrame(tester);

        expect(find.byType(RunDetailScreen), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);

        await tester.tap(find.byTooltip('Back'));
        await _pumpRouterFrame(tester);

        expect(_routerPath(router), app_router.Routes.calendarScreen.path);
        expect(find.byType(RunDetailScreen), findsNothing);
        expect(find.text('Calendar'), findsWidgets);
      },
    );
  });
}

Future<void> _pumpCalendar(
  WidgetTester tester, {
  required Iterable overrides,
  List<Run> savedRuns = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
        watchSavedRunDetailsForUserProvider(
          'runner-1',
        ).overrideWithValue(AsyncData<List<Run>>(savedRuns)),
        ...overrides,
      ],
      child: MaterialApp(theme: AppTheme.light, home: const CalendarScreen()),
    ),
  );
  await tester.pump();
}

Future<void> _pumpRouterFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _scrollCalendarDown(WidgetTester tester) async {
  for (var i = 0; i < 3; i += 1) {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -320));
    await tester.pump();
  }
}

RunParticipation _participation({
  required Run run,
  required String uid,
  required RunParticipationStatus status,
}) {
  final now = DateTime(2026, 1, 1);
  return RunParticipation(
    id: runParticipationId(runId: run.id, uid: uid),
    runId: run.id,
    runClubId: run.runClubId,
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

String _timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String _monthYearLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _agendaDayLabel(DateTime date, DateTime now) {
  const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  if (DateUtils.isSameDay(date, now)) return 'TODAY';
  return '${weekdays[date.weekday - 1]} · ${date.day} ${months[date.month - 1]}';
}

String _routerPath(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;
