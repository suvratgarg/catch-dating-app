import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/events/domain/event.dart';

enum HostEventAttendanceState { open, opensLater, closed }

HostEventAttendanceState hostEventAttendanceStateFor({
  required Event event,
  required DateTime now,
}) {
  if (isHostAttendanceOpen(event: event, now: now)) {
    return HostEventAttendanceState.open;
  }
  if (now.isBefore(hostAttendanceWindowStartsAt(event))) {
    return HostEventAttendanceState.opensLater;
  }
  return HostEventAttendanceState.closed;
}

bool isPastHostedEventForOperations({
  required Event event,
  required HostEventAttendanceState attendanceState,
  required DateTime now,
}) {
  return attendanceState == HostEventAttendanceState.closed &&
      event.endTime.isBefore(now);
}

bool isHostAttendanceOpen({required Event event, required DateTime now}) {
  final startsAt = hostAttendanceWindowStartsAt(event);
  final endsAt = event.endTime.add(
    const Duration(
      hours: CatchBusinessRules.eventHostAttendanceWindowAfterEventHours,
    ),
  );
  return now.isAfter(startsAt) && now.isBefore(endsAt);
}

DateTime hostAttendanceWindowStartsAt(Event event) {
  return event.startTime.subtract(
    const Duration(
      minutes: CatchBusinessRules.eventHostAttendanceWindowBeforeMinutes,
    ),
  );
}
