import 'package:catch_dating_app/runs/domain/run.dart';

class RunFormatters {
  static const _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _weekdaysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const _weekdaysLong = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String shortMonth(DateTime dateTime) =>
      _monthsShort[dateTime.month - 1];

  static String shortWeekday(DateTime dateTime) =>
      _weekdaysShort[dateTime.weekday - 1];

  static String longWeekday(DateTime dateTime) =>
      _weekdaysLong[dateTime.weekday - 1];

  static String shortDate(DateTime dateTime) =>
      '${shortWeekday(dateTime)}, ${dateTime.day} ${shortMonth(dateTime)}';

  static String longDate(DateTime dateTime) =>
      '${longWeekday(dateTime)}, ${dateTime.day} ${shortMonth(dateTime)}';

  static String time(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  static String timeRange(
    DateTime startTime,
    DateTime endTime, {
    String separator = ' – ',
  }) => '${time(startTime)}$separator${time(endTime)}';

  static String distanceKm(double distanceKm, {bool includeUnit = true}) {
    final value = distanceKm == distanceKm.roundToDouble()
        ? '${distanceKm.round()}'
        : distanceKm.toStringAsFixed(1);
    return includeUnit ? '${value}km' : value;
  }

  static String priceInPaise(int paise) {
    final rupees = paise / 100;
    return rupees == rupees.roundToDouble()
        ? '₹${rupees.round()}'
        : '₹${rupees.toStringAsFixed(2)}';
  }

  static String durationMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainderMinutes = minutes % 60;
    if (hours == 0) return '${remainderMinutes}m';
    if (remainderMinutes == 0) return '${hours}h';
    return '${hours}h ${remainderMinutes}m';
  }
}

extension RunFormattingX on Run {
  String get shortDateLabel => RunFormatters.shortDate(startTime);
  String get longDateLabel => RunFormatters.longDate(startTime);
  String get timeRangeLabel => RunFormatters.timeRange(startTime, endTime);
  String get compactTimeRangeLabel =>
      RunFormatters.timeRange(startTime, endTime, separator: '–');
  String get distanceLabel => RunFormatters.distanceKm(distanceKm);
  String get distanceValueLabel =>
      RunFormatters.distanceKm(distanceKm, includeUnit: false);
  String get spotsLabel => '$signedUpCount/$capacityLimit';
}
