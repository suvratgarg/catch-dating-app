import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

void main() {
  group('RunFormatters', () {
    final dateTime = DateTime(2025, 4, 23, 6, 30);

    test('formats short and long date labels', () {
      expect(RunFormatters.shortMonth(dateTime), 'Apr');
      expect(RunFormatters.shortWeekday(dateTime), 'Wed');
      expect(RunFormatters.longWeekday(dateTime), 'Wednesday');
      expect(RunFormatters.shortDate(dateTime), 'Wed, 23 Apr');
      expect(RunFormatters.longDate(dateTime), 'Wednesday, 23 Apr');
    });

    test('formats times and time ranges', () {
      final endTime = DateTime(2025, 4, 23, 7, 45);

      expect(RunFormatters.time(dateTime), '06:30');
      expect(RunFormatters.timeRange(dateTime, endTime), '06:30 – 07:45');
      expect(
        RunFormatters.timeRange(dateTime, endTime, separator: ' to '),
        '06:30 to 07:45',
      );
    });

    test('formats distances, prices, and durations', () {
      expect(RunFormatters.distanceKm(5), '5km');
      expect(RunFormatters.distanceKm(5.5), '5.5km');
      expect(RunFormatters.distanceKm(5.5, includeUnit: false), '5.5');
      expect(RunFormatters.priceInPaise(25000), '₹250');
      expect(RunFormatters.priceInPaise(24950), '₹249.50');
      expect(RunFormatters.durationMinutes(45), '45m');
      expect(RunFormatters.durationMinutes(120), '2h');
      expect(RunFormatters.durationMinutes(90), '1h 30m');
    });
  });

  group('RunFormattingX', () {
    test('adds shared display labels to runs', () {
      final run = buildRun(
        startTime: DateTime(2025, 4, 23, 6, 30),
        endTime: DateTime(2025, 4, 23, 7, 45),
        distanceKm: 5.5,
        signedUpUserIds: const ['runner-1', 'runner-2'],
      );

      expect(run.shortDateLabel, 'Wed, 23 Apr');
      expect(run.longDateLabel, 'Wednesday, 23 Apr');
      expect(run.timeRangeLabel, '06:30 – 07:45');
      expect(run.compactTimeRangeLabel, '06:30–07:45');
      expect(run.distanceLabel, '5.5km');
      expect(run.distanceValueLabel, '5.5');
      expect(run.spotsLabel, '2/20');
    });
  });
}
