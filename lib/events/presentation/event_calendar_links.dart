import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_calendar_links.g.dart';

@Riverpod(keepAlive: true)
EventCalendarController eventCalendarController(Ref ref) =>
    EventCalendarController(ref.watch(externalLinkControllerProvider));

class EventCalendarController {
  const EventCalendarController(this._links);

  final ExternalLinkController _links;

  Future<bool> addToCalendar(Event event) {
    return _links.openExternal(calendarUriForEvent(event));
  }
}

Uri calendarUriForEvent(Event event) {
  return Uri.https('calendar.google.com', '/calendar/render', {
    'action': 'TEMPLATE',
    'text': event.title,
    'dates':
        '${_calendarTimestamp(event.startTime)}/${_calendarTimestamp(event.endTime)}',
    'details': _calendarDetails(event),
    'location': _calendarLocation(event),
  });
}

String _calendarTimestamp(DateTime dateTime) {
  final utc = dateTime.toUtc();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${utc.year}'
      '${twoDigits(utc.month)}'
      '${twoDigits(utc.day)}T'
      '${twoDigits(utc.hour)}'
      '${twoDigits(utc.minute)}'
      '${twoDigits(utc.second)}Z';
}

String _calendarDetails(Event event) {
  final details = [
    'Catch event',
    event.description.trim(),
    event.activitySummaryLabel,
    if (event.locationNotes?.trim().isNotEmpty == true)
      event.locationNotes!.trim(),
  ]..removeWhere((line) => line.isEmpty);

  return details.join('\n');
}

String _calendarLocation(Event event) {
  final locationDetails = event.locationNotes?.trim();
  if (locationDetails == null || locationDetails.isEmpty) {
    return event.locationName;
  }
  return '${event.locationName}, $locationDetails';
}
