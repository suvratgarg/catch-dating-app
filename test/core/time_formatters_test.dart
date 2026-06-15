import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTimeFormatters', () {
    test('formats shared date labels', () {
      final dateTime = DateTime(2025, 4, 23, 6, 30);

      expect(AppTimeFormatters.shortMonth(dateTime), 'Apr');
      expect(AppTimeFormatters.shortWeekday(dateTime), 'Wed');
      expect(AppTimeFormatters.longWeekday(dateTime), 'Wednesday');
      expect(AppTimeFormatters.weekdayDayMonth(dateTime), 'Wed 23 Apr');
      expect(AppTimeFormatters.shortDate(dateTime), 'Wed, 23 Apr');
      expect(AppTimeFormatters.longDate(dateTime), 'Wednesday, 23 Apr');
      expect(AppTimeFormatters.monthDay(dateTime), 'Apr 23');
    });

    test('formats chat timestamps by age', () {
      final now = DateTime(2026, 6, 15, 12);

      expect(
        AppTimeFormatters.chatTimestamp(DateTime(2026, 6, 15, 9, 30), now: now),
        '9:30 AM',
      );
      expect(
        AppTimeFormatters.chatTimestamp(DateTime(2026, 6, 12, 9, 30), now: now),
        'Fri',
      );
      expect(
        AppTimeFormatters.chatTimestamp(DateTime(2026, 5, 31, 9, 30), now: now),
        'May 31',
      );
      expect(AppTimeFormatters.chatTimestamp(null, now: now), '');
    });
  });
}
