import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

List<EventAttendee> buildOperationalAttendees({
  required Event event,
  required DateTime now,
}) => [
  EventAttendee(
    id: 'external-1',
    eventId: event.id,
    clubId: event.clubId,
    organizerId: 'host-1',
    displayName: 'External guest 1',
    searchName: 'external guest 1',
    source: EventAttendeeSource.hostImport,
    status: EventAttendeeStatus.checkedIn,
    createdAt: now,
    updatedAt: now,
    checkedInAt: now,
  ),
  EventAttendee(
    id: 'external-2',
    eventId: event.id,
    clubId: event.clubId,
    organizerId: 'host-1',
    displayName: 'External guest 2',
    searchName: 'external guest 2',
    source: EventAttendeeSource.hostImport,
    status: EventAttendeeStatus.registered,
    createdAt: now,
    updatedAt: now,
  ),
];

Future<void> acceptInitialTime(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateEventFormKeys.timePicker));
  await pumpFeatureUi(tester);
  await tester.tap(find.text('OK'));
  await pumpFeatureUi(tester);
}

Finder hostManageScrollable() => find
    .descendant(
      of: find.byKey(const Key('host_event_manage_scroll_view')),
      matching: find.byType(Scrollable),
    )
    .first;
