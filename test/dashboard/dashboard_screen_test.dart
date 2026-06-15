import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_clubs_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_calendar_links.dart';
import 'package:catch_dating_app/events/presentation/event_check_in_location_service.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
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
import '../test_pump_helpers.dart';

DashboardRecommendationsQuery _recommendationsQueryFor(
  String uid,
  List<String> followedClubIds,
) => DashboardRecommendationsQuery(
  userId: uid,
  followedClubIds: followedClubIds,
);

const _noRecommendationCandidates =
    AsyncData<List<DashboardEventRecommendationCandidate>>([]);

AsyncData<WeeklyActivitySnapshot> _emptyWeeklyActivitySnapshot() {
  return AsyncData(
    WeeklyActivitySnapshot.permissionRequired(
      referenceDate: DateTime(2026, 5, 13),
      platformLabel: 'Apple Health',
    ),
  );
}

DashboardEventRecommendationCandidate _recommendationCandidate(
  Event event, {
  String clubName = 'Stride Social',
  String? clubLocation = 'mumbai',
}) => DashboardEventRecommendationCandidate(
  event: event,
  clubName: clubName,
  clubLocation: clubLocation,
);

ClubMembership _membership({required String clubId, String uid = 'runner-1'}) =>
    ClubMembership(
      id: clubMembershipId(clubId: clubId, uid: uid),
      clubId: clubId,
      uid: uid,
      role: ClubMembershipRole.member,
      status: ClubMembershipStatus.active,
      joinedAt: DateTime(2026),
    );

dynamic _membershipsOverride(UserProfile user, List<String> clubIds) =>
    watchActiveClubMembershipsForUserProvider(user.uid).overrideWith(
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
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

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
            _membershipsOverride(user, const []),
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

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
            _membershipsOverride(user, const []),
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

      expect(find.text('Unable to load your booked events.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text("Let's find your first event"), findsNothing);
    });

    testWidgets('shows the empty dashboard when there are no booked events', (
      tester,
    ) async {
      final user = buildUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            _membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
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

      expect(find.text("Let's find your first event"), findsOneWidget);
      expect(find.byType(DashboardFull), findsNothing);
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
            _membershipsOverride(user, const []),
            _activityNotificationsOverride(user),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
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

      expect(find.text("Let's find your first event"), findsOneWidget);
      expect(find.byType(DashboardFullSliverBody), findsNothing);
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
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            watchClubProvider(
              joinedClub.id,
            ).overrideWith((ref) => Stream.value(joinedClub)),
            _membershipsOverride(user, joinedClubIds),
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
      expect(find.text('${DashboardFull.greeting()}, Subrath'), findsOneWidget);
      expect(find.text('${DashboardFull.greeting()}, Manan'), findsNothing);
      expect(find.byType(TabBar), findsNothing);
      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('dashboard clubs rail renders joined clubs from club ids', (
      tester,
    ) async {
      final joinedClub = buildClub(name: 'Home Run Club');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchClubProvider(
              joinedClub.id,
            ).overrideWith((ref) => Stream.value(joinedClub)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: DashboardClubsRail(clubIds: ['club-1'])),
          ),
        ),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('Your clubs'), findsOneWidget);
      expect(find.text('Home Run Club'), findsOneWidget);
    });

    testWidgets('shows notification action with unread badge instead of tabs', (
      tester,
    ) async {
      final user = buildUser();

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
      expect(find.text("Let's find your first event"), findsOneWidget);
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

    testWidgets('notifications screen renders grouped notification rows', (
      tester,
    ) async {
      final now = DateTime.now();
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
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
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
      expect(find.text('YESTERDAY', findRichText: true), findsOneWidget);
      expect(find.text('THIS WEEK', findRichText: true), findsOneWidget);
      expect(find.text(today.title), findsOneWidget);
      expect(find.text(today.body), findsOneWidget);
      expect(find.text(yesterday.title), findsOneWidget);
      expect(find.text(thisWeek.title), findsOneWidget);
      expect(find.byType(NotificationRow), findsNWidgets(3));
      expect(find.text('Upcoming events'), findsNothing);
      expect(find.text('Recent updates'), findsNothing);
      expect(find.text('Catch'), findsNothing);
    });
  });

  group('DashboardFull', () {
    testWidgets('shows a loading card while attended events are loading', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncLoading<List<Event>>()),
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [buildEvent(bookedCount: 1)],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Loading your recent events...'), findsOneWidget);
    });

    testWidgets(
      'surfaces attended-events errors instead of hiding the section',
      (tester) async {
        final joinedClubIds = ['club-1'];
        final user = buildUser();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchAttendedEventsProvider(user.uid).overrideWithValue(
                AsyncError<List<Event>>(Exception('boom'), StackTrace.empty),
              ),
              dashboardRecommendedEventsProvider(
                _recommendationsQueryFor(user.uid, joinedClubIds),
              ).overrideWith(
                (ref) async => const <DashboardEventRecommendationCandidate>[],
              ),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: DashboardFull(
                user: user,
                followedClubIds: joinedClubIds,
                signedUpEvents: [buildEvent(bookedCount: 1)],
              ),
            ),
          ),
        );

        await tester.pump();

        // Errors now route through the canonical CatchInlineErrorState with
        // mapped copy + retry (ERROR-UI-002), not a fixed hidden message.
        expect(find.text('Dashboard unavailable'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
      },
    );

    testWidgets('shows a loading card while recommendations are loading', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(const AsyncData<List<Event>>([])),
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(
              const AsyncLoading<List<DashboardEventRecommendationCandidate>>(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [buildEvent(bookedCount: 1)],
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

      expect(find.text('Loading recommended events...'), findsOneWidget);
    });

    testWidgets(
      'surfaces recommendation errors instead of hiding the section',
      (tester) async {
        final joinedClubIds = ['club-1'];
        final user = buildUser();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchAttendedEventsProvider(
                user.uid,
              ).overrideWith((ref) => Stream.value(const [])),
              dashboardRecommendedEventsProvider(
                _recommendationsQueryFor(user.uid, joinedClubIds),
              ).overrideWithValue(
                AsyncError<List<DashboardEventRecommendationCandidate>>(
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
                signedUpEvents: [buildEvent(bookedCount: 1)],
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

        // Recommendations load failures now surface the canonical
        // CatchInlineErrorState with mapped copy + retry (ERROR-UI-002).
        expect(find.text('Dashboard unavailable'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
      },
    );

    testWidgets('renders active swipe and recommendations on the happy path', (
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
      final recommendedRun = buildEvent(
        id: 'recommended-event',
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
            watchAttendedEventsProvider(
              user.uid,
            ).overrideWithValue(AsyncData<List<Event>>([swipeRun])),
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(
              AsyncData<List<DashboardEventRecommendationCandidate>>([
                _recommendationCandidate(
                  recommendedRun,
                  clubName: 'Bandra Club',
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

      await tester.drag(
        find.byKey(DashboardFull.scrollViewKey),
        const Offset(0, -500),
      );
      await _pumpDashboardUi(tester);

      expect(find.text('Recommended for you'), findsOneWidget);
      expect(
        find.text(recommendedRun.title, skipOffstage: false),
        findsOneWidget,
      );
      // RecommendCard subtitle combines club + meeting point on one line.
      expect(
        find.text(
          'Bandra Club · Race Course Road main gate',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      // Activity summary and capacity stay visible in the ticket meta line.
      expect(
        find.text('12km · Moderate · 4 going · 8 left', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('₹150', skipOffstage: false), findsOneWidget);
      // The recommender reason rides as the ticket media label.
      expect(find.text('FITS YOUR PACE', skipOffstage: false), findsOneWidget);
    });

    testWidgets('shows connected weekly running activity from health data', (
      tester,
    ) async {
      final joinedClubIds = ['club-1'];
      final user = buildUser();
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
            weeklyActivityProvider.overrideWithValue(
              AsyncData(
                WeeklyActivitySnapshot.connected(
                  referenceDate: DateTime.now(),
                  platformLabel: 'Apple Health',
                  activities: [
                    PhysicalActivity(
                      stableId: 'health-event',
                      provider: PhysicalActivityProvider.appleHealth,
                      type: ActivityKind.running,
                      startTime: DateTime.now(),
                      endTime: DateTime.now().add(const Duration(hours: 1)),
                      distanceMeters: 6400,
                      sourceName: 'Apple Watch',
                    ),
                  ],
                ),
              ),
            ),
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            ..._dashboardHostOverrides(user, includeWeeklyActivity: false),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [nextEvent],
            ),
          ),
        ),
      );

      await _pumpDashboardUi(tester);

      expect(find.text('Your activity · this week'), findsOneWidget);
      expect(find.text('6.4'), findsOneWidget);
      expect(find.text('km · 60 min · 1 activity'), findsOneWidget);
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
              snapshot: WeeklyActivitySnapshot.permissionRequired(
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
        find.text('Connect Apple Health to include activity outside Catch.'),
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
      final user = buildUser(name: 'Manan Sethi', displayName: 'Subrath');
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
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
              user: user,
              followedClubIds: joinedClubIds,
              signedUpEvents: [nextEvent],
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
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, joinedClubIds),
            ).overrideWithValue(_noRecommendationCandidates),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
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
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
            eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
            eventSuccessRepositoryProvider.overrideWithValue(
              _FakeEventSuccessRepository(),
            ),
            uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
            eventCheckInLocationServiceProvider.overrideWithValue(
              const _FakeEventCheckInLocationService(),
            ),
            ..._dashboardHostOverrides(user),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: DashboardFull(
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
            dashboardRecommendedEventsProvider(
              _recommendationsQueryFor(user.uid, const []),
            ).overrideWithValue(_noRecommendationCandidates),
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
            home: DashboardFull(
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
              dashboardRecommendedEventsProvider(
                _recommendationsQueryFor(user.uid, const []),
              ).overrideWithValue(_noRecommendationCandidates),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: DashboardFull(
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
              dashboardRecommendedEventsProvider(
                _recommendationsQueryFor(user.uid, const []),
              ).overrideWithValue(_noRecommendationCandidates),
              ..._dashboardHostOverrides(user),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: DashboardFull(
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

  group('QuickActions', () {
    testWidgets('shows all primary dashboard actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: QuickActions()),
        ),
      );

      expect(find.text('Soon'), findsNothing);
      expect(find.text('Browse events'), findsNothing);
      expect(find.text('Map view'), findsNothing);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Saved events'), findsOneWidget);
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

      final calendarSize = tester.getSize(_quickActionSurface('Calendar'));
      final savedSize = tester.getSize(_quickActionSurface('Saved events'));

      expect(savedSize.height, calendarSize.height);
      expect(savedSize.width, calendarSize.width);
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
            path: Routes.calendarScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Calendar screen')),
          ),
          GoRoute(
            path: Routes.savedEventsScreen.path,
            builder: (_, _) =>
                const Scaffold(body: Text('Saved events screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Calendar'));
      await _pumpDashboardUi(tester);

      expect(find.text('Calendar screen'), findsOneWidget);

      router.go('/');
      await _pumpDashboardUi(tester);

      await tester.tap(find.text('Saved events'));
      await _pumpDashboardUi(tester);

      expect(find.text('Saved events screen'), findsOneWidget);
    });
  });
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
        weeklyActivity ?? _emptyWeeklyActivitySnapshot(),
      ),
    if (hostedEvents.isNotEmpty)
      watchEventsForClubProvider(
        hostedClubId,
      ).overrideWithValue(AsyncData<List<Event>>(hostedEvents)),
  ];
}
