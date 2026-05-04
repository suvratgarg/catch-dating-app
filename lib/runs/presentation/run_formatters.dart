import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:intl/intl.dart';

class RunFormatters {
  static final _month = DateFormat('MMM');
  static final _weekdayShort = DateFormat('E');
  static final _weekdayLong = DateFormat('EEEE');
  static final _time = DateFormat('HH:mm');
  static final _shortDateFmt = DateFormat('E, d MMM');
  static final _longDateFmt = DateFormat('EEEE, d MMM');

  static String shortMonth(DateTime dateTime) => _month.format(dateTime);

  static String shortWeekday(DateTime dateTime) =>
      _weekdayShort.format(dateTime);

  static String longWeekday(DateTime dateTime) =>
      _weekdayLong.format(dateTime);

  static String shortDate(DateTime dateTime) => _shortDateFmt.format(dateTime);

  static String longDate(DateTime dateTime) => _longDateFmt.format(dateTime);

  static String time(DateTime dateTime) => _time.format(dateTime);

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
