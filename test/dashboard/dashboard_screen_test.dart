import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/club_posts_home_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_calendar_links.dart';
import 'package:catch_dating_app/events/data/event_check_in_location_service.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/explore/data/explore_recommendations_repository.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../clubs/clubs_test_helpers.dart' as club_test;
import '../events/events_test_helpers.dart';
import '../support/dashboard_test_helpers.dart';
import '../test_pump_helpers.dart';

final _l10n = AppLocalizationsEn();

dynamic membershipsOverride(UserProfile user, List<String> clubIds) =>
    watchActiveClubMembershipsForUserProvider(user.uid).overrideWith(
      (ref) => Stream.value(
        clubIds
            .map((clubId) => membership(clubId: clubId, uid: user.uid))
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
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  group('NotificationsListState', () {
    test('groups visible rows with an injected clock', () {
      final now = DateTime(2026, 5, 16, 12);
      final state = buildNotificationsListState(
        l10n: _l10n,
        uid: const AsyncData<String?>('runner-1'),
        notifications: AsyncData<List<ActivityNotification>>([
          _activityNotification(
            id: 'today',
            uid: 'runner-1',
            title: 'Today catch',
            createdAt: DateTime(2026, 5, 16, 10),
          ),
          _activityNotification(
            id: 'yesterday',
            uid: 'runner-1',
            title: 'Yesterday catch',
            createdAt: DateTime(2026, 5, 15, 18),
            readAt: DateTime(2026, 5, 16, 8),
          ),
          _activityNotification(
            id: 'week',
            uid: 'runner-1',
            title: 'This week catch',
            createdAt: DateTime(2026, 5, 12, 9),
          ),
          _activityNotification(
            id: 'earlier',
            uid: 'runner-1',
            title: 'Earlier catch',
            createdAt: DateTime(2026, 5, 1, 9),
          ),
          _activityNotification(
            id: 'hidden-message',
            uid: 'runner-1',
            type: ActivityNotificationType.message,
            title: 'Hidden message',
            createdAt: DateTime(2026, 5, 16, 11),
          ),
        ]),
        now: now,
        markAllReadPending: true,
      );

      final content = state as NotificationsContent;
      expect(content.groups.map((group) => group.label), [
        'Today',
        'Yesterday',
        'This week',
        'Earlier',
      ]);
      expect(content.groups.first.rows.single.title, 'Today catch');
      expect(content.groups.first.rows.single.timeLabel, '2h');
      expect(content.groups.first.rows.single.route, '/chats/match-1');
      expect(content.visibleNotifications, hasLength(4));
      expect(content.unreadNotifications, hasLength(3));
      expect(content.showMarkAllReadAction, isTrue);
      expect(content.canMarkAllRead, isFalse);
      expect(content.markAllReadLabel(_l10n), 'Marking...');
    });
  });

  group('DashboardScreen', () {
    testWidgets('shows a loading state while booked events are loading', (
      tester,
    ) async {
      final signedUpEventsController =
          StreamController<List<Event>>.broadcast();
      addTearDown(signedUpEventsController.close);

      final user = buildUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            membershipsOverride(user, const []),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            _activityNotificationsOverride(user),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWith((ref) => signedUpEventsController.stream),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CatchSkeleton), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("Let's find your first event"), findsNothing);
    });

    testWidgets('shows an error when booked events fail to load', (
      tester,
    ) async {
      final user = buildUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            membershipsOverride(user, const []),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            _activityNotificationsOverride(user),
            watchSignedUpEventsProvider(user.uid).overrideWithValue(
              AsyncError<List<Event>>(Exception('boom'), StackTrace.empty),
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

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text("Let's find your first event"), findsNothing);
    });

    testWidgets('uses shared offline copy for typed dashboard load failures', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith(
              (ref) => Stream<UserProfile?>.error(
                const NetworkException(
                  'offline',
                  'No internet connection. Connect to the internet and try again.',
                ),
                StackTrace.empty,
              ),
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

      expect(find.text('Connection issue'), findsOneWidget);
      expect(
        find.text(
          'We are having trouble connecting. Please check your internet and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Dashboard unavailable'), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows the in-body idle CTA when there are no live modules', (
      tester,
    ) async {
      final user = buildUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            watchReviewsByUserProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Review>>([])),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(
        find.text('Your catches unlock\nafter your first event.'),
        findsOneWidget,
      );
      expect(find.byType(DashboardFullSliverBody), findsOneWidget);
    });

    testWidgets('logs idle home open, module impression, and CTA tap', (
      tester,
    ) async {
      final user = buildUser();
      final reporter = _FakeAnalyticsReporter();
      final router = GoRouter(
        initialLocation: Routes.dashboardScreen.path,
        routes: [
          GoRoute(
            path: Routes.dashboardScreen.path,
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: Routes.exploreScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Explore screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appAnalyticsProvider.overrideWithValue(
              AppAnalytics(reporter: reporter, shouldCollect: true),
            ),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            watchReviewsByUserProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Review>>([])),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(
        reporter.events,
        contains(
          const _AnalyticsEventCall(AnalyticsEvents.homeOpened, {
            AnalyticsParameters.homeState: 'idle',
          }),
        ),
      );
      expect(
        reporter.events,
        contains(
          const _AnalyticsEventCall(AnalyticsEvents.homeModuleImpression, {
            AnalyticsParameters.homeModule: 'idle_cta',
          }),
        ),
      );

      await tester.tap(find.text('Find an event near me'));
      await _pumpDashboardUi(tester);

      expect(find.text('Explore screen'), findsOneWidget);
      expect(
        reporter.events,
        contains(
          const _AnalyticsEventCall(AnalyticsEvents.homeActionTap, {
            AnalyticsParameters.homeModule: 'idle_cta',
            AnalyticsParameters.homeAction: 'find_event',
          }),
        ),
      );
    });

    testWidgets('keeps host tools out of the consumer empty state', (
      tester,
    ) async {
      final now = DateTime.now();
      final user = buildUser(uid: 'host-1');
      final hostedRun = buildEvent(
        id: 'hosted-event',
        clubId: 'club-host',
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now.add(const Duration(minutes: 55)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            watchReviewsByUserProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Review>>([])),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user, hostedEvents: [hostedRun]),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(
        find.text('Your catches unlock\nafter your first event.'),
        findsOneWidget,
      );
      expect(find.byType(DashboardFullSliverBody), findsOneWidget);
      expect(find.text('Host event'), findsNothing);
      expect(find.text('Attendance open'), findsNothing);
      expect(find.text('Take attendance'), findsNothing);
    });

    testWidgets('shows the full dashboard when booked events exist', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(name: 'Manan Sethi', displayName: 'Subrath');
      final joinedClub = buildClub(name: 'Home Run Club');
      final nextEvent = buildEvent(
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWithValue(AsyncData<List<Event>>([nextEvent])),
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(noRecommendationCandidates),
            watchClubsByIdsProvider(
              ClubsByIdQuery(joinedClubIds),
            ).overrideWith((ref) => Stream.value([joinedClub])),
            membershipsOverride(user, joinedClubIds),
            _activityNotificationsOverride(user),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
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
      expect(find.textContaining('Next event'), findsOneWidget);
      expect(find.text('Stride Social'), findsOneWidget);
      expect(
        find.text('${dashboardGreeting(_l10n, DateTime.now())}, Subrath'),
        findsOneWidget,
      );
      expect(
        find.text('${dashboardGreeting(_l10n, DateTime.now())}, Manan'),
        findsNothing,
      );
      expect(find.byType(TabBar), findsNothing);
      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('dashboard body omits the legacy followed clubs rail', (
      tester,
    ) async {
      final joinedClub = buildClub(name: 'Home Run Club');
      final user = buildUser();
      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        uid: user.uid,
        viewer: user,
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync: noRecommendationCandidates,
        weeklyActivityAsync: emptyWeeklyActivitySnapshot(),
        now: DateTime(2026, 5, 13),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchClubsByIdsProvider(
              ClubsByIdQuery([joinedClub.id]),
            ).overrideWith((ref) => Stream.value([joinedClub])),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  DashboardFullSliverBody(viewModel: viewModel, user: user),
                ],
              ),
            ),
          ),
        ),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('Your clubs'), findsNothing);
      expect(find.text('Home Run Club'), findsNothing);
      expect(
        find.text('Your catches unlock\nafter your first event.'),
        findsOneWidget,
      );
    });

    testWidgets('club posts home section renders unread post cards', (
      tester,
    ) async {
      final joinedClub = club_test.buildClub(name: 'Race Course Road Runners');
      final user = buildUser();
      final notifications = [
        _activityNotification(
          id: 'club-post-1',
          uid: user.uid,
          type: ActivityNotificationType.clubUpdate,
          title: 'New update from Race Course Road Runners',
          body: 'Meet ten minutes early at the main gate.',
          clubId: joinedClub.id,
          postId: 'post-1',
          eventId: 'event-1',
        ),
      ];
      var opened = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchClubsByIdsProvider(
              ClubsByIdQuery([joinedClub.id]),
            ).overrideWith((ref) => Stream.value([joinedClub])),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: ClubPostsHomeSection(
                notifications: notifications,
                onOpenPost: (_) => opened = true,
              ),
            ),
          ),
        ),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('CLUB UPDATES', findRichText: true), findsOneWidget);
      expect(find.text('RACE COURSE ROAD RUNNERS'), findsOneWidget);
      expect(
        find.text('Meet ten minutes early at the main gate.'),
        findsOneWidget,
      );
      expect(find.text('Linked event'), findsOneWidget);

      await tester.tap(find.text('Meet ten minutes early at the main gate.'));
      await _pumpDashboardUi(tester);

      expect(opened, isTrue);
    });

    testWidgets('keeps signed-in idle free of old tab chrome', (tester) async {
      final user = buildUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            membershipsOverride(user, const []),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            _activityNotificationsOverride(user, [
              _activityNotification(id: 'unread-1', uid: user.uid),
              _activityNotification(id: 'unread-2', uid: user.uid),
              _activityNotification(
                id: 'read',
                uid: user.uid,
                readAt: DateTime(2026, 5, 16),
              ),
            ]),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
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
      expect(
        find.text('Your catches unlock\nafter your first event.'),
        findsOneWidget,
      );
    });

    testWidgets('notifications screen opens with a manual read action', (
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
            watchSignedUpEventsProvider(
              'runner-1',
            ).overrideWithValue(const AsyncData<List<Event>>([])),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ActivityScreen(),
          ),
        ),
      );
      await _pumpDashboardUi(tester);
      await _pumpDashboardUi(tester);

      expect(find.text('Activity'), findsOneWidget);
      expect(find.text("It's a catch"), findsNWidgets(2));
      expect(find.text('Mark all read'), findsOneWidget);
      expect(repository.markReadCalls, isEmpty);

      await tester.tap(find.text('Mark all read'));
      await _pumpDashboardUi(tester);

      expect(repository.markReadCalls, hasLength(1));
      expect(repository.markReadCalls.single.map((item) => item.id), [
        'unread',
      ]);
    });

    testWidgets('notification row navigation failures show branded feedback', (
      tester,
    ) async {
      final notifications = [
        _activityNotification(
          id: 'deep-link',
          uid: 'runner-1',
          title: 'Deep link catch',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
            activityNotificationRepositoryProvider.overrideWithValue(
              _FakeActivityNotificationRepository(notifications),
            ),
            watchSignedUpEventsProvider(
              'runner-1',
            ).overrideWithValue(const AsyncData<List<Event>>([])),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ActivityScreen(),
          ),
        ),
      );
      await _pumpDashboardUi(tester);
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Deep link catch'));
      await _pumpDashboardUi(tester);

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('notification rows compose the CatchField primitive', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: NotificationRow(
              title: 'Event starts tomorrow',
              time: '2h',
              body: 'Sundowner 5K meets at Carter Road Jetty.',
              unread: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final field = tester.widget<CatchField>(find.byType(CatchField));
      expect(field.title, 'Event starts tomorrow');
      expect(field.body, 'Sundowner 5K meets at Carter Road Jetty.');
      expect(field.emphasis, CatchFieldEmphasis.title);
      expect(field.mode, CatchFieldMode.read);
      expect(find.byIcon(CatchIcons.chevronRightRounded), findsNothing);

      expect(find.text('2H'), findsOneWidget);
      final titleRect = tester.getRect(find.text('Event starts tomorrow'));
      final bodyRect = tester.getRect(
        find.text('Sundowner 5K meets at Carter Road Jetty.'),
      );
      final timeRect = tester.getRect(find.text('2H'));
      expect(
        timeRect.center.dy,
        closeTo((titleRect.top + bodyRect.bottom) / 2, 0.5),
      );

      await tester.tap(find.text('2H'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('notifications screen renders grouped notification rows', (
      tester,
    ) async {
      final now = DateTime.now().subtract(const Duration(minutes: 5));
      final today = _activityNotification(
        id: 'today',
        uid: 'runner-1',
        title: 'Booked: Doubles ladder + drinks',
        body: 'Sun 22 Jun · 9:00 AM · Versova Padel, Court 2.',
        createdAt: now,
      );
      final yesterday = _activityNotification(
        id: 'yesterday',
        uid: 'runner-1',
        type: ActivityNotificationType.waitlistPromotion,
        title: 'A spot opened up',
        body: "You're off the waitlist for Saturday's Sundowner 5K.",
        createdAt: now.subtract(const Duration(days: 1)),
        readAt: now,
      );
      final thisWeek = _activityNotification(
        id: 'this-week',
        uid: 'runner-1',
        type: ActivityNotificationType.eventUpdated,
        title: 'Start time moved to 6:45 AM',
        body: 'Sundowner 5K now starts 15 min later. Same spot.',
        createdAt: now.subtract(const Duration(days: 3)),
        readAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
            watchActivityNotificationsProvider('runner-1').overrideWithValue(
              AsyncData<List<ActivityNotification>>([
                thisWeek,
                today,
                yesterday,
              ]),
            ),
            watchSignedUpEventsProvider(
              'runner-1',
            ).overrideWithValue(const AsyncData<List<Event>>([])),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ActivityScreen(),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('TODAY', findRichText: true), findsOneWidget);
      expect(find.text(today.title), findsOneWidget);
      expect(find.text(today.body), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('YESTERDAY', findRichText: true),
        120,
      );
      expect(find.text('YESTERDAY', findRichText: true), findsOneWidget);
      expect(find.text(yesterday.title), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('THIS WEEK', findRichText: true),
        120,
      );
      expect(find.text('THIS WEEK', findRichText: true), findsOneWidget);
      expect(find.text(thisWeek.title), findsOneWidget);
      expect(find.byType(NotificationRow), findsWidgets);
      expect(find.text('Upcoming events'), findsNothing);
      expect(find.text('Recent updates'), findsNothing);
      expect(find.text('Catch'), findsNothing);

      final todayField = find
          .ancestor(
            of: find.text(today.title),
            matching: find.byType(CatchField),
          )
          .first;
      final fieldRect = tester.getRect(todayField);
      final leadingIcon = find
          .descendant(of: todayField, matching: find.byType(Icon))
          .first;
      final viewWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(fieldRect.left, CatchSpacing.screenPx);
      expect(fieldRect.right, viewWidth - CatchSpacing.screenPx);
      expect(tester.getRect(leadingIcon).left, fieldRect.left);
    });
  });

  group('Dashboard full home shell', () {
    testWidgets('keeps the focus rail while attended enrichment is loading', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser();
      final event = buildEvent(id: 'booked-event', bookedCount: 1);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncLoading<List<Event>>()),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [event],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(EventFocusRail), findsOneWidget);
      expect(find.text(event.title), findsOneWidget);
      expect(find.text('Your activity · this week'), findsNothing);
    });

    testWidgets('keeps live focus content when attended enrichment fails', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser();
      final event = buildEvent(id: 'booked-event', bookedCount: 1);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(user.uid).overrideWithValue(
              AsyncError<List<Event>>(Exception('boom'), StackTrace.empty),
            ),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWith(
              (ref) async => const <ExploreEventRecommendationCandidate>[],
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [event],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(EventFocusRail), findsOneWidget);
      expect(find.text(event.title), findsOneWidget);
      expect(find.text('Dashboard unavailable'), findsNothing);
    });

    testWidgets('renders the catch window before booked events', (
      tester,
    ) async {
      final now = DateTime.now();
      final joinedClubIds = ['club-1'];
      final user = buildUser();
      final nextEvent = buildEvent(
        id: 'next-event',
        bookedCount: 1,
        startTime: now.add(const Duration(hours: 3)),
      );
      final swipeRun = buildEvent(
        id: 'swipe-event',
        checkedInCount: 1,
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(AsyncData<List<Event>>([swipeRun])),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [nextEvent],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Event Focus'), findsOneWidget);
      expect(find.textContaining('After the event'), findsOneWidget);
      expect(find.text('Start catching'), findsOneWidget);
      expect(find.byKey(EventFocusRail.pageIndicatorKey), findsOneWidget);
      final rail = tester.widget<EventFocusRail>(find.byType(EventFocusRail));
      expect(rail.activeSwipeEvent?.id, swipeRun.id);
      expect(rail.upcomingEvents.map((event) => event.id), [nextEvent.id]);
    });

    testWidgets('uses the display name in the greeting header', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 560);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime(2026, 5, 13, 8);
      final joinedClubIds = ['club-1'];
      final user = buildUser(name: 'Manan Sethi', displayName: 'Subrath');
      final nextEvent = buildEvent(
        id: 'next-event',
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardNowProvider.overrideWithValue(now),
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [nextEvent],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      final greetingFinder = find.text(
        '${dashboardGreeting(_l10n, now)}, Subrath',
      );
      expect(greetingFinder, findsOneWidget);
      expect(
        find.text('${dashboardGreeting(_l10n, now)}, Manan'),
        findsNothing,
      );
      expect(find.text('WEDNESDAY · MUMBAI'), findsNothing);

      expect(find.byType(DashboardFullSliverBody), findsOneWidget);
    });

    testWidgets('does not render a profile shortcut in the dashboard header', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser(name: 'Suvrat Garg').copyWith(
        profilePhotos: [
          ProfilePhoto.uploaded(
            position: 0,
            url: 'https://example.test/full-profile.jpg',
            storagePath: 'test-profiles/runner-1/0.jpg',
            now: DateTime(2026),
          ).copyWith(thumbnailUrl: 'https://example.test/profile-thumb.jpg'),
        ],
      );
      final nextEvent = buildEvent(
        id: 'next-event',
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(noRecommendationCandidates),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [nextEvent],
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
      final user = buildUser();
      final event = buildEvent(
        id: 'check-in-event',
        bookedCount: 1,
        startTime: now.add(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            eventSuccessRepositoryProvider.overrideWithValue(
              _FakeEventSuccessRepository(),
            ),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            dashboardNowProvider.overrideWithValue(now),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: const [],
              signedUpEvents: [event],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Event Focus'), findsOneWidget);
      expect(find.text('Check-in open'), findsOneWidget);
      expect(find.text('Check in'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.textContaining('Next event'), findsNothing);

      await tester.tap(find.text('Check in'));
      await _pumpDashboardUi(tester);

      expect(find.text('CHECKED IN'), findsOneWidget);
      expect(find.text('Checked in.'), findsOneWidget);
    });

    testWidgets('surfaces self check-in failures inline', (tester) async {
      final now = DateTime.now();
      final user = buildUser();
      final event = buildEvent(
        id: 'check-in-error-event',
        bookedCount: 1,
        startTime: now.add(const Duration(minutes: 5)),
      );
      final events = FakeEventRepository()
        ..selfCheckInError = StateError('Check-in failed');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(events),
            eventSuccessRepositoryProvider.overrideWithValue(
              _FakeEventSuccessRepository(),
            ),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            dashboardNowProvider.overrideWithValue(now),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: const [],
              signedUpEvents: [event],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Check in'));
      await _pumpDashboardUi(tester);

      expect(
        find.text('Something went wrong. Please try again.'),
        findsWidgets,
      );
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('event focus directions opens the event location externally', (
      tester,
    ) async {
      Uri? launchedUri;
      CalendarEventPayload? calendarEvent;
      final user = buildUser();
      final event = buildEvent(
        id: 'directions-event',
        bookedCount: 1,
        startTime: DateTime.now().add(const Duration(hours: 3)),
        startingPointLat: 22.725848,
        startingPointLng: 75.897401,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            exploreRecommendedEventsProvider(
              recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(noRecommendationCandidates),
            externalUrlLauncherProvider.overrideWithValue((
              uri, {
              LaunchMode mode = LaunchMode.platformDefault,
            }) async {
              launchedUri = uri;
              return true;
            }),
            nativeCalendarLauncherProvider.overrideWithValue((event) async {
              calendarEvent = event;
              return true;
            }),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: _DashboardFullTestShell(
              user: user,
              followedClubIds: const [],
              signedUpEvents: [event],
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

      expect(calendarEvent?.title, event.title);
      expect(calendarEvent?.startTime, event.startTime);
      expect(calendarEvent?.endTime, event.endTime);
    });

    testWidgets(
      'event focus uses full-width snapping cards with stacked actions',
      (tester) async {
        final now = DateTime.now();
        final user = buildUser();
        final firstRunStart = now.add(const Duration(days: 1));
        final secondRunStart = now.add(const Duration(days: 2));
        final firstRun = buildEvent(
          id: 'event-focus-first',
          bookedCount: 1,
          startTime: DateTime(
            firstRunStart.year,
            firstRunStart.month,
            firstRunStart.day,
            9,
            10,
          ),
        );
        final secondRun = buildEvent(
          id: 'event-focus-second',
          bookedCount: 1,
          startTime: DateTime(
            secondRunStart.year,
            secondRunStart.month,
            secondRunStart.day,
            9,
            10,
          ),
        );
        final firstRunTitle = firstRun.title;
        final secondRunTitle = secondRun.title;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchAttendedEventsProvider(
                user.uid,
              ).overrideWithValue(const AsyncData<List<Event>>([])),
              exploreRecommendedEventsProvider(
                recommendationsQueryFor(user.uid, const []),
              ).overrideWithValue(noRecommendationCandidates),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: _DashboardFullTestShell(
                user: user,
                followedClubIds: const [],
                signedUpEvents: [firstRun, secondRun],
              ),
            ),
          ),
        );

        await _pumpDashboardUi(tester);

        expect(find.text(firstRunTitle), findsOneWidget);
        expect(find.text(secondRunTitle), findsNothing);
        expect(find.byKey(EventFocusRail.pageIndicatorKey), findsOneWidget);

        final railWidth = tester
            .getSize(find.byKey(EventFocusRail.railKey))
            .width;
        final cardWidth = tester
            .getSize(_runFocusCardSurface(firstRunTitle))
            .width;
        expect(cardWidth, railWidth);
        expect(
          tester.getTopLeft(find.text('Directions')).dy,
          greaterThan(tester.getTopLeft(find.text('View event')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Add to calendar')).dy,
          greaterThan(tester.getTopLeft(find.text('Directions')).dy),
        );

        await tester.drag(find.text(firstRunTitle), const Offset(-420, 0));
        await tester.pump();
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 250));

        expect(find.text(firstRunTitle), findsNothing);
        expect(find.text(secondRunTitle), findsOneWidget);
      },
    );

    testWidgets(
      'event focus combines catching and review for an attended event',
      (tester) async {
        final now = DateTime.now();
        final user = buildUser();
        final attendedRun = buildEvent(
          id: 'attended-event',
          checkedInCount: 2,
          startTime: now.subtract(const Duration(hours: 4)),
          endTime: now.subtract(const Duration(hours: 2)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchAttendedEventsProvider(
                user.uid,
              ).overrideWithValue(AsyncData<List<Event>>([attendedRun])),
              watchReviewsByUserProvider(
                user.uid,
              ).overrideWithValue(const AsyncData<List<Review>>([])),
              exploreRecommendedEventsProvider(
                recommendationsQueryFor(user.uid, const []),
              ).overrideWithValue(noRecommendationCandidates),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: _DashboardFullTestShell(
                user: user,
                followedClubIds: const [],
                signedUpEvents: const [],
              ),
            ),
          ),
        );

        await _pumpDashboardUi(tester);

        expect(find.text('Event Focus'), findsOneWidget);
        expect(find.textContaining('After the event'), findsOneWidget);
        expect(find.text('Start catching'), findsOneWidget);
        expect(find.text('Write review'), findsOneWidget);
        expect(find.text('Review your event'), findsNothing);
      },
    );
  });
}

class _DashboardFullTestShell extends ConsumerWidget {
  const _DashboardFullTestShell({
    required this.user,
    required this.signedUpEvents,
    required this.followedClubIds,
  });

  final UserProfile user;
  final List<Event> signedUpEvents;
  final List<String> followedClubIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(dashboardNowProvider);
    final viewModel = ref.watch(
      dashboardFullViewModelProvider(
        signedUpEvents: signedUpEvents,
        user: user,
        uid: user.uid,
        followedClubIds: followedClubIds,
      ),
    );

    return DashboardHomeScreen(
      header: DashboardHomeHeaderModel.full(user: user, now: now),
      dashboardSliver: DashboardFullSliverBody(
        viewModel: viewModel,
        user: user,
      ),
    );
  }
}

final class _AnalyticsEventCall {
  const _AnalyticsEventCall(this.name, this.parameters);

  final String name;
  final Map<String, Object>? parameters;

  @override
  bool operator ==(Object other) {
    if (other is! _AnalyticsEventCall) return false;
    if (other.name != name) return false;
    final otherParameters = other.parameters;
    final theseParameters = parameters;
    if (identical(otherParameters, theseParameters)) return true;
    if (otherParameters == null || theseParameters == null) return false;
    if (otherParameters.length != theseParameters.length) return false;
    for (final entry in theseParameters.entries) {
      if (otherParameters[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    name,
    Object.hashAllUnordered([
      for (final entry
          in parameters?.entries ?? const <MapEntry<String, Object>>[])
        Object.hash(entry.key, entry.value),
    ]),
  );
}

final class _FakeAnalyticsReporter implements AnalyticsReporter {
  final events = <_AnalyticsEventCall>[];

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add(_AnalyticsEventCall(name, parameters));
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}

class _FakeEventCheckInLocationService implements EventCheckInLocationService {
  const _FakeEventCheckInLocationService();

  @override
  Future<EventCheckInLocation> getCurrentLocation() async {
    return const EventCheckInLocation(latitude: 19.07, longitude: 72.87);
  }
}

class _FakeEventSuccessRepository extends Fake
    implements EventSuccessRepository {
  @override
  Future<EventSuccessPlan?> fetchPlan(String eventId) async => null;
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
  ActivityNotificationType type = ActivityNotificationType.match,
  String title = "It's a catch",
  String body = 'You and Runner Two matched. Say hi!',
  String? clubId,
  String? postId,
  String? eventId,
  DateTime? createdAt,
  DateTime? readAt,
}) {
  return ActivityNotification(
    id: id,
    uid: uid,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt ?? DateTime(2026, 5, 16, 10),
    readAt: readAt,
    matchId: type == ActivityNotificationType.match ? 'match-1' : null,
    eventId: eventId,
    clubId: clubId,
    postId: postId,
  );
}

Future<void> _pumpDashboardUi(WidgetTester tester) async {
  await pumpFeatureUi(tester);
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
  List<Event> hostedEvents = const [],
  bool includeWeeklyActivity = true,
  AsyncValue<WeeklyActivitySnapshot>? weeklyActivity,
}) {
  final hostedClubs = hostedEvents.isEmpty
      ? const <Club>[]
      : [buildClub(id: hostedClubId, hostUserId: user.uid)];

  return [
    clubsRepositoryProvider.overrideWith(
      (ref) => club_test.FakeClubsRepository()
        ..clubsById['club-1'] = buildClub()
        ..clubsById[hostedClubId] = buildClub(
          id: hostedClubId,
          hostUserId: user.uid,
        ),
    ),
    watchClubsHostedByProvider(
      user.uid,
    ).overrideWithValue(AsyncData(hostedClubs)),
    watchClubsOwnedByProvider(
      user.uid,
    ).overrideWithValue(const AsyncData<List<Club>>([])),
    if (includeWeeklyActivity)
      weeklyActivityProvider.overrideWithValue(
        weeklyActivity ?? emptyWeeklyActivitySnapshot(),
      ),
    if (hostedEvents.isNotEmpty)
      watchEventsForClubProvider(
        hostedClubId,
      ).overrideWithValue(AsyncData<List<Event>>(hostedEvents)),
  ];
}
