import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/hosts/domain/host_attendance_window.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

const _noRecommendationCandidates =
    AsyncData<List<DashboardEventRecommendationCandidate>>([]);

DashboardEventRecommendationCandidate _recommendationCandidate(
  Event event, {
  String clubName = 'Stride Social',
  String? clubLocation = 'mumbai',
}) => DashboardEventRecommendationCandidate(
  event: event,
  clubName: clubName,
  clubLocation: clubLocation,
);

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
        recommendedEventsAsync: _noRecommendationCandidates,
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
        recommendedEventsAsync: _noRecommendationCandidates,
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
        recommendedEventsAsync: _noRecommendationCandidates,
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
        recommendedEventsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.activeSwipeEvent?.id, latest.id);
    });

    test('uses Catch attended events as the weekly activity fallback', () {
      final now = DateTime(2026, 5, 13, 12);
      final attendedRun = buildEvent(
        id: 'catch-event',
        startTime: DateTime(2026, 5, 11, 6),
        distanceKm: 5,
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
        recommendedEventsAsync: _noRecommendationCandidates,
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
          distanceKm: 5,
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
          recommendedEventsAsync: _noRecommendationCandidates,
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
        distanceKm: 5,
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
        recommendedEventsAsync: _noRecommendationCandidates,
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
        recommendedEventsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.pendingReviewEvent?.id, 'pending-event');
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
              _recommendationCandidate(booked),
              _recommendationCandidate(unbooked),
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
        city: 'mumbai',
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
        distanceKm: 5,
        pace: PaceLevel.competitive,
        startTime: DateTime(2026, 4, 24, 19),
        startingPointLat: 19.30,
        startingPointLng: 72.90,
      );

      final recommendations = rankDashboardEventRecommendations(
        candidates: [
          _recommendationCandidate(
            weakMatch,
            clubName: 'Late Miles',
            clubLocation: 'delhi',
          ),
          _recommendationCandidate(strongMatch, clubName: 'Bandra Club'),
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
        ].map(_recommendationCandidate).toList(),
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
        recommendedEventsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.arrivalAction?.kind, EventArrivalActionKind.selfCheckIn);
      expect(viewModel.arrivalAction?.event.id, 'check-in-event');
    });

    test('exposes open host attendance in host tools', () {
      final now = DateTime(2026, 4, 23, 9, 5);
      final hostedRun = buildEvent(
        id: 'hosted-event',
        startTime: DateTime(2026, 4, 23, 9),
        endTime: DateTime(2026, 4, 23, 10),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        uid: 'host-1',
        hostedEvents: [hostedRun],
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.arrivalAction, isNull);
      expect(viewModel.hostEventTools.single.event.id, 'hosted-event');
      expect(
        viewModel.hostEventTools.single.attendanceState,
        HostEventAttendanceState.open,
      );
    });

    test('keeps past hosted events with attendance-open events first', () {
      final now = DateTime(2026, 4, 23, 9);
      final recentlyEnded = buildEvent(
        id: 'recently-ended-hosted',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );
      final old = buildEvent(
        id: 'old-hosted',
        startTime: now.subtract(const Duration(hours: 10)),
        endTime: now.subtract(const Duration(hours: 9)),
      );
      final later = buildEvent(
        id: 'later-hosted',
        startTime: now.add(const Duration(hours: 4)),
      );
      final sooner = buildEvent(
        id: 'sooner-hosted',
        startTime: now.add(const Duration(hours: 2)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpEvents: const [],
        uid: 'host-1',
        hostedEvents: [old, later, recentlyEnded, sooner],
        attendedEventsAsync: const AsyncData<List<Event>>([]),
        recommendedEventsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.hostEventTools.map((tool) => tool.event.id), [
        'recently-ended-hosted',
        'sooner-hosted',
        'later-hosted',
        'old-hosted',
      ]);
      expect(viewModel.hostEventTools.map((tool) => tool.attendanceState), [
        HostEventAttendanceState.open,
        HostEventAttendanceState.opensLater,
        HostEventAttendanceState.opensLater,
        HostEventAttendanceState.closed,
      ]);
    });
  });
}
