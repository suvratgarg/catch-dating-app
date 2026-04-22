import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  group('swipe window helpers', () {
    test('calculates the closing time 24 hours after the run ends', () {
      final endTime = DateTime(2026, 4, 20, 8);
      final run = buildRun(
        startTime: endTime.subtract(const Duration(hours: 1)),
        endTime: endTime,
      );

      expect(swipeWindowClosesAt(run), DateTime(2026, 4, 21, 8));
    });

    test('filters runs with an active swipe window', () {
      final now = DateTime(2026, 4, 22, 12);
      final openRun = buildRun(
        id: 'open',
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 2)),
      );
      final upcomingRun = buildRun(
        id: 'upcoming',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
      );
      final closedRun = buildRun(
        id: 'closed',
        startTime: now.subtract(const Duration(hours: 30)),
        endTime: now.subtract(const Duration(hours: 29)),
      );

      expect(
        runsWithOpenSwipeWindow([
          openRun,
          upcomingRun,
          closedRun,
        ], now: now).map((run) => run.id).toList(),
        ['open'],
      );
    });

    test('selects the most recent run with an active swipe window', () {
      final now = DateTime(2026, 4, 22, 12);
      final olderRun = buildRun(
        id: 'older',
        startTime: now.subtract(const Duration(hours: 6)),
        endTime: now.subtract(const Duration(hours: 5)),
      );
      final latestRun = buildRun(
        id: 'latest',
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 2)),
      );

      expect(
        latestRunWithOpenSwipeWindow([olderRun, latestRun], now: now)?.id,
        'latest',
      );
    });
  });
}
