import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
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
  });

  const DashboardSectionModel.loading(String message)
    : this._(status: DashboardSectionStatus.loading, message: message);

  const DashboardSectionModel.error(String message)
    : this._(status: DashboardSectionStatus.error, message: message);

  const DashboardSectionModel.data(T data)
    : this._(status: DashboardSectionStatus.data, data: data);

  final DashboardSectionStatus status;
  final String? message;
  final T? data;

  bool get isLoading => status == DashboardSectionStatus.loading;
  bool get hasError => status == DashboardSectionStatus.error;
}

class DashboardFullViewModel {
  const DashboardFullViewModel({
    required this.upcomingRuns,
    required this.nextRun,
    required this.arrivalAction,
    required this.activeSwipeRun,
    required this.pendingReviewRun,
    required this.hostRunTools,
    required this.attendedRunsSection,
    required this.weeklyActivitySection,
    required this.recommendationsSection,
  });

  final List<Run> upcomingRuns;
  final Run? nextRun;
  final RunArrivalAction? arrivalAction;
  final Run? activeSwipeRun;
  final Run? pendingReviewRun;
  final List<DashboardHostRunTool> hostRunTools;
  final DashboardSectionModel<List<Run>> attendedRunsSection;
  final DashboardSectionModel<WeeklyRunningActivitySnapshot>
  weeklyActivitySection;
  final DashboardSectionModel<List<DashboardRunRecommendation>>
  recommendationsSection;
}

enum DashboardHostAttendanceState { open, opensLater, closed }

class DashboardHostRunTool {
  const DashboardHostRunTool({
    required this.run,
    required this.attendanceState,
  });

  final Run run;
  final DashboardHostAttendanceState attendanceState;

  bool get canTakeAttendance =>
      attendanceState == DashboardHostAttendanceState.open;
}

class DashboardRunRecommendation {
  const DashboardRunRecommendation({
    required this.run,
    required this.clubName,
    required this.reasonLabel,
    required this.score,
  });

  final Run run;
  final String clubName;
  final String reasonLabel;
  final double score;
}

DashboardFullViewModel buildDashboardFullViewModel({
  required List<Run> signedUpRuns,
  String? uid,
  UserProfile? viewer,
  List<Run> hostedRuns = const [],
  required AsyncValue<List<Run>> attendedRunsAsync,
  required AsyncValue<List<DashboardRunRecommendationCandidate>>
  recommendedRunsAsync,
  AsyncValue<WeeklyRunningActivitySnapshot>? weeklyActivityAsync,
  AsyncValue<List<Review>> reviewsByUserAsync = const AsyncData<List<Review>>(
    [],
  ),
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();

  final upcomingRuns =
      signedUpRuns.where((run) => run.startTime.isAfter(effectiveNow)).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final hostRunTools = _buildHostRunTools(hostedRuns, now: effectiveNow);

  final nextRun = upcomingRuns.firstOrNull;

  final attendedRunsSection = attendedRunsAsync.when(
    loading: () => const DashboardSectionModel<List<Run>>.loading(
      'Loading your recent runs...',
    ),
    error: (error, stackTrace) => const DashboardSectionModel<List<Run>>.error(
      'Unable to load your recent runs.',
    ),
    data: DashboardSectionModel<List<Run>>.data,
  );
  final weeklyActivitySection = _buildWeeklyActivitySection(
    attendedRunsAsync: attendedRunsAsync,
    weeklyActivityAsync: weeklyActivityAsync,
    referenceDate: effectiveNow,
  );

  final signedUpRunIds = signedUpRuns.map((run) => run.id).toSet();
  final recommendationsSection = recommendedRunsAsync.when(
    loading: () =>
        const DashboardSectionModel<List<DashboardRunRecommendation>>.loading(
          'Loading recommended runs...',
        ),
    error: (error, stackTrace) =>
        const DashboardSectionModel<List<DashboardRunRecommendation>>.error(
          'Unable to load recommended runs.',
        ),
    data: (candidates) =>
        DashboardSectionModel<List<DashboardRunRecommendation>>.data(
          rankDashboardRunRecommendations(
            candidates: candidates,
            signedUpRunIds: signedUpRunIds,
            attendedRuns: attendedRunsAsync.asData?.value ?? const <Run>[],
            signedUpRuns: signedUpRuns,
            viewer: viewer,
            now: effectiveNow,
          ),
        ),
  );

  final activeSwipeRun = attendedRunsSection.data == null
      ? null
      : latestRunWithOpenSwipeWindow(
          attendedRunsSection.data!,
          now: effectiveNow,
        );
  final reviewedRunIds =
      reviewsByUserAsync.asData?.value
          .map((review) => review.runId)
          .whereType<String>()
          .toSet() ??
      const <String>{};
  final pendingReviewRun = attendedRunsSection.data == null
      ? null
      : _latestUnreviewedAttendedRun(
          attendedRunsSection.data!,
          reviewedRunIds: reviewedRunIds,
        );
  final arrivalAction = uid == null
      ? null
      : selectRunArrivalAction(
          signedUpRuns: signedUpRuns,
          hostedRuns: const [],
          uid: uid,
          now: effectiveNow,
        );

  return DashboardFullViewModel(
    upcomingRuns: upcomingRuns,
    nextRun: nextRun,
    arrivalAction: arrivalAction,
    activeSwipeRun: activeSwipeRun,
    pendingReviewRun: pendingReviewRun,
    hostRunTools: hostRunTools,
    attendedRunsSection: attendedRunsSection,
    weeklyActivitySection: weeklyActivitySection,
    recommendationsSection: recommendationsSection,
  );
}

DashboardSectionModel<WeeklyRunningActivitySnapshot>
_buildWeeklyActivitySection({
  required AsyncValue<List<Run>> attendedRunsAsync,
  required AsyncValue<WeeklyRunningActivitySnapshot>? weeklyActivityAsync,
  required DateTime referenceDate,
}) {
  if (attendedRunsAsync.isLoading) {
    return const DashboardSectionModel<WeeklyRunningActivitySnapshot>.loading(
      'Loading your recent runs...',
    );
  }
  if (weeklyActivityAsync?.isLoading ?? false) {
    return const DashboardSectionModel<WeeklyRunningActivitySnapshot>.loading(
      'Loading your weekly running activity...',
    );
  }

  final attendedRuns = attendedRunsAsync.asData?.value;
  final platformSnapshot = weeklyActivityAsync?.asData?.value;
  if (attendedRunsAsync.hasError &&
      platformSnapshot?.hasPlatformConnection != true) {
    return const DashboardSectionModel<WeeklyRunningActivitySnapshot>.error(
      'Unable to load your recent runs.',
    );
  }

  if (attendedRuns != null || platformSnapshot != null) {
    return DashboardSectionModel<WeeklyRunningActivitySnapshot>.data(
      buildDashboardWeeklyActivitySnapshot(
        attendedRuns: attendedRuns ?? const <Run>[],
        platformSnapshot:
            platformSnapshot ??
            WeeklyRunningActivitySnapshot.unsupported(
              referenceDate: referenceDate,
            ),
        referenceDate: referenceDate,
      ),
    );
  }

  return DashboardSectionModel<WeeklyRunningActivitySnapshot>.data(
    WeeklyRunningActivitySnapshot.unsupported(referenceDate: referenceDate),
  );
}

WeeklyRunningActivitySnapshot buildDashboardWeeklyActivitySnapshot({
  required List<Run> attendedRuns,
  required WeeklyRunningActivitySnapshot platformSnapshot,
  required DateTime referenceDate,
}) {
  final catchActivities = attendedRuns
      .map(_runnerActivityFromCatchRun)
      .toList(growable: false);

  if (!platformSnapshot.hasPlatformConnection) {
    final catchSummary = WeeklyActivitySummary.fromActivities(
      catchActivities,
      referenceDate: referenceDate,
      refreshedAt: platformSnapshot.summary.refreshedAt,
    );
    if (!catchSummary.hasRuns) {
      return platformSnapshot.copyWith(
        summary: catchSummary,
        activities: const [],
        source: WeeklyRunningActivitySource.none,
      );
    }
    return platformSnapshot.copyWith(
      summary: catchSummary,
      activities: catchActivities,
      source: WeeklyRunningActivitySource.catchFallback,
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
    clearMessage: source != WeeklyRunningActivitySource.catchFallback,
    message: source == WeeklyRunningActivitySource.catchFallback
        ? 'Catch check-ins only.'
        : null,
  );
}

RunnerActivity _runnerActivityFromCatchRun(Run run) {
  return RunnerActivity(
    stableId: 'catch:${run.id}',
    provider: RunnerActivityProvider.catchAttendance,
    type: RunnerActivityType.running,
    startTime: run.startTime,
    endTime: run.endTime,
    distanceMeters: run.distanceKm * 1000,
    sourceName: 'Catch',
    matchedCatchRunId: run.id,
  );
}

bool _overlapsPlatformActivity(
  RunnerActivity catchActivity,
  List<RunnerActivity> platformActivities,
) {
  final matchWindowStart = catchActivity.startTime.subtract(
    const Duration(minutes: 30),
  );
  final matchWindowEnd = catchActivity.endTime.add(const Duration(minutes: 30));
  return platformActivities.any(
    (activity) => activity.overlaps(matchWindowStart, matchWindowEnd),
  );
}

WeeklyRunningActivitySource _weeklyActivitySource({
  required List<RunnerActivity> platformActivities,
  required List<RunnerActivity> catchActivities,
  required WeeklyActivitySummary summary,
}) {
  if (!summary.hasRuns) return WeeklyRunningActivitySource.none;
  if (platformActivities.isNotEmpty && catchActivities.isNotEmpty) {
    return WeeklyRunningActivitySource.mixed;
  }
  if (platformActivities.isNotEmpty) {
    return WeeklyRunningActivitySource.healthPlatform;
  }
  return WeeklyRunningActivitySource.catchFallback;
}

List<DashboardHostRunTool> _buildHostRunTools(
  List<Run> hostedRuns, {
  required DateTime now,
}) {
  final tools = <DashboardHostRunTool>[];
  for (final run in hostedRuns) {
    if (run.isCancelled) continue;
    final attendanceState = _hostAttendanceState(run: run, now: now);
    final isFuture = run.startTime.isAfter(now);
    if (!isFuture && attendanceState != DashboardHostAttendanceState.open) {
      continue;
    }
    tools.add(DashboardHostRunTool(run: run, attendanceState: attendanceState));
  }

  tools.sort((a, b) {
    if (a.canTakeAttendance != b.canTakeAttendance) {
      return a.canTakeAttendance ? -1 : 1;
    }
    return a.run.startTime.compareTo(b.run.startTime);
  });
  return tools;
}

DashboardHostAttendanceState _hostAttendanceState({
  required Run run,
  required DateTime now,
}) {
  if (isHostAttendanceOpen(run: run, now: now)) {
    return DashboardHostAttendanceState.open;
  }
  if (now.isBefore(hostAttendanceWindowStartsAt(run))) {
    return DashboardHostAttendanceState.opensLater;
  }
  return DashboardHostAttendanceState.closed;
}

Run? _latestUnreviewedAttendedRun(
  List<Run> attendedRuns, {
  required Set<String> reviewedRunIds,
}) {
  final unreviewedRuns =
      attendedRuns.where((run) => !reviewedRunIds.contains(run.id)).toList()
        ..sort((a, b) => b.endTime.compareTo(a.endTime));
  return unreviewedRuns.firstOrNull;
}

List<DashboardRunRecommendation> rankDashboardRunRecommendations({
  required List<DashboardRunRecommendationCandidate> candidates,
  required Set<String> signedUpRunIds,
  required List<Run> attendedRuns,
  required List<Run> signedUpRuns,
  required DateTime now,
  UserProfile? viewer,
  int limit = 10,
}) {
  final timePreference = _timePreferenceFromRuns(
    attendedRuns: attendedRuns,
    signedUpRuns: signedUpRuns,
    now: now,
  );

  final recommendations = <DashboardRunRecommendation>[];
  for (final candidate in candidates) {
    final run = candidate.run;
    if (signedUpRunIds.contains(run.id) ||
        run.isCancelled ||
        !run.startTime.isAfter(now) ||
        run.isFull) {
      continue;
    }
    if (viewer != null && !_isEligibleForRecommendation(run, viewer)) {
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
    return a.run.startTime.compareTo(b.run.startTime);
  });
  return recommendations.take(limit).toList(growable: false);
}

bool _isEligibleForRecommendation(Run run, UserProfile viewer) {
  if (viewer.age < run.constraints.minAge ||
      viewer.age > run.constraints.maxAge) {
    return false;
  }
  final genderCap = run.constraints.maxForGender(viewer.gender);
  if (genderCap != null &&
      (run.genderCounts[viewer.gender.name] ?? 0) >= genderCap) {
    return false;
  }
  return true;
}

DashboardRunRecommendation _scoreRecommendation({
  required DashboardRunRecommendationCandidate candidate,
  required UserProfile? viewer,
  required _RunTimeBucket? timePreference,
  required DateTime now,
}) {
  final run = candidate.run;
  var score = 0.0;
  var reason = 'From your clubs';

  final distanceReason = _distancePreferenceReason(viewer, run);
  if (distanceReason != null) {
    score += 28;
    reason = distanceReason;
  } else if (_hasNearbyPreferredDistance(viewer, run)) {
    score += 12;
  }

  final paceScore = _paceFitScore(viewer, run);
  score += paceScore;
  if (reason == 'From your clubs' && paceScore >= 18) {
    reason = 'Fits your pace';
  }

  final runTimeBucket = _RunTimeBucket.fromHour(run.startTime.hour);
  if (timePreference != null && runTimeBucket == timePreference) {
    score += 18;
    if (reason == 'From your clubs') {
      reason = '${timePreference.label} run pattern';
    }
  }

  final proximityScore = _proximityScore(viewer, run);
  score += proximityScore;
  if (reason == 'From your clubs' && proximityScore >= 14) {
    reason = 'Near you';
  }

  if (_isSameCity(viewer, candidate.clubLocation)) {
    score += 10;
  }

  score += _startTimeScore(run, now);
  score += run.spotsRemaining >= 5 ? 5 : 2;

  return DashboardRunRecommendation(
    run: run,
    clubName: candidate.clubName,
    reasonLabel: reason,
    score: score,
  );
}

String? _distancePreferenceReason(UserProfile? viewer, Run run) {
  final preferredDistances = viewer?.preferredDistances ?? const [];
  for (final preferred in preferredDistances) {
    if ((run.distanceKm - preferred.targetKm).abs() <= 0.75) {
      return 'Matches your ${preferred.label} preference';
    }
  }
  return null;
}

bool _hasNearbyPreferredDistance(UserProfile? viewer, Run run) {
  final preferredDistances = viewer?.preferredDistances ?? const [];
  return preferredDistances.any(
    (preferred) => (run.distanceKm - preferred.targetKm).abs() <= 2,
  );
}

double _paceFitScore(UserProfile? viewer, Run run) {
  if (viewer == null) return 0;
  final runPace = run.pace.secondsPerKm;
  if (runPace >= viewer.paceMinSecsPerKm &&
      runPace <= viewer.paceMaxSecsPerKm) {
    return 18;
  }
  final minDelta = (runPace - viewer.paceMinSecsPerKm).abs();
  final maxDelta = (runPace - viewer.paceMaxSecsPerKm).abs();
  return minDelta < 45 || maxDelta < 45 ? 8 : 0;
}

double _proximityScore(UserProfile? viewer, Run run) {
  final userLocation = LocationCoordinate.fromNullable(
    latitude: viewer?.latitude,
    longitude: viewer?.longitude,
  );
  final runLocation = LocationCoordinate.fromNullable(
    latitude: run.startingPointLat,
    longitude: run.startingPointLng,
  );
  if (userLocation == null || runLocation == null) return 0;

  final distanceKm = userLocation.distanceTo(runLocation) / 1000;
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

double _startTimeScore(Run run, DateTime now) {
  final daysAway = run.startTime.difference(now).inDays;
  if (daysAway <= 7) return 8;
  if (daysAway <= 14) return 5;
  if (daysAway <= 30) return 2;
  return 0;
}

_RunTimeBucket? _timePreferenceFromRuns({
  required List<Run> attendedRuns,
  required List<Run> signedUpRuns,
  required DateTime now,
}) {
  final counts = <_RunTimeBucket, int>{};
  void addRun(Run run, int weight) {
    if (run.startTime.isAfter(now)) return;
    final bucket = _RunTimeBucket.fromHour(run.startTime.hour);
    counts[bucket] = (counts[bucket] ?? 0) + weight;
  }

  for (final run in attendedRuns) {
    addRun(run, 2);
  }
  for (final run in signedUpRuns) {
    addRun(run, 1);
  }
  if (counts.isEmpty) return null;

  final ranked = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return ranked.first.value > 1 ? ranked.first.key : null;
}

enum _RunTimeBucket {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening');

  const _RunTimeBucket(this.label);

  final String label;

  factory _RunTimeBucket.fromHour(int hour) {
    if (hour < 12) return _RunTimeBucket.morning;
    if (hour < 17) return _RunTimeBucket.afternoon;
    return _RunTimeBucket.evening;
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

/// Combines signed-up runs, attended runs, and recommended runs into a single
/// [DashboardFullViewModel] for the dashboard screen.
@riverpod
DashboardFullViewModel dashboardFullViewModel(
  Ref ref, {
  required List<Run> signedUpRuns,
  required UserProfile user,
  required String uid,
  required List<String> followedClubIds,
}) {
  final hostedClubs = ref
      .watch(watchRunClubsHostedByProvider(uid))
      .asData
      ?.value;
  final hostedRuns = <Run>[];
  for (final club in hostedClubs ?? const <RunClub>[]) {
    final runs = ref.watch(watchRunsForClubProvider(club.id)).asData?.value;
    if (runs != null) {
      hostedRuns.addAll(runs);
    }
  }

  return buildDashboardFullViewModel(
    signedUpRuns: signedUpRuns,
    uid: uid,
    viewer: user,
    hostedRuns: hostedRuns,
    attendedRunsAsync: ref.watch(watchAttendedRunsProvider(uid)),
    weeklyActivityAsync: ref.watch(weeklyRunningActivityProvider),
    reviewsByUserAsync: ref.watch(watchReviewsByUserProvider(uid)),
    recommendedRunsAsync: ref.watch(
      dashboardRecommendedRunsProvider(
        DashboardRecommendationsQuery(
          userId: uid,
          followedClubIds: followedClubIds,
        ),
      ),
    ),
  );
}
