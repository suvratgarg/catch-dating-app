import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

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
        recommendedRunsAsync: const AsyncData<List<Run>>([]),
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
        recommendedRunsAsync: const AsyncData<List<Run>>([]),
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
        recommendedRunsAsync: const AsyncData<List<Run>>([]),
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
        recommendedRunsAsync: const AsyncData<List<Run>>([]),
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
        recommendedRunsAsync: const AsyncData<List<Run>>([]),
        now: now,
      );

      expect(viewModel.pendingReviewRun?.id, 'pending-run');
    });

    test('surfaces recommendation loading state', () {
      final viewModel = buildDashboardFullViewModel(
        signedUpRuns: const [],
        attendedRunsAsync: const AsyncData<List<Run>>([]),
        recommendedRunsAsync: const AsyncLoading<List<Run>>(),
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
        recommendedRunsAsync: AsyncData<List<Run>>([booked, unbooked]),
      );

      expect(viewModel.recommendationsSection.data, [unbooked]);
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
        recommendedRunsAsync: const AsyncData<List<Run>>([]),
        now: now,
      );

      expect(viewModel.arrivalAction?.kind, RunArrivalActionKind.selfCheckIn);
      expect(viewModel.arrivalAction?.run.id, 'check-in-run');
    });

    test('selects host attendance for active hosted runs', () {
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
        recommendedRunsAsync: const AsyncData<List<Run>>([]),
        now: now,
      );

      expect(
        viewModel.arrivalAction?.kind,
        RunArrivalActionKind.takeAttendance,
      );
      expect(viewModel.arrivalAction?.run.id, 'hosted-run');
    });
  });
}
