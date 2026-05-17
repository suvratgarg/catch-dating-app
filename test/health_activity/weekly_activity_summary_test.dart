import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyActivitySummary', () {
    test('uses Monday inclusive and next Monday exclusive week boundaries', () {
      final referenceDate = DateTime(2026, 5, 13, 12);
      final summary = WeeklyActivitySummary.fromActivities([
        _activity(
          startTime: DateTime(2026, 5, 10, 23, 59),
          distanceMeters: 9000,
        ),
        _activity(startTime: DateTime(2026, 5, 11), distanceMeters: 5000),
        _activity(startTime: DateTime(2026, 5, 17, 10), distanceMeters: 3000),
        _activity(startTime: DateTime(2026, 5, 18), distanceMeters: 7000),
      ], referenceDate: referenceDate);

      expect(summary.weekStart, DateTime(2026, 5, 11));
      expect(summary.weekEnd, DateTime(2026, 5, 18));
      expect(summary.runCount, 2);
      expect(summary.totalDistanceKm, 8);
      expect(summary.distanceMetersByWeekday[0], 5000);
      expect(summary.distanceMetersByWeekday[6], 3000);
    });

    test('ignores zero-distance activity', () {
      final summary = WeeklyActivitySummary.fromActivities([
        _activity(startTime: DateTime(2026, 5, 11), distanceMeters: 0),
      ], referenceDate: DateTime(2026, 5, 13));

      expect(summary.hasEvents, isFalse);
      expect(summary.runCount, 0);
      expect(summary.totalDistanceMeters, 0);
    });
  });
}

RunnerActivity _activity({
  required DateTime startTime,
  required double distanceMeters,
}) {
  return RunnerActivity(
    stableId: startTime.toIso8601String(),
    provider: RunnerActivityProvider.appleHealth,
    type: RunnerActivityType.running,
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1)),
    distanceMeters: distanceMeters,
  );
}
