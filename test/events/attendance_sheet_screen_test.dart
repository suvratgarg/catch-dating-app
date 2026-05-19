import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';
import 'events_test_helpers.dart';

void main() {
  testWidgets('shows an empty state when no runners have signed up', (
    tester,
  ) async {
    final event = buildEvent(bookedCount: 1);

    await pumpEventsTestApp(
      tester,
      Scaffold(body: HostEventAttendancePanel(eventId: event.id)),
      overrides: [
        watchEventProvider(event.id).overrideWith((ref) => Stream.value(event)),
        watchEventParticipationsForEventProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(const [])),
      ],
    );
    await _settleAttendanceSheet(tester);

    expect(find.text('No attendees yet'), findsOneWidget);
    expect(
      find.text('No one has signed up for this event yet.'),
      findsOneWidget,
    );
  });

  testWidgets('renders attendee profiles and toggles attendance', (
    tester,
  ) async {
    final event = buildEvent(id: 'attendance-event');
    final fakeEventRepository = FakeEventRepository();
    final fakePublicProfileRepository = FakePublicProfileRepository()
      ..profiles = [
        buildPublicProfile(uid: 'runner-1', name: 'Asha'),
        buildPublicProfile(uid: 'runner-2', name: 'Kabir'),
      ];

    await pumpEventsTestApp(
      tester,
      Scaffold(body: HostEventAttendancePanel(eventId: event.id)),
      overrides: [
        watchEventProvider(event.id).overrideWith((ref) => Stream.value(event)),
        watchEventParticipationsForEventProvider(event.id).overrideWith(
          (ref) => Stream.value([
            buildEventParticipation(
              event: event,
              uid: 'runner-1',
              createdAt: DateTime(2026, 5, 6, 7, 1),
            ),
            buildEventParticipation(
              event: event,
              uid: 'runner-2',
              status: EventParticipationStatus.attended,
              createdAt: DateTime(2026, 5, 6, 7, 2),
            ),
            buildEventParticipation(
              event: event,
              uid: 'runner-3',
              status: EventParticipationStatus.waitlisted,
              createdAt: DateTime(2026, 5, 6, 7, 3),
            ),
          ]),
        ),
        eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        publicProfileRepositoryProvider.overrideWith(
          (ref) => fakePublicProfileRepository,
        ),
      ],
      signedInUid: 'host-1',
    );
    await _settleAttendanceSheet(tester);

    expect(fakePublicProfileRepository.lastRequestedUids, [
      'runner-1',
      'runner-2',
    ]);
    expect(find.text('1 / 2 checked in'), findsOneWidget);
    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('Kabir'), findsOneWidget);
    expect(find.text('ABSENT'), findsOneWidget);
    expect(find.text('CHECKED IN'), findsOneWidget);

    await tester.tap(find.text('Asha'));
    await tester.pump();

    expect(fakeEventRepository.markedAttendanceEventId, 'attendance-event');
    expect(fakeEventRepository.markedAttendanceUserId, 'runner-1');
  });
}

Future<void> _settleAttendanceSheet(WidgetTester tester) =>
    pumpFeatureUi(tester);
