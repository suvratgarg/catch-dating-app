import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_full_view_model.g.dart';

enum DashboardSectionStatus { loading, error, data }

class DashboardSectionModel<T> {
  const DashboardSectionModel._({
    required this.status,
    this.message,
    this.data,
    this.error,
  });

  const DashboardSectionModel.loading(String message)
    : this._(status: DashboardSectionStatus.loading, message: message);

  const DashboardSectionModel.error(String message, {Object? error})
    : this._(
        status: DashboardSectionStatus.error,
        message: message,
        error: error,
      );

  const DashboardSectionModel.data(T data)
    : this._(status: DashboardSectionStatus.data, data: data);

  final DashboardSectionStatus status;
  final String? message;
  final T? data;

  /// The original error for error-status sections, so the UI can render mapped
  /// copy + retry via the canonical error primitives instead of a fixed string.
  final Object? error;

  bool get isLoading => status == DashboardSectionStatus.loading;
  bool get hasError => status == DashboardSectionStatus.error;
}

class DashboardFullViewModel {
  const DashboardFullViewModel({
    required this.upcomingEvents,
    required this.nextEvent,
    required this.arrivalAction,
    required this.activeSwipeEvent,
    required this.pendingReviewEvent,
    required this.attendedEventsSection,
    required this.weeklyActivitySection,
    required this.recommendationsSection,
  });

  final List<Event> upcomingEvents;
  final Event? nextEvent;
  final EventArrivalAction? arrivalAction;
  final Event? activeSwipeEvent;
  final Event? pendingReviewEvent;
  final DashboardSectionModel<List<Event>> attendedEventsSection;
  final DashboardSectionModel<WeeklyActivitySnapshot> weeklyActivitySection;
  final DashboardSectionModel<List<DashboardEventRecommendation>>
  recommendationsSection;
}

class DashboardEventRecommendation {
  const DashboardEventRecommendation({
    required this.event,
    required this.clubName,
    required this.reasonLabel,
    required this.score,
  });

  final Event event;
  final String clubName;
  final String reasonLabel;
  final double score;
}

DashboardFullViewModel buildDashboardFullViewModel({
  required List<Event> signedUpEvents,
  String? uid,
  UserProfile? viewer,
  required AsyncValue<List<Event>> attendedEventsAsync,
  required AsyncValue<List<DashboardEventRecommendationCandidate>>
  recommendedEventsAsync,
  AsyncValue<WeeklyActivitySnapshot>? weeklyActivityAsync,
  AsyncValue<List<Review>> reviewsByUserAsync = const AsyncData<List<Review>>(
    [],
  ),
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();

  final upcomingEvents =
      signedUpEvents
          .where((event) => event.startTime.isAfter(effectiveNow))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  final nextEvent = upcomingEvents.firstOrNull;

  final attendedEventsSection = attendedEventsAsync.when(
    loading: () => const DashboardSectionModel<List<Event>>.loading(
      'Loading your recent events...',
    ),
    error: (error, stackTrace) => DashboardSectionModel<List<Event>>.error(
      'Unable to load your recent events.',
      error: error,
    ),
    data: DashboardSectionModel<List<Event>>.data,
  );
  final weeklyActivitySection = _buildWeeklyActivitySection(
    attendedEventsAsync: attendedEventsAsync,
    weeklyActivityAsync: weeklyActivityAsync,
    referenceDate: effectiveNow,
  );

  final signedUpEventIds = signedUpEvents.map((event) => event.id).toSet();
  final recommendationsSection = recommendedEventsAsync.when(
    loading: () =>
        const DashboardSectionModel<List<DashboardEventRecommendation>>.loading(
          'Loading recommended events...',
        ),
    error: (error, stackTrace) =>
        DashboardSectionModel<List<DashboardEventRecommendation>>.error(
          'Unable to load recommended events.',
          error: error,
        ),
    data: (candidates) =>
        DashboardSectionModel<List<DashboardEventRecommendation>>.data(
          rankDashboardEventRecommendations(
            candidates: candidates,
            signedUpEventIds: signedUpEventIds,
            attendedEvents:
                attendedEventsAsync.asData?.value ?? const <Event>[],
            signedUpEvents: signedUpEvents,
            viewer: viewer,
            now: effectiveNow,
          ),
        ),
  );

  final activeSwipeEvent = attendedEventsSection.data == null
      ? null
      : latestEventWithOpenSwipeWindow(
          attendedEventsSection.data!,
          now: effectiveNow,
        );
  final reviewedEventIds =
      reviewsByUserAsync.asData?.value
          .map((review) => review.eventId)
          .whereType<String>()
          .toSet() ??
      const <String>{};
  final pendingReviewEvent = attendedEventsSection.data == null
      ? null
      : _latestUnreviewedAttendedEvent(
          attendedEventsSection.data!,
          reviewedEventIds: reviewedEventIds,
        );
  final arrivalAction = uid == null
      ? null
      : selectEventArrivalAction(
          signedUpEvents: signedUpEvents,
          hostedEvents: const [],
          uid: uid,
          now: effectiveNow,
        );

  return DashboardFullViewModel(
    upcomingEvents: upcomingEvents,
    nextEvent: nextEvent,
    arrivalAction: arrivalAction,
    activeSwipeEvent: activeSwipeEvent,
    pendingReviewEvent: pendingReviewEvent,
    attendedEventsSection: attendedEventsSection,
    weeklyActivitySection: weeklyActivitySection,
    recommendationsSection: recommendationsSection,
  );
}

DashboardSectionModel<WeeklyActivitySnapshot> _buildWeeklyActivitySection({
  required AsyncValue<List<Event>> attendedEventsAsync,
  required AsyncValue<WeeklyActivitySnapshot>? weeklyActivityAsync,
  required DateTime referenceDate,
}) {
  if (attendedEventsAsync.isLoading) {
    return const DashboardSectionModel<WeeklyActivitySnapshot>.loading(
      'Loading your recent events...',
    );
  }
  if (weeklyActivityAsync?.isLoading ?? false) {
    return const DashboardSectionModel<WeeklyActivitySnapshot>.loading(
      'Loading your weekly activity...',
    );
  }

  final attendedEvents = attendedEventsAsync.asData?.value;
  final platformSnapshot = weeklyActivityAsync?.asData?.value;
  if (attendedEventsAsync.hasError &&
      platformSnapshot?.hasPlatformConnection != true) {
    return DashboardSectionModel<WeeklyActivitySnapshot>.error(
      'Unable to load your recent events.',
      error: attendedEventsAsync.error,
    );
  }

  if (attendedEvents != null || platformSnapshot != null) {
    return DashboardSectionModel<WeeklyActivitySnapshot>.data(
      buildDashboardWeeklyActivitySnapshot(
        attendedEvents: attendedEvents ?? const <Event>[],
        platformSnapshot:
            platformSnapshot ??
            WeeklyActivitySnapshot.unsupported(referenceDate: referenceDate),
        referenceDate: referenceDate,
      ),
    );
  }

  return DashboardSectionModel<WeeklyActivitySnapshot>.data(
    WeeklyActivitySnapshot.unsupported(referenceDate: referenceDate),
  );
}

WeeklyActivitySnapshot buildDashboardWeeklyActivitySnapshot({
  required List<Event> attendedEvents,
  required WeeklyActivitySnapshot platformSnapshot,
  required DateTime referenceDate,
}) {
  final catchActivities = attendedEvents
      .map(_activityFromCatchEvent)
      .toList(growable: false);

  if (!platformSnapshot.hasPlatformConnection) {
    final catchSummary = WeeklyActivitySummary.fromActivities(
      catchActivities,
      referenceDate: referenceDate,
      refreshedAt: platformSnapshot.summary.refreshedAt,
    );
    if (!catchSummary.hasEvents) {
      return platformSnapshot.copyWith(
        summary: catchSummary,
        activities: const [],
        source: WeeklyActivitySource.none,
      );
    }
    return platformSnapshot.copyWith(
      summary: catchSummary,
      activities: catchActivities,
      source: WeeklyActivitySource.catchFallback,
      message: 'Catch check-ins only.',
    );
  }

  final platformActivities = platformSnapshot.activities;
  final catchOnlyActivities = catchActivities
      .where(
        (activity) => !_overlapsPlatformActivity(activity, platformActivities),
      )
      .toList(growable: false);
  final mergedActivities = [...platformActivities, ...catchOnlyActivities];
  final summary = WeeklyActivitySummary.fromActivities(
    mergedActivities,
    referenceDate: referenceDate,
    refreshedAt: platformSnapshot.summary.refreshedAt,
  );

  final source = _weeklyActivitySource(
    platformActivities: platformActivities,
    catchActivities: catchOnlyActivities,
    summary: summary,
  );

  return platformSnapshot.copyWith(
    summary: summary,
    activities: mergedActivities,
    source: source,
    clearMessage: source != WeeklyActivitySource.catchFallback,
    message: source == WeeklyActivitySource.catchFallback
        ? 'Catch check-ins only.'
        : null,
  );
}

PhysicalActivity _activityFromCatchEvent(Event event) {
  final activityKind = event.eventFormat.healthActivityKind;
  return PhysicalActivity(
    stableId: 'catch:${event.id}',
    provider: PhysicalActivityProvider.catchAttendance,
    type: activityKind,
    startTime: event.startTime,
    endTime: event.endTime,
    distanceMeters: activityKind.isDistanceBased
        ? event.distanceKm * 1000
        : null,
    sourceName: 'Catch',
    matchedCatchEventId: event.id,
  );
}

bool _overlapsPlatformActivity(
  PhysicalActivity catchActivity,
  List<PhysicalActivity> platformActivities,
) {
  final matchWindowStart = catchActivity.startTime.subtract(
    const Duration(minutes: 30),
  );
  final matchWindowEnd = catchActivity.endTime.add(const Duration(minutes: 30));
  return platformActivities.any(
    (activity) => activity.overlaps(matchWindowStart, matchWindowEnd),
  );
}

WeeklyActivitySource _weeklyActivitySource({
  required List<PhysicalActivity> platformActivities,
  required List<PhysicalActivity> catchActivities,
  required WeeklyActivitySummary summary,
}) {
  if (!summary.hasEvents) return WeeklyActivitySource.none;
  if (platformActivities.isNotEmpty && catchActivities.isNotEmpty) {
    return WeeklyActivitySource.mixed;
  }
  if (platformActivities.isNotEmpty) {
    return WeeklyActivitySource.healthPlatform;
  }
  return WeeklyActivitySource.catchFallback;
}

Event? _latestUnreviewedAttendedEvent(
  List<Event> attendedEvents, {
  required Set<String> reviewedEventIds,
}) {
  final unreviewedEvents =
      attendedEvents
          .where((event) => !reviewedEventIds.contains(event.id))
          .toList()
        ..sort((a, b) => b.endTime.compareTo(a.endTime));
  return unreviewedEvents.firstOrNull;
}

List<DashboardEventRecommendation> rankDashboardEventRecommendations({
  required List<DashboardEventRecommendationCandidate> candidates,
  required Set<String> signedUpEventIds,
  required List<Event> attendedEvents,
  required List<Event> signedUpEvents,
  required DateTime now,
  UserProfile? viewer,
  int limit = 10,
}) {
  final timePreference = _timePreferenceFromEvents(
    attendedEvents: attendedEvents,
    signedUpEvents: signedUpEvents,
    now: now,
  );

  final recommendations = <DashboardEventRecommendation>[];
  for (final candidate in candidates) {
    final event = candidate.event;
    if (signedUpEventIds.contains(event.id) ||
        event.isCancelled ||
        !event.startTime.isAfter(now) ||
        event.isFull) {
      continue;
    }
    if (viewer != null && !_isEligibleForRecommendation(event, viewer)) {
      continue;
    }

    final scored = _scoreRecommendation(
      candidate: candidate,
      viewer: viewer,
      timePreference: timePreference,
      now: now,
    );
    recommendations.add(scored);
  }

  recommendations.sort((a, b) {
    final scoreOrder = b.score.compareTo(a.score);
    if (scoreOrder != 0) return scoreOrder;
    return a.event.startTime.compareTo(b.event.startTime);
  });
  return recommendations.take(limit).toList(growable: false);
}

bool _isEligibleForRecommendation(Event event, UserProfile viewer) {
  if (viewer.age < event.constraints.minAge ||
      viewer.age > event.constraints.maxAge) {
    return false;
  }
  final genderCap = event.constraints.maxForGender(viewer.gender);
  if (genderCap != null &&
      (event.genderCounts[viewer.gender.name] ?? 0) >= genderCap) {
    return false;
  }
  return true;
}

DashboardEventRecommendation _scoreRecommendation({
  required DashboardEventRecommendationCandidate candidate,
  required UserProfile? viewer,
  required _EventTimeBucket? timePreference,
  required DateTime now,
}) {
  final event = candidate.event;
  var score = 0.0;
  var reason = 'From your clubs';

  final distanceReason = _distancePreferenceReason(viewer, event);
  if (distanceReason != null) {
    score += 28;
    reason = distanceReason;
  } else if (_hasNearbyPreferredDistance(viewer, event)) {
    score += 12;
  }

  final paceScore = _paceFitScore(viewer, event);
  score += paceScore;
  if (reason == 'From your clubs' && paceScore >= 18) {
    reason = 'Fits your pace';
  }

  final eventTimeBucket = _EventTimeBucket.fromHour(event.startTime.hour);
  if (timePreference != null && eventTimeBucket == timePreference) {
    score += 18;
    if (reason == 'From your clubs') {
      reason = '${timePreference.label} event pattern';
    }
  }

  final proximityScore = _proximityScore(viewer, event);
  score += proximityScore;
  if (reason == 'From your clubs' && proximityScore >= 14) {
    reason = 'Near you';
  }

  if (_isSameCity(viewer, candidate.clubLocation)) {
    score += 10;
  }

  score += _startTimeScore(event, now);
  score += event.spotsRemaining >= 5 ? 5 : 2;

  return DashboardEventRecommendation(
    event: event,
    clubName: candidate.clubName,
    reasonLabel: reason,
    score: score,
  );
}

String? _distancePreferenceReason(UserProfile? viewer, Event event) {
  final preferredDistances = viewer?.preferredDistances ?? const [];
  for (final preferred in preferredDistances) {
    if ((event.distanceKm - preferred.targetKm).abs() <= 0.75) {
      return 'Matches your ${preferred.label} preference';
    }
  }
  return null;
}

bool _hasNearbyPreferredDistance(UserProfile? viewer, Event event) {
  final preferredDistances = viewer?.preferredDistances ?? const [];
  return preferredDistances.any(
    (preferred) => (event.distanceKm - preferred.targetKm).abs() <= 2,
  );
}

double _paceFitScore(UserProfile? viewer, Event event) {
  if (viewer == null) return 0;
  final eventPace = event.pace.secondsPerKm;
  if (eventPace >= viewer.paceMinSecsPerKm &&
      eventPace <= viewer.paceMaxSecsPerKm) {
    return 18;
  }
  final minDelta = (eventPace - viewer.paceMinSecsPerKm).abs();
  final maxDelta = (eventPace - viewer.paceMaxSecsPerKm).abs();
  return minDelta < 45 || maxDelta < 45 ? 8 : 0;
}

double _proximityScore(UserProfile? viewer, Event event) {
  final userLocation = LocationCoordinate.fromNullable(
    latitude: viewer?.latitude,
    longitude: viewer?.longitude,
  );
  final eventLocation = LocationCoordinate.fromNullable(
    latitude: event.effectiveStartingPointLat,
    longitude: event.effectiveStartingPointLng,
  );
  if (userLocation == null || eventLocation == null) return 0;

  final distanceKm = userLocation.distanceTo(eventLocation) / 1000;
  if (distanceKm <= 3) return 18;
  if (distanceKm <= 8) return 12;
  if (distanceKm <= 15) return 6;
  return 0;
}

bool _isSameCity(UserProfile? viewer, String? clubLocation) {
  final userCity = viewer?.city?.trim().toLowerCase();
  final location = clubLocation?.trim().toLowerCase();
  return userCity != null &&
      userCity.isNotEmpty &&
      location != null &&
      location.isNotEmpty &&
      userCity == location;
}

double _startTimeScore(Event event, DateTime now) {
  final daysAway = event.startTime.difference(now).inDays;
  if (daysAway <= 7) return 8;
  if (daysAway <= 14) return 5;
  if (daysAway <= 30) return 2;
  return 0;
}

_EventTimeBucket? _timePreferenceFromEvents({
  required List<Event> attendedEvents,
  required List<Event> signedUpEvents,
  required DateTime now,
}) {
  final counts = <_EventTimeBucket, int>{};
  void addRun(Event event, int weight) {
    if (event.startTime.isAfter(now)) return;
    final bucket = _EventTimeBucket.fromHour(event.startTime.hour);
    counts[bucket] = (counts[bucket] ?? 0) + weight;
  }

  for (final event in attendedEvents) {
    addRun(event, 2);
  }
  for (final event in signedUpEvents) {
    addRun(event, 1);
  }
  if (counts.isEmpty) return null;

  final ranked = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return ranked.first.value > 1 ? ranked.first.key : null;
}

enum _EventTimeBucket {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening');

  const _EventTimeBucket(this.label);

  final String label;

  factory _EventTimeBucket.fromHour(int hour) {
    if (hour < 12) return _EventTimeBucket.morning;
    if (hour < 17) return _EventTimeBucket.afternoon;
    return _EventTimeBucket.evening;
  }
}

extension on PreferredDistance {
  double get targetKm => switch (this) {
    PreferredDistance.fiveK => 5,
    PreferredDistance.tenK => 10,
    PreferredDistance.halfMarathon => 21,
    PreferredDistance.marathon => 42,
  };
}

extension on PaceLevel {
  int get secondsPerKm => switch (this) {
    PaceLevel.easy => 420,
    PaceLevel.moderate => 360,
    PaceLevel.fast => 300,
    PaceLevel.competitive => 255,
  };
}

/// Combines signed-up events, attended events, and recommended events into a single
/// [DashboardFullViewModel] for the dashboard screen.
@riverpod
DashboardFullViewModel dashboardFullViewModel(
  Ref ref, {
  required List<Event> signedUpEvents,
  required UserProfile user,
  required String uid,
  required List<String> followedClubIds,
}) {
  return buildDashboardFullViewModel(
    signedUpEvents: signedUpEvents,
    uid: uid,
    viewer: user,
    attendedEventsAsync: ref.watch(watchAttendedEventsProvider(uid)),
    weeklyActivityAsync: ref.watch(weeklyActivityProvider),
    reviewsByUserAsync: ref.watch(watchReviewsByUserProvider(uid)),
    recommendedEventsAsync: ref.watch(
      dashboardRecommendedEventsProvider(
        DashboardRecommendationsQuery(
          userId: uid,
          followedClubIds: followedClubIds,
        ),
      ),
    ),
  );
}
