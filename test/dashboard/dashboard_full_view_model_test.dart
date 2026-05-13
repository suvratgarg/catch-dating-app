import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

const _noRecommendationCandidates =
    AsyncData<List<DashboardRunRecommendationCandidate>>([]);

DashboardRunRecommendationCandidate _recommendationCandidate(
  Run run, {
  String clubName = 'Stride Social',
  String? clubLocation = 'mumbai',
}) => DashboardRunRecommendationCandidate(
  run: run,
  clubName: clubName,
  clubLocation: clubLocation,
);

void main() {
  group('buildDashboardFullViewModel', () {
    test('selects the nearest upcoming run as nextRun', () {
      final now = DateTime(2026, 4, 23, 9);
      final earlier = buildRun(startTime: now.add(const Duration(hours: 2)));
      final later = buildRun(
        id: 'later',
        startTime: now.add(const Duration(hours: 5)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: [later, earlier],
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.nextRun?.id, earlier.id);
      expect(viewModel.upcomingRuns.map((run) => run.id), [
        earlier.id,
        later.id,
      ]);
    });

    test('filters past booked runs out of upcomingRuns', () {
      final now = DateTime(2026, 4, 23, 9);
      final past = buildRun(
        id: 'past',
        startTime: now.subtract(const Duration(hours: 2)),
      );
      final upcoming = buildRun(
        id: 'upcoming',
        startTime: now.add(const Duration(hours: 2)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: [past, upcoming],
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.nextRun?.id, 'upcoming');
      expect(viewModel.upcomingRuns.map((run) => run.id), ['upcoming']);
    });

    test('surfaces attended section errors and clears the swipe run', () {
      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: const [],
        attendedRunsAsync: AsyncError<List<Run>>(
          Exception('boom'),
          StackTrace.empty,
        ),
        recommendedRunsAsync: _noRecommendationCandidates,
      );

      expect(viewModel.attendedRunsSection.hasError, isTrue);
      expect(
        viewModel.attendedRunsSection.message,
        'Unable to load your recent runs.',
      );
      expect(viewModel.activeSwipeRun, isNull);
    });

    test('selects the most recent run with an open swipe window', () {
      final now = DateTime(2026, 4, 23, 20);
      final older = buildRun(
        id: 'older',
        checkedInCount: 1,
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 6)),
      );
      final latest = buildRun(
        id: 'latest',
        checkedInCount: 1,
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 2)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: const [],
        attendedRunsAsync: AsyncData<List<Run>>([older, latest]),
        recommendedRunsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.activeSwipeRun?.id, latest.id);
    });

    test('selects the latest attended run that has not been reviewed', () {
      final now = DateTime(2026, 4, 23, 20);
      final reviewedRun = buildRun(
        id: 'reviewed-run',
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 7)),
      );
      final pendingRun = buildRun(
        id: 'pending-run',
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 3)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: const [],
        attendedRunsAsync: AsyncData<List<Run>>([reviewedRun, pendingRun]),
        reviewsByUserAsync: AsyncData<List<Review>>([
          buildReview(id: 'reviewed-run~runner-1', runId: reviewedRun.id),
        ]),
        recommendedRunsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.pendingReviewRun?.id, 'pending-run');
    });

    test('surfaces recommendation loading state', () {
      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: const [],
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync:
            const AsyncLoading<List<DashboardRunRecommendationCandidate>>(),
      );

      expect(viewModel.recommendationsSection.isLoading, isTrue);
      expect(
        viewModel.recommendationsSection.message,
        'Loading recommended runs...',
      );
    });

    test('removes already booked runs from recommendations', () {
      final booked = buildRun(id: 'booked');
      final unbooked = buildRun(id: 'recommended');

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: [booked],
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync:
            AsyncData<List<DashboardRunRecommendationCandidate>>([
              _recommendationCandidate(booked),
              _recommendationCandidate(unbooked),
            ]),
      );

      expect(
        viewModel.recommendationsSection.data?.map((item) => item.run.id),
        ['recommended'],
      );
    });

    test('ranks recommendations by preferences, proximity, and run time', () {
      final now = DateTime(2026, 4, 23, 9);
      final viewer = buildUser().copyWith(
        city: 'mumbai',
        latitude: 19.076,
        longitude: 72.8777,
        paceMinSecsPerKm: 330,
        paceMaxSecsPerKm: 390,
        preferredDistances: const [PreferredDistance.tenK],
      );
      final morningHistory = buildRun(
        id: 'morning-history',
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
      );
      final strongMatch = buildRun(
        id: 'strong-match',
        distanceKm: 10,
        pace: PaceLevel.moderate,
        startTime: DateTime(2026, 4, 24, 7),
        startingPointLat: 19.08,
        startingPointLng: 72.88,
      );
      final weakMatch = buildRun(
        id: 'weak-match',
        distanceKm: 5,
        pace: PaceLevel.competitive,
        startTime: DateTime(2026, 4, 24, 19),
        startingPointLat: 19.30,
        startingPointLng: 72.90,
      );

      final recommendations = rankDashboardRunRecommendations(
        candidates: [
          _recommendationCandidate(
            weakMatch,
            clubName: 'Late Miles',
            clubLocation: 'delhi',
          ),
          _recommendationCandidate(strongMatch, clubName: 'Bandra Run Club'),
        ],
        signedUpRunIds: const {},
        attendedRuns: [morningHistory],
        signedUpRuns: const [],
        viewer: viewer,
        now: now,
      );

      expect(recommendations.map((item) => item.run.id), [
        'strong-match',
        'weak-match',
      ]);
      expect(recommendations.first.clubName, 'Bandra Run Club');
      expect(
        recommendations.first.reasonLabel,
        'Matches your 10 km preference',
      );
    });

    test('filters past, cancelled, full, booked, and ineligible runs', () {
      final now = DateTime(2026, 4, 23, 9);
      final viewer = buildUser();
      final eligible = buildRun(
        id: 'eligible',
        startTime: now.add(const Duration(hours: 3)),
      );
      final booked = buildRun(
        id: 'booked',
        startTime: now.add(const Duration(hours: 4)),
      );
      final cancelled = buildRun(
        id: 'cancelled',
        startTime: now.add(const Duration(hours: 5)),
        status: RunLifecycleStatus.cancelled,
      );
      final full = buildRun(
        id: 'full',
        startTime: now.add(const Duration(hours: 6)),
        capacityLimit: 2,
        bookedCount: 2,
      );
      final ineligible = buildRun(
        id: 'ineligible',
        startTime: now.add(const Duration(hours: 7)),
        constraints: const RunConstraints(minAge: 45),
      );
      final past = buildRun(
        id: 'past',
        startTime: now.subtract(const Duration(hours: 1)),
      );

      final recommendations = rankDashboardRunRecommendations(
        candidates: [
          eligible,
          booked,
          cancelled,
          full,
          ineligible,
          past,
        ].map(_recommendationCandidate).toList(),
        signedUpRunIds: {'booked'},
        attendedRuns: const [],
        signedUpRuns: const [],
        viewer: viewer,
        now: now,
      );

      expect(recommendations.map((item) => item.run.id), ['eligible']);
    });

    test('selects self check-in during the run check-in window', () {
      final now = DateTime(2026, 4, 23, 8, 55);
      final run = buildRun(
        id: 'check-in-run',
        bookedCount: 1,
        startTime: DateTime(2026, 4, 23, 9),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: [run],
        uid: 'runner-1',
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.arrivalAction?.kind, RunArrivalActionKind.selfCheckIn);
      expect(viewModel.arrivalAction?.run.id, 'check-in-run');
    });

    test('exposes open host attendance in host tools', () {
      final now = DateTime(2026, 4, 23, 9, 5);
      final hostedRun = buildRun(
        id: 'hosted-run',
        startTime: DateTime(2026, 4, 23, 9),
        endTime: DateTime(2026, 4, 23, 10),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: const [],
        uid: 'host-1',
        hostedRuns: [hostedRun],
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.arrivalAction, isNull);
      expect(viewModel.hostRunTools.single.run.id, 'hosted-run');
      expect(
        viewModel.hostRunTools.single.attendanceState,
        DashboardHostAttendanceState.open,
      );
    });

    test('exposes actionable hosted runs with attendance-open runs first', () {
      final now = DateTime(2026, 4, 23, 9);
      final recentlyEnded = buildRun(
        id: 'recently-ended-hosted',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );
      final old = buildRun(
        id: 'old-hosted',
        startTime: now.subtract(const Duration(hours: 10)),
        endTime: now.subtract(const Duration(hours: 9)),
      );
      final later = buildRun(
        id: 'later-hosted',
        startTime: now.add(const Duration(hours: 4)),
      );
      final sooner = buildRun(
        id: 'sooner-hosted',
        startTime: now.add(const Duration(hours: 2)),
      );

      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: const [],
        uid: 'host-1',
        hostedRuns: [old, later, recentlyEnded, sooner],
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync: _noRecommendationCandidates,
        now: now,
      );

      expect(viewModel.hostRunTools.map((tool) => tool.run.id), [
        'recently-ended-hosted',
        'sooner-hosted',
        'later-hosted',
      ]);
      expect(viewModel.hostRunTools.map((tool) => tool.attendanceState), [
        DashboardHostAttendanceState.open,
        DashboardHostAttendanceState.opensLater,
        DashboardHostAttendanceState.opensLater,
      ]);
    });
  });
}
