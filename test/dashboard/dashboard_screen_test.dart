import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
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

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

DashboardRecommendationsQuery _recommendationsQueryFor(
  String uid,
  List<String> followedClubIds,
) => DashboardRecommendationsQuery(
  userId: uid,
  followedClubIds: followedClubIds,
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
      final user = buildUser(uid: 'runner-1');
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
            ).overrideWithValue(const AsyncData<List<Run>>([])),
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
    });

    testWidgets('uses native Dashboard and Activity tabs', (tester) async {
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

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text("Let's find your first run"), findsOneWidget);

      await tester.tap(find.text('Activity'));
      await _pumpDashboardUi(tester);

      expect(find.text('No new activity'), findsOneWidget);
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
            _membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
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
      final user = buildUser(uid: 'runner-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncLoading<List<Run>>()),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
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
            ).overrideWith((ref) async => const []),
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
            ).overrideWithValue(const AsyncLoading<List<Run>>()),
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
                AsyncError<List<Run>>(Exception('boom'), StackTrace.empty),
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
            ).overrideWithValue(AsyncData<List<Run>>([recommendedRun])),
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
      final user = buildUser(uid: 'runner-1', name: 'Suvrat Garg');
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
            ).overrideWithValue(const AsyncData<List<Run>>([])),
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

      final greetingFinder = find.text('${DashboardFull.greeting()}, Suvrat');
      expect(greetingFinder, findsOneWidget);

      await tester.drag(
        find.byKey(DashboardFull.scrollViewKey),
        const Offset(0, -180),
      );
      await _pumpDashboardUi(tester);

      expect(greetingFinder, findsNothing);
    });

    testWidgets('profile avatar uses thumbnail URL and opens Profile tab', (
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
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpRuns: [nextRun],
            ),
          ),
          GoRoute(
            path: Routes.profileScreen.path,
            name: Routes.profileScreen.name,
            builder: (_, _) => const Scaffold(body: Text('Profile tab')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedRunsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            dashboardRecommendedRunsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is NetworkImage &&
              (widget.image as NetworkImage).url ==
                  'https://example.test/profile-thumb.jpg',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(DashboardFull.profileAvatarButtonKey));
      await _pumpDashboardUi(tester);

      expect(find.text('Profile tab'), findsOneWidget);
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
            ).overrideWithValue(const AsyncData<List<Run>>([])),
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

      expect(find.text('CHECK-IN OPEN'), findsOneWidget);
      expect(find.text('Check in'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('CHECK-IN OPEN')).dy,
        lessThan(tester.getTopLeft(find.textContaining('NEXT RUN')).dy),
      );

      await tester.tap(find.text('Check in'));
      await _pumpDashboardUi(tester);

      expect(find.text('CHECKED IN'), findsOneWidget);
      expect(find.text('Checked in.'), findsOneWidget);
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
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(const AsyncData<List<Run>>([])),
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

class _FakeRunCheckInLocationService implements RunCheckInLocationService {
  const _FakeRunCheckInLocationService();

  @override
  Future<RunCheckInLocation> getCurrentLocation() async {
    return const RunCheckInLocation(latitude: 19.07, longitude: 72.87);
  }
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
