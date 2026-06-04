import 'package:flutter/widgets.dart';

abstract final class HostEventActionKeys {
  static const takeAttendanceButton = ValueKey(
    'hosts.event.takeAttendance.button',
  );

  static Key attendeeCheckInButton(String uid) =>
      ValueKey('hosts.event.attendee.$uid.checkIn.button');
}
