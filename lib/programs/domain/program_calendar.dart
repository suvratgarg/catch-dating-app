import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

bool _initialized = false;

void _ensureTimeZones() {
  if (_initialized) return;
  timezone_data.initializeTimeZones();
  _initialized = true;
}

bool isProgramTimeZone(String identifier) {
  _ensureTimeZones();
  try {
    timezone.getLocation(identifier.trim());
    return true;
  } on timezone.LocationNotFoundException {
    return false;
  }
}

/// Resolves a date-picker calendar value to midnight in the program's IANA
/// timezone. The device timezone never participates in the resulting instant.
DateTime programCalendarDateInstant(DateTime date, String identifier) {
  _ensureTimeZones();
  final location = timezone.getLocation(identifier.trim());
  return timezone.TZDateTime(location, date.year, date.month, date.day);
}

/// Projects a stored instant back into the Program's civil calendar. Date
/// labels must use this value instead of the device timezone.
DateTime programCalendarDateAtInstant(DateTime instant, String identifier) {
  _ensureTimeZones();
  final location = timezone.getLocation(identifier.trim());
  return timezone.TZDateTime.from(instant, location);
}
