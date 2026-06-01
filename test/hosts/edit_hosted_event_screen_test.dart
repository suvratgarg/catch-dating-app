import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/presentation/create_event_form_keys.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('saves host-editable event details through updateEvent', (
    tester,
  ) async {
    final start = DateTime(2026, 5, 22, 7);
    final event = buildEvent(
      id: 'hosted-event',
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      meetingPoint: 'Old gate',
      startingPointLat: 19.076,
      startingPointLng: 72.8777,
      description: 'Old description',
    );
    final repository = FakeEventRepository();

    await pumpEventsTestApp(
      tester,
      EditHostedEventScreen(
        club: buildClub(id: event.clubId),
        event: event,
        now: () => DateTime(2026, 5, 21, 9),
      ),
      signedInUid: 'host-1',
      overrides: [eventRepositoryProvider.overrideWith((ref) => repository)],
    );

    expect(find.text('Published event'), findsOneWidget);
    expect(
      find.textContaining(
        'capacity, pricing, admission policy, and invite setup until the first booking',
        findRichText: true,
      ),
      findsOneWidget,
    );

    await _enterText(tester, CreateEventFormKeys.meetingPoint, 'New gate');
    await _enterText(tester, CreateEventFormKeys.distance, '7.5');
    await _enterText(
      tester,
      CreateEventFormKeys.description,
      'Updated route notes',
    );

    await tester.tap(find.byKey(EditHostedEventKeys.saveButton));
    await pumpFeatureUi(tester);

    expect(repository.updatedEvent, isNotNull);
    expect(repository.updatedEvent!.id, 'hosted-event');
    expect(repository.updatedEvent!.meetingPoint, 'New gate');
    expect(repository.updatedEvent!.distanceKm, 7.5);
    expect(repository.updatedEvent!.description, 'Updated route notes');
    expect(repository.updatedEvent!.startingPointLat, 19.076);
    expect(repository.updatedEvent!.startingPointLng, 72.8777);
  });

  testWidgets('locks schedule controls when the event has activity', (
    tester,
  ) async {
    final start = DateTime(2026, 5, 22, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      startingPointLat: 19.076,
      startingPointLng: 72.8777,
      bookedCount: 1,
    );

    await pumpEventsTestApp(
      tester,
      EditHostedEventScreen(
        club: buildClub(id: event.clubId),
        event: event,
        now: () => DateTime(2026, 5, 21, 9),
      ),
      signedInUid: 'host-1',
    );

    expect(find.text('Schedule locked'), findsOneWidget);
    expect(
      find.textContaining(
        'You can still update location and descriptive details',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.byKey(CreateEventFormKeys.datePicker), findsNothing);
    expect(find.text(event.timeRangeLabel), findsOneWidget);
    expect(find.byKey(CreateEventFormKeys.meetingPoint), findsOneWidget);
  });
}

Future<void> _enterText(WidgetTester tester, Key key, String value) async {
  final field = find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field);
  await tester.pump();
  await tester.enterText(field, value);
  await tester.pump();
}
