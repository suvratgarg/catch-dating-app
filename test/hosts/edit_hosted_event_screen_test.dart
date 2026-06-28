import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  test('HostEventEditState maps route provider states', () {
    final event = buildEvent();
    final club = buildClub();

    expect(
      HostEventEditState.resolve(
        uid: const AsyncLoading<String?>(),
        club: AsyncData(club),
        event: AsyncData(event),
      ).status,
      HostEventEditRouteStatus.loading,
    );

    expect(
      HostEventEditState.resolve(
        uid: const AsyncData<String?>('host-1'),
        club: AsyncError<Club?>(StateError('Club failed'), StackTrace.empty),
        event: AsyncData(event),
      ).status,
      HostEventEditRouteStatus.error,
    );

    expect(
      HostEventEditState.resolve(
        uid: const AsyncData<String?>('host-1'),
        club: const AsyncData(null),
        event: AsyncData(event),
      ).status,
      HostEventEditRouteStatus.notFound,
    );

    expect(
      HostEventEditState.resolve(
        uid: const AsyncData<String?>('guest-1'),
        club: AsyncData(club),
        event: AsyncData(event),
      ).status,
      HostEventEditRouteStatus.unauthorized,
    );

    expect(
      HostEventEditState.resolve(
        uid: const AsyncData<String?>('host-1'),
        club: AsyncData(club),
        event: AsyncData(event),
      ).status,
      HostEventEditRouteStatus.ready,
    );
  });

  test('HostEventEditState maps edit locks', () {
    final start = DateTime(2026, 5, 22, 7);
    final editable = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final booked = editable.copyWith(bookedCount: 1);
    final cancelled = editable.copyWith(
      status: EventLifecycleStatus.cancelled,
      cancelledAt: start.subtract(const Duration(days: 1)),
    );

    expect(
      HostEventEditState.eventScheduleLocked(
        editable,
        start.subtract(const Duration(days: 1)),
      ),
      isFalse,
    );
    expect(
      HostEventEditState.eventScheduleLocked(
        booked,
        start.subtract(const Duration(days: 1)),
      ),
      isTrue,
    );
    expect(HostEventEditState.eventCanEdit(cancelled), isFalse);
    expect(
      HostEventEditState.eventPolicyLocked(
        cancelled,
        start.subtract(const Duration(days: 1)),
      ),
      isTrue,
    );
  });

  testWidgets('saves host-editable event details through updateEvent', (
    tester,
  ) async {
    _setTallViewport(tester);

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

    expect(find.text('Edit event'), findsOneWidget);
    _expectBuiltText('Published event');
    _expectBuiltText('Schedule');
    expect(
      find.text(
        'You can edit schedule, location, event details, capacity, pricing, admission policy, and invite setup until the first booking or waitlist join.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    await _expectVisibleText(tester, 'Where');
    expect(find.text('Save changes'), findsOneWidget);

    await _enterText(tester, CreateEventFormKeys.meetingPoint, 'New gate');
    await _scrollToFinder(
      tester,
      find.byKey(CreateEventFormKeys.distance, skipOffstage: false),
    );
    expect(find.byType(CatchSelectChip, skipOffstage: false), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CatchField && widget.title == 'Cohort caps',
      ),
      findsOneWidget,
    );

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
    _setTallViewport(tester);

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

    _expectBuiltText('Schedule locked');
    expect(
      find.textContaining(
        'You can still update location and descriptive details',
        findRichText: true,
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(CreateEventFormKeys.datePicker, skipOffstage: false),
      findsNothing,
    );
    await _expectVisibleText(tester, event.timeRangeLabel);
    await _scrollToFinder(
      tester,
      find.byKey(CreateEventFormKeys.meetingPoint, skipOffstage: false),
    );
    expect(find.byKey(CreateEventFormKeys.meetingPoint), findsOneWidget);
  });

  testWidgets('validates required host-editable event fields before saving', (
    tester,
  ) async {
    _setTallViewport(tester);

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

    await _enterText(tester, CreateEventFormKeys.meetingPoint, '');
    await _enterText(tester, CreateEventFormKeys.distance, '');
    await tester.tap(find.byKey(EditHostedEventKeys.saveButton));
    await pumpFeatureUi(tester);

    expect(find.text('Required', skipOffstage: false), findsNWidgets(2));
    expect(repository.updatedEvent, isNull);
  });
}

void _setTallViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1800);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _enterText(WidgetTester tester, Key key, String value) async {
  await _scrollToFinder(tester, find.byKey(key, skipOffstage: false));
  final field = find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextField),
  );
  await tester.enterText(field, value);
  await tester.pump();
}

void _expectBuiltText(String text) {
  expect(find.text(text, skipOffstage: false), findsOneWidget);
}

Future<void> _expectVisibleText(WidgetTester tester, String text) async {
  await _scrollToFinder(tester, find.text(text, skipOffstage: false));
  expect(find.text(text), findsOneWidget);
}

Future<void> _scrollToFinder(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: findPrimaryScrollable(),
  );
  await tester.pump();
}
