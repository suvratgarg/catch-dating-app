import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../runs/runs_test_helpers.dart';

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
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(user: user, signedUpRuns: [nextRun]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('NEXT RUN'), findsOneWidget);
      expect(find.textContaining('SWIPE WINDOW CLOSING'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recommended runs'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recommended runs'), findsOneWidget);
    });
  });

  group('QuickActions', () {
    testWidgets('shows all primary dashboard actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: QuickActions(tokens: CatchTokens.sunsetLight)),
        ),
      );

      expect(find.text('Soon'), findsNothing);
      expect(find.text('Browse runs'), findsOneWidget);
      expect(find.text('Map view'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('navigates for all primary actions', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                Scaffold(body: QuickActions(tokens: CatchTokens.sunsetLight)),
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
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map view'));
      await tester.pumpAndSettle();

      expect(find.text('Map screen'), findsOneWidget);

      router.go('/');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Browse runs'));
      await tester.pumpAndSettle();

      expect(find.text('Clubs screen'), findsOneWidget);

      router.go('/');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.text('Calendar screen'), findsOneWidget);
    });
  });
}
