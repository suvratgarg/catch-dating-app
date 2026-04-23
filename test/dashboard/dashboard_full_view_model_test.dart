import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
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
        attendedUserIds: const ['runner-1'],
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 6)),
      );
      final latest = buildRun(
        id: 'latest',
        attendedUserIds: const ['runner-1'],
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
  });
}
