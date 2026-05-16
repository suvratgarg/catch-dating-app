import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/run_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_check_in_location_service.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../run_clubs/run_clubs_test_helpers.dart' as club_test;
import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

DashboardRecommendationsQuery _recommendationsQueryFor(
  String uid,
  List<String> followedClubIds,
) => DashboardRecommendationsQuery(
  userId: uid,
  followedClubIds: followedClubIds,
);

const _noRecommendationCandidates =
    AsyncData<List<DashboardRunRecommendationCandidate>>([]);

AsyncData<WeeklyRunningActivitySnapshot> _emptyWeeklyActivitySnapshot() {
  return AsyncData(
    WeeklyRunningActivitySnapshot.permissionRequired(
      referenceDate: DateTime(2026, 5, 13),
      platformLabel: 'Apple Health',
    ),
  );
}

DashboardRunRecommendationCandidate _recommendationCandidate(
  Run run, {
  String clubName = 'Stride Social',
  String? clubLocation = 'mumbai',
}) => DashboardRunRecommendationCandidate(
  run: run,
  clubName: clubName,
  clubLocation: clubLocation,
);

RunClubMembership _membership({
  required String clubId,
  String uid = 'runner-1',
}) => RunClubMembership(
  id: runClubMembershipId(clubId: clubId, uid: uid),
  clubId: clubId,
  uid: uid,
  role: RunClubMembershipRole.member,
  status: RunClubMembershipStatus.active,
  joinedAt: DateTime(2026, 1, 1),
);

dynamic _membershipsOverride(UserProfile user, List<String> clubIds) =>
    watchActiveRunClubMembershipsForUserProvider(user.uid).overrideWith(
      (ref) => Stream.value(
        clubIds
            .map((clubId) => _membership(clubId: clubId, uid: user.uid))
            .toList(),
      ),
    );

dynamic _activityNotificationsOverride(
  UserProfile user, [
  List<ActivityNotification> notifications = const [],
]) => watchActivityNotificationsProvider(
  user.uid,
).overrideWithValue(AsyncData<List<ActivityNotification>>(notifications));

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
            _membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
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
            _membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
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

      await _pumpDashboardUi(tester);
      await _pumpDashboardUi(tester);

      expect(find.text('Unable to load your booked runs.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
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
            _membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
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

      await _pumpDashboardUi(tester);

      expect(find.text("Let's find your first run"), findsOneWidget);
      expect(find.byType(DashboardFull), findsNothing);
    });

    testWidgets('shows the full dashboard when booked runs exist', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(
        uid: 'runner-1',
        name: 'Manan Sethi',
        displayName: 'Subrath',
      );
      final nextRun = buildRun(
        bookedCount: 1,
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
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            _membershipsOverride(user, joinedClubIds),
            _activityNotificationsOverride(user),
            runRepositoryProvider.overrideWithValue(FakeRunRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            runCheckInLocationServiceProvider.overrideWithValue(
              const _FakeRunCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.byType(DashboardFullSliverBody), findsOneWidget);
      expect(find.textContaining('NEXT RUN'), findsOneWidget);
      expect(find.text('Stride Social'), findsOneWidget);
      expect(find.text('${DashboardFull.greeting()}, Subrath'), findsOneWidget);
      expect(find.text('${DashboardFull.greeting()}, Manan'), findsNothing);
      expect(find.byType(TabBar), findsNothing);
      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('shows notification action with unread badge instead of tabs', (
      tester,
    ) async {
      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            _membershipsOverride(user, const []),
            _activityNotificationsOverride(user, [
              _activityNotification(id: 'unread-1', uid: user.uid),
              _activityNotification(id: 'unread-2', uid: user.uid),
              _activityNotification(
                id: 'read',
                uid: user.uid,
                readAt: DateTime(2026, 5, 16),
              ),
            ]),
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

      await _pumpDashboardUi(tester);

      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Activity'), findsNothing);
      expect(find.byTooltip('Notifications'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text("Let's find your first run"), findsOneWidget);
    });

    testWidgets('notifications screen opens as a full screen and marks read', (
      tester,
    ) async {
      final notifications = [
        _activityNotification(id: 'unread', uid: 'runner-1'),
        _activityNotification(
          id: 'read',
          uid: 'runner-1',
          readAt: DateTime(2026, 5, 16),
        ),
      ];
      final repository = _FakeActivityNotificationRepository(notifications);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
            activityNotificationRepositoryProvider.overrideWithValue(
              repository,
            ),
            watchSignedUpRunsProvider(
              'runner-1',
            ).overrideWithValue(const AsyncData<List<Run>>([])),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ActivityScreen(),
          ),
        ),
      );
      await _pumpDashboardUi(tester);
      await _pumpDashboardUi(tester);

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text("It's a catch"), findsNWidgets(2));
      expect(find.text('Mark all read'), findsNothing);
      expect(repository.markReadCalls, hasLength(1));
      expect(repository.markReadCalls.single.map((item) => item.id), [
        'unread',
      ]);
    });
  });

  group('DashboardFull', () {
    testWidgets('shows a loading card while attended runs are loading', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncLoading<List<Run>>()),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            runRepositoryProvider.overrideWithValue(FakeRunRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            runCheckInLocationServiceProvider.overrideWithValue(
              const _FakeRunCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [buildRun(bookedCount: 1)],
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
      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(user.uid).overrideWithValue(
              AsyncError<List<Run>>(Exception('boom'), StackTrace.empty),
            ),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWith(
              (ref) async => const <DashboardRunRecommendationCandidate>[],
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [buildRun(bookedCount: 1)],
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
      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(
              const AsyncLoading<List<DashboardRunRecommendationCandidate>>(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [buildRun(bookedCount: 1)],
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
        final user = buildUser(uid: 'runner-1');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchAttendedRunsProvider(
                user.uid,
              ).overrideWith((ref) => Stream.value(const [])),
              dashboardRecommendedRunsProvider(
                _recommendationsQueryFor(user.uid, joinedClubIds),
              ).overrideWithValue(
                AsyncError<List<DashboardRunRecommendationCandidate>>(
                  Exception('boom'),
                  StackTrace.empty,
                ),
              ),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: DashboardFull(
                user: user,
                followedClubIds: joinedClubIds,
                signedUpRuns: [buildRun(bookedCount: 1)],
              ),
            ),
          ),
        );

        await _pumpDashboardUi(tester);
        await tester.drag(
          find.byKey(DashboardFull.scrollViewKey),
          const Offset(0, -500),
        );
        await _pumpDashboardUi(tester);

        expect(find.text('Unable to load recommended runs.'), findsOneWidget);
      },
    );

    testWidgets('renders active swipe and recommendations on the happy path', (
      tester,
    ) async {
      final now = DateTime.now();
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1');
      final nextRun = buildRun(
        id: 'next-run',
        bookedCount: 1,
        startTime: now.add(const Duration(hours: 3)),
      );
      final swipeRun = buildRun(
        id: 'swipe-run',
        checkedInCount: 1,
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 2)),
      );
      final recommendedRun = buildRun(
        id: 'recommended-run',
        runClubId: 'club-1',
        meetingPoint: 'Race Course Road main gate',
        distanceKm: 12,
        priceInPaise: 15000,
        bookedCount: 4,
        capacityLimit: 12,
        pace: PaceLevel.moderate,
        startTime: now.add(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(AsyncData<List<Run>>([swipeRun])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(
              AsyncData<List<DashboardRunRecommendationCandidate>>([
                _recommendationCandidate(
                  recommendedRun,
                  clubName: 'Bandra Run Club',
                ),
              ]),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [nextRun],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Run Focus'), findsOneWidget);
      expect(find.textContaining('AFTER THE RUN'), findsOneWidget);
      expect(find.text('Start catching'), findsOneWidget);
      expect(find.byKey(RunFocusRail.pageIndicatorKey), findsOneWidget);

      await tester.drag(
        find.byKey(DashboardFull.scrollViewKey),
        const Offset(0, -500),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('Recommended runs'), findsOneWidget);
      expect(
        find.text(recommendedRun.title, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Race Course Road main gate', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('12km', skipOffstage: false), findsOneWidget);
      expect(find.text('₹150', skipOffstage: false), findsOneWidget);
      expect(find.text('Bandra Run Club', skipOffstage: false), findsOneWidget);
      expect(find.text('4/12 signed up', skipOffstage: false), findsOneWidget);
      expect(find.text('Fits your pace', skipOffstage: false), findsOneWidget);
    });

    testWidgets('shows connected weekly running activity from health data', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1');
      final nextRun = buildRun(
        id: 'next-run',
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            weeklyRunningActivityProvider.overrideWithValue(
              AsyncData(
                WeeklyRunningActivitySnapshot.connected(
                  referenceDate: DateTime.now(),
                  platformLabel: 'Apple Health',
                  activities: [
                    RunnerActivity(
                      stableId: 'health-run',
                      provider: RunnerActivityProvider.appleHealth,
                      type: RunnerActivityType.running,
                      startTime: DateTime.now(),
                      endTime: DateTime.now().add(const Duration(hours: 1)),
                      distanceMeters: 6400,
                      sourceName: 'Apple Watch',
                    ),
                  ],
                ),
              ),
            ),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            ..._dashboardHostOverrides(user, includeWeeklyActivity: false),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [nextRun],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Your stride · this week'), findsOneWidget);
      expect(find.text('6.4'), findsOneWidget);
      expect(find.text('km · 1 run'), findsOneWidget);
      expect(find.text('From Apple Health'), findsOneWidget);
    });

    testWidgets('shows a health permission action on the stride card', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StrideCard(
              snapshot: WeeklyRunningActivitySnapshot.permissionRequired(
                referenceDate: DateTime(2026, 5, 13),
                platformLabel: 'Apple Health',
              ),
              onConnect: () {},
            ),
          ),
        ),
      );

      expect(find.text('Connect Apple Health'), findsOneWidget);
      expect(
        find.text('Connect Apple Health to include runs outside Catch.'),
        findsOneWidget,
      );
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
        name: 'Manan Sethi',
        displayName: 'Subrath',
      );
      final nextRun = buildRun(
        id: 'next-run',
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            runRepositoryProvider.overrideWithValue(FakeRunRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            runCheckInLocationServiceProvider.overrideWithValue(
              const _FakeRunCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [nextRun],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      final greetingFinder = find.text('${DashboardFull.greeting()}, Subrath');
      expect(greetingFinder, findsOneWidget);
      expect(find.text('${DashboardFull.greeting()}, Manan'), findsNothing);

      await tester.drag(
        find.byKey(DashboardFull.scrollViewKey),
        const Offset(0, -180),
      );
      await _pumpDashboardUi(tester);

      expect(greetingFinder, findsNothing);
    });

    testWidgets('does not render a profile shortcut in the dashboard header', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(uid: 'runner-1', name: 'Suvrat Garg').copyWith(
        photoUrls: const ['https://example.test/full-profile.jpg'],
        photoThumbnailUrls: const ['https://example.test/profile-thumb.jpg'],
      );
      final nextRun = buildRun(
        id: 'next-run',
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [nextRun],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.byTooltip('Open profile'), findsNothing);
      expect(find.bySemanticsLabel('Open profile'), findsNothing);
    });

    testWidgets('shows self check-in as the first dashboard content card', (
      tester,
    ) async {
      final now = DateTime.now();
      final user = buildUser(uid: 'runner-1');
      final run = buildRun(
        id: 'check-in-run',
        bookedCount: 1,
        startTime: now.add(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
            runRepositoryProvider.overrideWithValue(FakeRunRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            runCheckInLocationServiceProvider.overrideWithValue(
              const _FakeRunCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: const [],
              signedUpRuns: [run],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Run Focus'), findsOneWidget);
      expect(find.text('CHECK-IN OPEN'), findsOneWidget);
      expect(find.text('Check in'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.textContaining('NEXT RUN'), findsNothing);

      await tester.tap(find.text('Check in'));
      await _pumpDashboardUi(tester);

      expect(find.text('CHECKED IN'), findsOneWidget);
      expect(find.text('Checked in.'), findsOneWidget);
    });

    testWidgets('run focus directions opens the run location externally', (
      tester,
    ) async {
      Uri? launchedUri;
      final user = buildUser(uid: 'runner-1');
      final run = buildRun(
        id: 'directions-run',
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
        startingPointLat: 22.725848,
        startingPointLng: 75.897401,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
            externalUrlLauncherProvider.overrideWithValue((
              uri, {
              LaunchMode mode = LaunchMode.platformDefault,
            }) async {
              launchedUri = uri;
              return true;
            }),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: const [],
              signedUpRuns: [run],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Directions'));
      await tester.pump();

      expect(launchedUri?.host, 'www.google.com');
      expect(launchedUri?.path, '/maps/dir/');
      expect(
        launchedUri?.queryParameters['destination'],
        '22.725848,75.897401',
      );

      launchedUri = null;
      await tester.tap(find.text('Add to calendar'));
      await tester.pump();

      expect(launchedUri?.host, 'calendar.google.com');
      expect(launchedUri?.queryParameters['action'], 'TEMPLATE');
      expect(launchedUri?.queryParameters['text'], run.title);
    });

    testWidgets(
      'run focus uses full-width snapping cards with stacked actions',
      (tester) async {
        final user = buildUser(uid: 'runner-1');
        final firstRun = buildRun(
          id: 'run-focus-first',
          bookedCount: 1,
          startTime: DateTime(2026, 5, 28, 9, 10),
        );
        final secondRun = buildRun(
          id: 'run-focus-second',
          bookedCount: 1,
          startTime: DateTime(2026, 5, 29, 9, 10),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchAttendedRunsProvider(
                user.uid,
              ).overrideWithValue(const AsyncData<List<Run>>([])),
              dashboardRecommendedRunsProvider(
                _recommendationsQueryFor(user.uid, const []),
              ).overrideWithValue(_noRecommendationCandidates),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: DashboardFull(
                user: user,
                followedClubIds: const [],
                signedUpRuns: [firstRun, secondRun],
              ),
            ),
          ),
        );

        await _pumpDashboardUi(tester);

        expect(find.text('Thursday Morning Run'), findsOneWidget);
        expect(find.text('Friday Morning Run'), findsNothing);
        expect(find.byKey(RunFocusRail.pageIndicatorKey), findsOneWidget);

        final railWidth = tester
            .getSize(find.byKey(RunFocusRail.railKey))
            .width;
        final cardWidth = tester
            .getSize(_runFocusCardSurface('Thursday Morning Run'))
            .width;
        expect(cardWidth, railWidth);
        expect(
          tester.getTopLeft(find.text('Directions')).dy,
          greaterThan(tester.getTopLeft(find.text('View run')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Add to calendar')).dy,
          greaterThan(tester.getTopLeft(find.text('Directions')).dy),
        );

        await tester.drag(
          find.text('Thursday Morning Run'),
          const Offset(-420, 0),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.text('Thursday Morning Run'), findsNothing);
        expect(find.text('Friday Morning Run'), findsOneWidget);
      },
    );

    testWidgets('run focus combines catching and review for an attended run', (
      tester,
    ) async {
      final now = DateTime.now();
      final user = buildUser(uid: 'runner-1');
      final attendedRun = buildRun(
        id: 'attended-run',
        checkedInCount: 2,
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(AsyncData<List<Run>>([attendedRun])),
            watchReviewsByUserProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Review>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: const [],
              signedUpRuns: const [],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Run Focus'), findsOneWidget);
      expect(find.textContaining('AFTER THE RUN'), findsOneWidget);
      expect(find.text('Start catching'), findsOneWidget);
      expect(find.text('Write review'), findsOneWidget);
      expect(find.text('Review your run'), findsNothing);
    });

    testWidgets('shows host attendance inside the consolidated host rail', (
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
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
            ..._dashboardHostOverrides(
              user,
              hostedClubId: 'club-host',
              hostedRuns: [hostedRun],
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: const [],
              signedUpRuns: const [],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Host tools'), findsOneWidget);
      expect(find.text('1 run'), findsOneWidget);
      expect(find.text('HOST TOOLS'), findsOneWidget);
      expect(find.text('ATTENDANCE OPEN'), findsOneWidget);
      expect(find.text('Take attendance'), findsOneWidget);
      expect(find.text('Manage run'), findsOneWidget);
      expect(find.text('Take Attendance'), findsNothing);
      expect(find.textContaining('NEXT RUN'), findsNothing);
    });

    testWidgets('shows a paged host tools rail for upcoming hosted runs', (
      tester,
    ) async {
      final now = DateTime.now();
      final user = buildUser(uid: 'host-1');
      final hostedRuns = [
        buildRun(
          id: 'hosted-run-1',
          runClubId: 'club-host',
          startTime: now.add(const Duration(hours: 3)),
          bookedCount: 2,
        ),
        buildRun(
          id: 'hosted-run-2',
          runClubId: 'club-host',
          startTime: now.add(const Duration(hours: 5)),
          bookedCount: 7,
          waitlistedCount: 1,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
            ..._dashboardHostOverrides(
              user,
              hostedClubId: 'club-host',
              hostedRuns: hostedRuns,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: const [],
              signedUpRuns: const [],
            ),
          ),
        ),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('Host tools'), findsOneWidget);
      expect(find.text('2 runs'), findsOneWidget);
      expect(find.text('HOST TOOLS'), findsOneWidget);
      expect(find.text('Manage run'), findsOneWidget);
      expect(find.text('Attendance opens later'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
      expect(find.textContaining('2/20 booked'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('host-run-tools-carousel')),
        const Offset(-120, 0),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('2/2'), findsOneWidget);
      expect(find.textContaining('7/20 booked'), findsOneWidget);
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
      expect(find.text('Browse runs'), findsNothing);
      expect(find.text('Map view'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Saved runs'), findsOneWidget);
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

      final mapSize = tester.getSize(_quickActionSurface('Map view'));
      final calendarSize = tester.getSize(_quickActionSurface('Calendar'));
      final savedSize = tester.getSize(_quickActionSurface('Saved runs'));

      expect(calendarSize.height, mapSize.height);
      expect(savedSize.height, mapSize.height);
      expect(calendarSize.width, mapSize.width);
      expect(savedSize.width, mapSize.width);
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
            path: Routes.runMapScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Map screen')),
          ),
          GoRoute(
            path: Routes.calendarScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Calendar screen')),
          ),
          GoRoute(
            path: Routes.savedRunsScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Saved runs screen')),
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

      await tester.tap(find.text('Calendar'));
      await _pumpDashboardUi(tester);

      expect(find.text('Calendar screen'), findsOneWidget);

      router.go('/');
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Saved runs'));
      await _pumpDashboardUi(tester);

      expect(find.text('Saved runs screen'), findsOneWidget);
    });

    testWidgets('host tools rail opens the selected hosted run', (
      tester,
    ) async {
      final run = buildRun(id: 'hosted-run', runClubId: 'club-host');
      final tool = DashboardHostRunTool(
        run: run,
        attendanceState: DashboardHostAttendanceState.opensLater,
      );
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(body: HostToolsRail(tools: [tool])),
          ),
          GoRoute(
            path: Routes.hostRunManageScreen.path,
            name: Routes.hostRunManageScreen.name,
            builder: (_, state) => Scaffold(
              body: Text(
                'Manage ${state.pathParameters['runClubId']} ${state.pathParameters['runId']}',
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Manage run'));
      await _pumpDashboardUi(tester);

      expect(find.text('Manage club-host hosted-run'), findsOneWidget);
    });

    testWidgets('host tools rail opens attendance only when the window is open', (
      tester,
    ) async {
      final run = buildRun(id: 'hosted-run', runClubId: 'club-host');
      final tool = DashboardHostRunTool(
        run: run,
        attendanceState: DashboardHostAttendanceState.open,
      );
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(body: HostToolsRail(tools: [tool])),
          ),
          GoRoute(
            path: Routes.attendanceSheet.path,
            name: Routes.attendanceSheet.name,
            builder: (_, state) => Scaffold(
              body: Text(
                'Attendance ${state.pathParameters['runClubId']} ${state.pathParameters['runId']}',
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Take attendance'));
      await _pumpDashboardUi(tester);

      expect(find.text('Attendance club-host hosted-run'), findsOneWidget);
    });
  });
}

class _FakeRunCheckInLocationService implements RunCheckInLocationService {
  const _FakeRunCheckInLocationService();

  @override
  Future<RunCheckInLocation> getCurrentLocation() async {
    return const RunCheckInLocation(latitude: 19.07, longitude: 72.87);
  }
}

class _FakeActivityNotificationRepository
    implements ActivityNotificationRepository {
  _FakeActivityNotificationRepository(this.notifications);

  final List<ActivityNotification> notifications;
  final List<List<ActivityNotification>> markReadCalls = [];

  @override
  Stream<List<ActivityNotification>> watchActivity({
    required String uid,
    int limit = 50,
  }) => Stream.value(notifications);

  @override
  Future<void> markAllRead({
    required String uid,
    required Iterable<ActivityNotification> notifications,
  }) async {
    markReadCalls.add(notifications.toList(growable: false));
  }
}

ActivityNotification _activityNotification({
  required String id,
  required String uid,
  DateTime? readAt,
}) {
  return ActivityNotification(
    id: id,
    uid: uid,
    type: ActivityNotificationType.match,
    title: "It's a catch",
    body: 'You and Runner Two matched. Say hi!',
    createdAt: DateTime(2026, 5, 16, 10),
    readAt: readAt,
    matchId: 'match-1',
  );
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

Finder _runFocusCardSurface(String title) {
  return find.ancestor(
    of: find.text(title),
    matching: find.byType(CatchSurface),
  );
}

List _dashboardHostOverrides(
  UserProfile user, {
  String hostedClubId = 'club-host',
  List<Run> hostedRuns = const [],
  bool includeWeeklyActivity = true,
  AsyncValue<WeeklyRunningActivitySnapshot>? weeklyActivity,
}) {
  final hostedClubs = hostedRuns.isEmpty
      ? const <RunClub>[]
      : [buildRunClub(id: hostedClubId, hostUserId: user.uid)];

  return [
    runClubsRepositoryProvider.overrideWith(
      (ref) => club_test.FakeRunClubsRepository()
        ..clubsById['club-1'] = buildRunClub(id: 'club-1')
        ..clubsById[hostedClubId] = buildRunClub(
          id: hostedClubId,
          hostUserId: user.uid,
        ),
    ),
    watchRunClubsHostedByProvider(
      user.uid,
    ).overrideWithValue(AsyncData(hostedClubs)),
    if (includeWeeklyActivity)
      weeklyRunningActivityProvider.overrideWithValue(
        weeklyActivity ?? _emptyWeeklyActivitySnapshot(),
      ),
    if (hostedRuns.isNotEmpty)
      watchRunsForClubProvider(
        hostedClubId,
      ).overrideWithValue(AsyncData<List<Run>>(hostedRuns)),
  ];
}
