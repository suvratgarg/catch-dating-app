import 'package:intl/intl.dart';

abstract final class AppTimeFormatters {
  static final DateFormat _timeOfDay = DateFormat('h:mm a');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy · h:mm a');

  static String time(DateTime dateTime) => _timeOfDay.format(dateTime);

  static String clockTime({required int hour, required int minute}) {
    return time(DateTime(2000, 1, 1, hour, minute));
  }

  static String dateTime(DateTime dateTime) => _dateTime.format(dateTime);
}
