import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/dashboard/data/dashboard_recommendations_repository.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../support/dashboard_test_helpers.dart';

PhysicalActivity _platformActivity({
  required String id,
  required DateTime startTime,
  required double distanceMeters,
}) {
  return PhysicalActivity(
    stableId: id,
    provider: PhysicalActivityProvider.appleHealth,
    type: ActivityKind.running,
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1)),
    distanceMeters: distanceMeters,
    sourceName: 'Apple Watch',
  );
}

void main() {
  group('dashboardHomeScreenStateProvider', () {
    test(
      'returns the signed-out empty state without notification chrome',
      () async {
        final container = ProviderContainer(
          overrides: [
            watchUserProfileProvider.overrideWithValue(
              const AsyncData<UserProfile?>(null),
            ),
          ],
        );
        addTearDown(container.dispose);

        final state = container.read(dashboardHomeScreenStateProvider);
        expect(state.status, DashboardHomeScreenStatus.empty);
        expect(state.notificationUid, isNull);
        expect(state.header.title, "Let's find your first event");
      },
    );

    test('surfaces membership failures with a typed retry target', () async {
      final user = buildUser();
      final container = ProviderContainer(
        overrides: [
          watchUserProfileProvider.overrideWithValue(AsyncData(user)),
          uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          watchActiveClubMembershipsForUserProvider(user.uid).overrideWithValue(
            const AsyncError<List<ClubMembership>>('clubs', StackTrace.empty),
          ),
          watchSignedUpEventsProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<Event>>([])),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardHomeScreenStateProvider);
      expect(state.status, DashboardHomeScreenStatus.error);
      expect(state.error?.retryTarget, DashboardHomeRetryTarget.memberships);
      expect(state.error?.uid, user.uid);
      expect(state.error?.fallbackMessage, 'Unable to load your clubs.');
    });

    test('normalizes provider loading waves into one loading state', () {
      final user = buildUser();
      final profileLoading = ProviderContainer(
        overrides: [
          watchUserProfileProvider.overrideWithValue(
            const AsyncLoading<UserProfile?>(),
          ),
        ],
      );
      final membershipsLoading = ProviderContainer(
        overrides: [
          watchUserProfileProvider.overrideWithValue(AsyncData(user)),
          uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          watchActiveClubMembershipsForUserProvider(
            user.uid,
          ).overrideWithValue(const AsyncLoading<List<ClubMembership>>()),
          watchSignedUpEventsProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<Event>>([])),
        ],
      );
      addTearDown(profileLoading.dispose);
      addTearDown(membershipsLoading.dispose);

      expect(
        profileLoading.read(dashboardHomeScreenStateProvider).status,
        DashboardHomeScreenStatus.loading,
      );
      expect(
        membershipsLoading.read(dashboardHomeScreenStateProvider).status,
        DashboardHomeScreenStatus.loading,
      );
    });

    test('returns signed-in idle as a full live-layer state', () {
      final user = buildUser();
      final container = ProviderContainer(
        overrides: [
          dashboardNowProvider.overrideWithValue(DateTime(2026, 5, 13, 8)),
          watchUserProfileProvider.overrideWithValue(AsyncData(user)),
          uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          watchActiveClubMembershipsForUserProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<ClubMembership>>([])),
          watchSignedUpEventsProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<Event>>([])),
          watchAttendedEventsProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<Event>>([])),
          weeklyActivityProvider.overrideWithValue(
            emptyWeeklyActivitySnapshot(),
          ),
          watchReviewsByUserProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<Review>>([])),
          dashboardRecommendedEventsProvider(
            recommendationsQueryFor(user.uid, const []),
          ).overrideWithValue(noRecommendationCandidates),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardHomeScreenStateProvider);
      expect(state.status, DashboardHomeScreenStatus.full);
      expect(state.notificationUid, user.uid);
      expect(
        dashboardHomeLiveStateFor(state, now: DateTime(2026, 5, 13, 8)),
        DashboardHomeLiveState.idle,
      );
    });

    test('returns full state with pinned header copy and followed clubs', () {
      final user = buildUser();
      final event = buildEvent(startTime: DateTime(2026, 5, 14, 8));
      final container = ProviderContainer(
        overrides: [
          dashboardNowProvider.overrideWithValue(DateTime(2026, 5, 13, 8)),
          watchUserProfileProvider.overrideWithValue(AsyncData(user)),
          uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          watchActiveClubMembershipsForUserProvider(user.uid).overrideWithValue(
            AsyncData<List<ClubMembership>>([
              membership(clubId: 'club-a', uid: user.uid),
            ]),
          ),
          watchSignedUpEventsProvider(
            user.uid,
          ).overrideWithValue(AsyncData<List<Event>>([event])),
          watchAttendedEventsProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<Event>>([])),
          weeklyActivityProvider.overrideWithValue(
            emptyWeeklyActivitySnapshot(),
          ),
          watchReviewsByUserProvider(
            user.uid,
          ).overrideWithValue(const AsyncData<List<Review>>([])),
          dashboardRecommendedEventsProvider(
            recommendationsQueryFor(user.uid, const ['club-a']),
          ).overrideWithValue(noRecommendationCandidates),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardHomeScreenStateProvider);
      expect(state.status, DashboardHomeScreenStatus.full);
      expect(state.header.title, 'Morning, Runner');
      expect(state.followedClubIds, ['club-a']);
      expect(state.viewModel?.nextEvent?.id, event.id);
    });
  });

  group('buildDashboardFullViewModel', () {
    test('selects the nearest upcoming event as nextEvent', () {
      final now = DateTime(2026, 4, 23, 9);
      final earlier = buildEvent(startTime: now.add(const Duration(hours: 2)));
      final later = buildEvent(
        id: 'later',
        startTime: now.add(const Duration(hours: 5)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: [later, earlier],
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync: noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.nextEvent?.id, earlier.id);
      expect(viewModel.upcomingEvents.map((event) => event.id), [
        earlier.id,
        later.id,
      ]);
    });

    test('filters past booked events out of upcomingEvents', () {
      final now = DateTime(2026, 4, 23, 9);
      final past = buildEvent(
        id: 'past',
        startTime: now.subtract(const Duration(hours: 2)),
      );
      final upcoming = buildEvent(
        id: 'upcoming',
        startTime: now.add(const Duration(hours: 2)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: [past, upcoming],
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync: noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.nextEvent?.id, 'upcoming');
      expect(viewModel.upcomingEvents.map((event) => event.id), ['upcoming']);
    });

    test('surfaces attended section errors and clears the swipe event', () {
      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        attendedEventsAsync: AsyncError<List<Event>>(
          Exception('boom'),
          StackTrace.empty,
        ),
        recommendedEventsAsync: noRecommendationCandidates,
      );

      expect(viewModel.attendedEventsSection.hasError, isTrue);
      expect(
        viewModel.attendedEventsSection.message,
        'Unable to load your recent events.',
      );
      expect(viewModel.activeSwipeEvent, isNull);
    });

    test('selects the most recent event with an open swipe window', () {
      final now = DateTime(2026, 4, 23, 20);
      final older = buildEvent(
        id: 'older',
        checkedInCount: 1,
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 6)),
      );
      final latest = buildEvent(
        id: 'latest',
        checkedInCount: 1,
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 2)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        attendedEventsAsync: AsyncData<List<Event>>([older, latest]),
        recommendedEventsAsync: noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.activeSwipeEvent?.id, latest.id);
    });

    test('uses Catch attended events as the weekly activity fallback', () {
      final now = DateTime(2026, 5, 13, 12);
      final attendedRun = buildEvent(
        id: 'catch-event',
        startTime: DateTime(2026, 5, 11, 6),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        attendedEventsAsync: AsyncData<List<Event>>([attendedRun]),
        weeklyActivityAsync: AsyncData(
          WeeklyActivitySnapshot.permissionRequired(
            referenceDate: now,
            platformLabel: 'Apple Health',
          ),
        ),
        recommendedEventsAsync: noRecommendationCandidates,
        now: now,
      );

      final snapshot = viewModel.weeklyActivitySection.data!;
      expect(snapshot.source, WeeklyActivitySource.catchFallback);
      expect(snapshot.canRequestPermission, isTrue);
      expect(snapshot.summary.totalDistanceKm, 5);
      expect(snapshot.summary.activityCount, 1);
    });

    test(
      'merges connected platform activity with non-overlapping Catch events',
      () {
        final now = DateTime(2026, 5, 13, 12);
        final catchEvent = buildEvent(
          id: 'catch-event',
          startTime: DateTime(2026, 5, 12, 7),
        );
        final platformActivity = _platformActivity(
          id: 'health-event',
          startTime: DateTime(2026, 5, 11, 7),
          distanceMeters: 3000,
        );

        final viewModel = buildDashboardFullViewModel(
          signedUpEvents: const [],
          attendedEventsAsync: AsyncData<List<Event>>([catchEvent]),
          weeklyActivityAsync: AsyncData(
            WeeklyActivitySnapshot.connected(
              referenceDate: now,
              platformLabel: 'Apple Health',
              activities: [platformActivity],
            ),
          ),
          recommendedEventsAsync: noRecommendationCandidates,
          now: now,
        );

        final snapshot = viewModel.weeklyActivitySection.data!;
        expect(snapshot.source, WeeklyActivitySource.mixed);
        expect(snapshot.summary.totalDistanceKm, 8);
        expect(snapshot.summary.activityCount, 2);
        expect(snapshot.activities.map((activity) => activity.stableId), [
          'health-event',
          'catch:catch-event',
        ]);
      },
    );

    test('does not double count overlapping platform and Catch activity', () {
      final now = DateTime(2026, 5, 13, 12);
      final catchEvent = buildEvent(
        id: 'catch-event',
        startTime: DateTime(2026, 5, 12, 7),
        endTime: DateTime(2026, 5, 12, 8),
      );
      final platformActivity = _platformActivity(
        id: 'health-event',
        startTime: DateTime(2026, 5, 12, 7, 10),
        distanceMeters: 5100,
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        attendedEventsAsync: AsyncData<List<Event>>([catchEvent]),
        weeklyActivityAsync: AsyncData(
          WeeklyActivitySnapshot.connected(
            referenceDate: now,
            platformLabel: 'Apple Health',
            activities: [platformActivity],
          ),
        ),
        recommendedEventsAsync: noRecommendationCandidates,
        now: now,
      );

      final snapshot = viewModel.weeklyActivitySection.data!;
      expect(snapshot.source, WeeklyActivitySource.healthPlatform);
      expect(snapshot.summary.totalDistanceMeters, 5100);
      expect(snapshot.summary.activityCount, 1);
      expect(snapshot.activities.map((activity) => activity.stableId), [
        'health-event',
      ]);
    });

    test('selects the latest attended event that has not been reviewed', () {
      final now = DateTime(2026, 4, 23, 20);
      final reviewedEvent = buildEvent(
        id: 'reviewed-event',
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 7)),
      );
      final pendingRun = buildEvent(
        id: 'pending-event',
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 3)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        attendedEventsAsync: AsyncData<List<Event>>([
          reviewedEvent,
          pendingRun,
        ]),
        reviewsByUserAsync: AsyncData<List<Review>>([
          buildReview(id: 'reviewed-event~runner-1', eventId: reviewedEvent.id),
        ]),
        recommendedEventsAsync: noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.pendingReviewEvent?.id, 'pending-event');
    });

    test('surfaces unread club post notifications as a home module', () {
      final now = DateTime(2026, 5, 18, 10);
      final posts = clubPostNotificationsFromActivity([
        _activityNotification(
          id: 'old-post',
          type: ActivityNotificationType.clubUpdate,
          postId: 'post-old',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        _activityNotification(
          id: 'new-post',
          type: ActivityNotificationType.clubUpdate,
          postId: 'post-new',
          createdAt: now.subtract(const Duration(minutes: 20)),
        ),
        _activityNotification(
          id: 'read-post',
          type: ActivityNotificationType.clubUpdate,
          postId: 'post-read',
          readAt: now,
        ),
        _activityNotification(
          id: 'club-without-post',
          type: ActivityNotificationType.clubUpdate,
        ),
        _activityNotification(id: 'match'),
      ]);

      expect(posts.map((notification) => notification.id), [
        'new-post',
        'old-post',
      ]);

      final user = buildUser();
      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        uid: user.uid,
        viewer: user,
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync: noRecommendationCandidates,
        clubPostNotifications: posts,
        now: now,
      );
      final state = DashboardHomeScreenState.full(
        header: DashboardHomeHeaderModel.full(user: user, now: now),
        user: user,
        viewModel: viewModel,
        followedClubIds: const [],
      );

      expect(dashboardHomeModuleImpressionsFor(state), [
        'idle_cta',
        'club_posts',
      ]);
    });

    test('surfaces recommendation loading state', () {
      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync:
            const AsyncLoading<List<DashboardEventRecommendationCandidate>>(),
      );

      expect(viewModel.recommendationsSection.isLoading, isTrue);
      expect(
        viewModel.recommendationsSection.message,
        'Loading recommended events...',
      );
    });

    test('removes already booked events from recommendations', () {
      final booked = buildEvent(id: 'booked');
      final unbooked = buildEvent(id: 'recommended');

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: [booked],
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync:
            AsyncData<List<DashboardEventRecommendationCandidate>>([
              recommendationCandidate(booked),
              recommendationCandidate(unbooked),
            ]),
      );

      expect(
        viewModel.recommendationsSection.data?.map((item) => item.event.id),
        ['recommended'],
      );
    });

    test('ranks recommendations by preferences, proximity, and event time', () {
      final now = DateTime(2026, 4, 23, 9);
      final viewer = buildUser().copyWith(
        city: 'in-mh-mumbai',
        latitude: 19.076,
        longitude: 72.8777,
        activityPreferences: const ActivityPreferences(
          running: RunningPreferences(
            paceMinSecsPerKm: 330,
            paceMaxSecsPerKm: 390,
            preferredDistances: [PreferredDistance.tenK],
          ),
        ),
      );
      final morningHistory = buildEvent(
        id: 'morning-history',
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
      );
      final strongMatch = buildEvent(
        id: 'strong-match',
        distanceKm: 10,
        pace: PaceLevel.moderate,
        startTime: DateTime(2026, 4, 24, 7),
        startingPointLat: 19.08,
        startingPointLng: 72.88,
      );
      final weakMatch = buildEvent(
        id: 'weak-match',
        pace: PaceLevel.competitive,
        startTime: DateTime(2026, 4, 24, 19),
        startingPointLat: 19.30,
        startingPointLng: 72.90,
      );

      final recommendations = rankDashboardEventRecommendations(
        candidates: [
          recommendationCandidate(
            weakMatch,
            clubName: 'Late Miles',
            clubLocation: 'delhi',
          ),
          recommendationCandidate(strongMatch, clubName: 'Bandra Club'),
        ],
        signedUpEventIds: const {},
        attendedEvents: [morningHistory],
        signedUpEvents: const [],
        viewer: viewer,
        now: now,
      );

      expect(recommendations.map((item) => item.event.id), [
        'strong-match',
        'weak-match',
      ]);
      expect(recommendations.first.clubName, 'Bandra Club');
      expect(
        recommendations.first.reasonLabel,
        'Matches your 10 km preference',
      );
    });

    test('filters past, cancelled, full, booked, and ineligible events', () {
      final now = DateTime(2026, 4, 23, 9);
      final viewer = buildUser();
      final eligible = buildEvent(
        id: 'eligible',
        startTime: now.add(const Duration(hours: 3)),
      );
      final booked = buildEvent(
        id: 'booked',
        startTime: now.add(const Duration(hours: 4)),
      );
      final cancelled = buildEvent(
        id: 'cancelled',
        startTime: now.add(const Duration(hours: 5)),
        status: EventLifecycleStatus.cancelled,
      );
      final full = buildEvent(
        id: 'full',
        startTime: now.add(const Duration(hours: 6)),
        capacityLimit: 2,
        bookedCount: 2,
      );
      final ineligible = buildEvent(
        id: 'ineligible',
        startTime: now.add(const Duration(hours: 7)),
        constraints: const EventConstraints(minAge: 45),
      );
      final past = buildEvent(
        id: 'past',
        startTime: now.subtract(const Duration(hours: 1)),
      );

      final recommendations = rankDashboardEventRecommendations(
        candidates: [
          eligible,
          booked,
          cancelled,
          full,
          ineligible,
          past,
        ].map(recommendationCandidate).toList(),
        signedUpEventIds: {'booked'},
        attendedEvents: const [],
        signedUpEvents: const [],
        viewer: viewer,
        now: now,
      );

      expect(recommendations.map((item) => item.event.id), ['eligible']);
    });

    test('selects self check-in during the event check-in window', () {
      final now = DateTime(2026, 4, 23, 8, 55);
      final event = buildEvent(
        id: 'check-in-event',
        bookedCount: 1,
        startTime: DateTime(2026, 4, 23, 9),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: [event],
        uid: 'runner-1',
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync: noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.arrivalAction?.kind, EventArrivalActionKind.selfCheckIn);
      expect(viewModel.arrivalAction?.event.id, 'check-in-event');
    });
  });
}

ActivityNotification _activityNotification({
  required String id,
  ActivityNotificationType type = ActivityNotificationType.match,
  String? postId,
  DateTime? createdAt,
  DateTime? readAt,
}) {
  return ActivityNotification(
    id: id,
    uid: 'runner-1',
    type: type,
    title: 'Club update',
    body: 'Meet ten minutes early.',
    clubId: type == ActivityNotificationType.clubUpdate ? 'club-1' : null,
    postId: postId,
    createdAt: createdAt ?? DateTime(2026, 5, 18, 9),
    readAt: readAt,
  );
}
