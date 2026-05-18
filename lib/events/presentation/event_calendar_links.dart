import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventCalendarControllerProvider = Provider<EventCalendarController>((
  ref,
) {
  return EventCalendarController(ref.watch(externalLinkControllerProvider));
});

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
    if (event.locationDetails?.trim().isNotEmpty == true)
      event.locationDetails!.trim(),
  ]..removeWhere((line) => line.isEmpty);

  return details.join('\n');
}

String _calendarLocation(Event event) {
  final locationDetails = event.locationDetails?.trim();
  if (locationDetails == null || locationDetails.isEmpty) {
    return event.meetingPoint;
  }
  return '${event.meetingPoint}, $locationDetails';
}
