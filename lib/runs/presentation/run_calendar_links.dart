import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final runCalendarControllerProvider = Provider<RunCalendarController>((ref) {
  return RunCalendarController(ref.watch(externalLinkControllerProvider));
});

class RunCalendarController {
  const RunCalendarController(this._links);

  final ExternalLinkController _links;

  Future<bool> addToCalendar(Run run) {
    return _links.openExternal(calendarUriForRun(run));
  }
}

Uri calendarUriForRun(Run run) {
  return Uri.https('calendar.google.com', '/calendar/render', {
    'action': 'TEMPLATE',
    'text': run.title,
    'dates':
        '${_calendarTimestamp(run.startTime)}/${_calendarTimestamp(run.endTime)}',
    'details': _calendarDetails(run),
    'location': _calendarLocation(run),
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

String _calendarDetails(Run run) {
  final details = [
    'Catch run',
    run.description.trim(),
    '${run.distanceLabel} · ${run.pace.label}',
    if (run.locationDetails?.trim().isNotEmpty == true)
      run.locationDetails!.trim(),
  ]..removeWhere((line) => line.isEmpty);

  return details.join('\n');
}

String _calendarLocation(Run run) {
  final locationDetails = run.locationDetails?.trim();
  if (locationDetails == null || locationDetails.isEmpty) {
    return run.meetingPoint;
  }
  return '${run.meetingPoint}, $locationDetails';
}
