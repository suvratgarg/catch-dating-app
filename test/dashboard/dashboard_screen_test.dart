import 'dart:async';

import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

DashboardRecommendationsQuery _recommendationsQueryForUser(UserProfile user) =>
    DashboardRecommendationsQuery(
      userId: user.uid,
      followedClubIds: user.joinedRunClubIds,
    );

void main() {
  group('DashboardScreen', () {
    testWidgets('shows a loading state while booked runs are loading', (
      tester,
    ) async {
      final signedUpRunsController = StreamController<List<Run>>.broadcast();
      addTearDown(signedUpRunsController.close);

      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchSignedUpRunsProvider(
              user.uid,
            ).overrideWith((ref) => signedUpRunsController.stream),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("Let's find your first run"), findsNothing);
    });

    testWidgets('shows an error when booked runs fail to load', (tester) async {
      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchSignedUpRunsProvider(user.uid).overrideWithValue(
              AsyncError<List<Run>>(Exception('boom'), StackTrace.empty),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to load your booked runs.'), findsOneWidget);
      expect(find.text("Let's find your first run"), findsNothing);
    });

    testWidgets('shows the empty dashboard when there are no booked runs', (
      tester,
    ) async {
      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchSignedUpRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text("Let's find your first run"), findsOneWidget);
      expect(find.byType(DashboardFull), findsNothing);
    });

    testWidgets('shows the full dashboard when booked runs exist', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1', joinedRunClubIds: joinedClubIds);
      final nextRun = buildRun(
        signedUpUserIds: const ['runner-1'],
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchSignedUpRunsProvider(
              user.uid,
            ).overrideWithValue(AsyncData<List<Run>>([nextRun])),
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(DashboardFull), findsOneWidget);
      expect(find.textContaining('NEXT RUN'), findsOneWidget);
    });

    testWidgets('pauses dashboard streams while the Home tab is inactive', (
      tester,
    ) async {
      final activeIndex = ValueNotifier<int>(1);
      addTearDown(activeIndex.dispose);

      var userListens = 0;
      var userCancels = 0;
      var signedUpListens = 0;
      var signedUpCancels = 0;
      final userController = StreamController<UserProfile?>.broadcast(
        onListen: () => userListens += 1,
        onCancel: () => userCancels += 1,
      );
      final signedUpRunsController = StreamController<List<Run>>.broadcast(
        onListen: () => signedUpListens += 1,
        onCancel: () => signedUpCancels += 1,
      );
      addTearDown(userController.close);
      addTearDown(signedUpRunsController.close);

      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith(
              (ref) => userController.stream,
            ),
            watchSignedUpRunsProvider(
              user.uid,
            ).overrideWith((ref) => signedUpRunsController.stream),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ValueListenableBuilder<int>(
              valueListenable: activeIndex,
              builder: (context, index, child) {
                return AppShellActiveTab(
                  index: index,
                  child: const DashboardScreen(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(userListens, 0);
      expect(signedUpListens, 0);

      activeIndex.value = 0;
      await tester.pump();
      userController.add(user);
      await tester.pump();
      signedUpRunsController.add(const []);
      await tester.pump();

      expect(userListens, 1);
      expect(signedUpListens, 1);
      expect(find.text("Let's find your first run"), findsOneWidget);

      activeIndex.value = 1;
      await tester.pump();
      await tester.pump();

      expect(userCancels, 0);
      expect(signedUpCancels, 1);

      activeIndex.value = 0;
      await tester.pump();

      expect(userListens, 1);
      expect(signedUpListens, 2);
    });
  });

  group('DashboardFull', () {
    testWidgets('shows a loading card while attended runs are loading', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1', joinedRunClubIds: joinedClubIds);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncLoading<List<Run>>()),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              signedUpRuns: [
                buildRun(signedUpUserIds: const ['runner-1']),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Loading your recent runs...'), findsOneWidget);
    });

    testWidgets('surfaces attended-runs errors instead of hiding the section', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1', joinedRunClubIds: joinedClubIds);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(user.uid).overrideWithValue(
              AsyncError<List<Run>>(Exception('boom'), StackTrace.empty),
            ),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWith((ref) async => const []),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              signedUpRuns: [
                buildRun(signedUpUserIds: const ['runner-1']),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Unable to load your recent runs.'), findsOneWidget);
    });

    testWidgets('shows a loading card while recommendations are loading', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1', joinedRunClubIds: joinedClubIds);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWithValue(const AsyncLoading<List<Run>>()),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              signedUpRuns: [
                buildRun(signedUpUserIds: const ['runner-1']),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.drag(
        find.byKey(DashboardFull.scrollViewKey),
        const Offset(0, -500),
      );
      await tester.pump();

      expect(find.text('Loading recommended runs...'), findsOneWidget);
    });

    testWidgets(
      'surfaces recommendation errors instead of hiding the section',
      (tester) async {
        final joinedClubIds = ['club-1'];
        final user = buildUser(
          uid: 'runner-1',
          joinedRunClubIds: joinedClubIds,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchAttendedRunsProvider(
                user.uid,
              ).overrideWith((ref) => Stream.value(const [])),
              dashboardRecommendedRunsProvider(
                _recommendationsQueryForUser(user),
              ).overrideWithValue(
                AsyncError<List<Run>>(Exception('boom'), StackTrace.empty),
              ),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: DashboardFull(
                user: user,
                signedUpRuns: [
                  buildRun(signedUpUserIds: const ['runner-1']),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Unable to load recommended runs.'), findsOneWidget);
      },
    );

    testWidgets('renders active swipe and recommendations on the happy path', (
      tester,
    ) async {
      final now = DateTime.now();
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1', joinedRunClubIds: joinedClubIds);
      final nextRun = buildRun(
        id: 'next-run',
        signedUpUserIds: const ['runner-1'],
        startTime: now.add(const Duration(hours: 3)),
      );
      final swipeRun = buildRun(
        id: 'swipe-run',
        attendedUserIds: const ['runner-1'],
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 2)),
      );
      final recommendedRun = buildRun(
        id: 'recommended-run',
        runClubId: 'club-1',
        startTime: now.add(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(AsyncData<List<Run>>([swipeRun])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWithValue(AsyncData<List<Run>>([recommendedRun])),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(user: user, signedUpRuns: [nextRun]),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.textContaining('NEXT RUN'), findsOneWidget);
      expect(find.textContaining('SWIPE WINDOW CLOSING'), findsOneWidget);

      await tester.drag(
        find.byKey(DashboardFull.scrollViewKey),
        const Offset(0, -500),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('Recommended runs'), findsOneWidget);
    });

    testWidgets('scrolls the greeting header away with dashboard content', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 560);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final joinedClubIds = ['club-1'];
      final user = buildUser(
        uid: 'runner-1',
        name: 'Suvrat Garg',
        joinedRunClubIds: joinedClubIds,
      );
      final nextRun = buildRun(
        id: 'next-run',
        signedUpUserIds: const ['runner-1'],
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(user: user, signedUpRuns: [nextRun]),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      final greetingFinder = find.text('${DashboardFull.greeting()}, Suvrat');
      expect(greetingFinder, findsOneWidget);

      await tester.drag(
        find.byKey(DashboardFull.scrollViewKey),
        const Offset(0, -180),
      );
      await _pumpDashboardUi(tester);

      expect(greetingFinder, findsNothing);
    });

    testWidgets('shows self check-in as the first dashboard content card', (
      tester,
    ) async {
      final now = DateTime.now();
      final user = buildUser(uid: 'runner-1');
      final run = buildRun(
        id: 'check-in-run',
        signedUpUserIds: const ['runner-1'],
        startTime: now.add(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(user: user, signedUpRuns: [run]),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('CHECK-IN OPEN'), findsOneWidget);
      expect(find.text('Check in'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('CHECK-IN OPEN')).dy,
        lessThan(tester.getTopLeft(find.textContaining('NEXT RUN')).dy),
      );
    });

    testWidgets('shows host attendance as the first dashboard content card', (
      tester,
    ) async {
      final now = DateTime.now();
      final user = buildUser(uid: 'host-1');
      final hostedRun = buildRun(
        id: 'hosted-run',
        runClubId: 'club-host',
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now.add(const Duration(minutes: 55)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryForUser(user),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            ..._dashboardHostOverrides(
              user,
              hostedClubId: 'club-host',
              hostedRuns: [hostedRun],
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(user: user, signedUpRuns: const []),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('HOST TOOLS'), findsOneWidget);
      expect(find.text('Take Attendance'), findsOneWidget);
      expect(find.textContaining('NEXT RUN'), findsNothing);
    });
  });

  group('QuickActions', () {
    testWidgets('shows all primary dashboard actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: QuickActions()),
        ),
      );

      expect(find.text('Soon'), findsNothing);
      expect(find.text('Browse runs'), findsOneWidget);
      expect(find.text('Map view'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('keeps primary action tiles visually consistent', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: QuickActions()),
        ),
      );

      final browseSize = tester.getSize(_quickActionSurface('Browse runs'));
      final mapSize = tester.getSize(_quickActionSurface('Map view'));
      final calendarSize = tester.getSize(_quickActionSurface('Calendar'));

      expect(mapSize.height, browseSize.height);
      expect(calendarSize.height, browseSize.height);
      expect(mapSize.width, browseSize.width);
      expect(calendarSize.width, browseSize.width);
    });

    testWidgets('navigates for all primary actions', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: QuickActions()),
          ),
          GoRoute(
            path: Routes.runClubsListScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Clubs screen')),
          ),
          GoRoute(
            path: Routes.runMapScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Map screen')),
          ),
          GoRoute(
            path: Routes.calendarScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Calendar screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Map view'));
      await _pumpDashboardUi(tester);

      expect(find.text('Map screen'), findsOneWidget);

      router.go('/');
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Browse runs'));
      await _pumpDashboardUi(tester);

      expect(find.text('Clubs screen'), findsOneWidget);

      router.go('/');
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Calendar'));
      await _pumpDashboardUi(tester);

      expect(find.text('Calendar screen'), findsOneWidget);
    });
  });
}

Future<void> _pumpDashboardUi(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

Finder _quickActionSurface(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(CatchSurface),
  );
}

List _dashboardHostOverrides(
  UserProfile user, {
  String hostedClubId = 'club-host',
  List<Run> hostedRuns = const [],
}) {
  final hostedClubs = hostedRuns.isEmpty
      ? const <RunClub>[]
      : [buildRunClub(id: hostedClubId, hostUserId: user.uid)];

  return [
    watchRunClubsHostedByProvider(
      user.uid,
    ).overrideWithValue(AsyncData(hostedClubs)),
    if (hostedRuns.isNotEmpty)
      watchRunsForClubProvider(
        hostedClubId,
      ).overrideWithValue(AsyncData<List<Run>>(hostedRuns)),
  ];
}
