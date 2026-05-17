import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:intl/intl.dart';

class EventFormatters {
  static final _month = DateFormat('MMM');
  static final _weekdayShort = DateFormat('E');
  static final _weekdayLong = DateFormat('EEEE');
  static final _shortDateFmt = DateFormat('E, d MMM');
  static final _longDateFmt = DateFormat('EEEE, d MMM');

  static String shortMonth(DateTime dateTime) => _month.format(dateTime);

  static String shortWeekday(DateTime dateTime) =>
      _weekdayShort.format(dateTime);

  static String longWeekday(DateTime dateTime) => _weekdayLong.format(dateTime);

  static String shortDate(DateTime dateTime) => _shortDateFmt.format(dateTime);

  static String longDate(DateTime dateTime) => _longDateFmt.format(dateTime);

  static String time(DateTime dateTime) => AppTimeFormatters.time(dateTime);

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

extension EventFormattingX on Event {
  String get shortDateLabel => EventFormatters.shortDate(startTime);
  String get longDateLabel => EventFormatters.longDate(startTime);
  String get timeRangeLabel => EventFormatters.timeRange(startTime, endTime);
  String get compactTimeRangeLabel =>
      EventFormatters.timeRange(startTime, endTime, separator: '–');
  String get distanceLabel => EventFormatters.distanceKm(distanceKm);
  String get distanceValueLabel =>
      EventFormatters.distanceKm(distanceKm, includeUnit: false);
  String get spotsLabel => '$signedUpCount/$capacityLimit';
}
