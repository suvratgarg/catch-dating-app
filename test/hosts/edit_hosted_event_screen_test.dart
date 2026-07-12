import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_view_model.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
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
        uid: const CatchAsyncState<String?>.loading(),
        club: CatchAsyncState<Club?>.data(club),
        event: CatchAsyncState<Event?>.data(event),
      ).status,
      HostEventEditRouteStatus.loading,
    );

    expect(
      HostEventEditState.resolve(
        uid: const CatchAsyncState<String?>.data('host-1'),
        club: CatchAsyncState<Club?>.error(StateError('Club failed')),
        event: CatchAsyncState<Event?>.data(event),
      ).status,
      HostEventEditRouteStatus.error,
    );

    expect(
      HostEventEditState.resolve(
        uid: const CatchAsyncState<String?>.data('host-1'),
        club: const CatchAsyncState<Club?>.data(null),
        event: CatchAsyncState<Event?>.data(event),
      ).status,
      HostEventEditRouteStatus.notFound,
    );

    expect(
      HostEventEditState.resolve(
        uid: const CatchAsyncState<String?>.data('guest-1'),
        club: CatchAsyncState<Club?>.data(club),
        event: CatchAsyncState<Event?>.data(event),
      ).status,
      HostEventEditRouteStatus.unauthorized,
    );

    expect(
      HostEventEditState.resolve(
        uid: const CatchAsyncState<String?>.data('host-1'),
        club: CatchAsyncState<Club?>.data(club),
        event: CatchAsyncState<Event?>.data(event),
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

  test('HostEventEditScreenState maps save display and success policy', () {
    final start = DateTime(2026, 5, 22, 7);
    final editable = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final cancelled = editable.copyWith(
      status: EventLifecycleStatus.cancelled,
      cancelledAt: start.subtract(const Duration(days: 1)),
    );
    final error = StateError('Save failed');

    final ready = HostEventEditScreenState.from(
      event: editable,
      now: start.subtract(const Duration(days: 1)),
      savePending: false,
    );
    expect(ready.canEdit, isTrue);
    expect(ready.scheduleLocked, isFalse);
    expect(ready.policyLocked, isFalse);
    expect(ready.footer.label, 'Save changes');
    expect(ready.footer.isEnabled, isTrue);
    expect(ready.footer.isLoading, isFalse);
    expect(ready.saveOutcome.successMessage, 'Event updated.');
    expect(ready.saveOutcome.popRouteOnSuccess, isTrue);

    final pending = HostEventEditScreenState.from(
      event: editable,
      now: start.subtract(const Duration(days: 1)),
      savePending: true,
      saveError: error,
    );
    expect(pending.footer.isEnabled, isFalse);
    expect(pending.footer.isLoading, isTrue);
    expect(pending.saveError, same(error));
    expect(pending.hasSaveError, isTrue);

    final disabled = HostEventEditScreenState.from(
      event: cancelled,
      now: start.subtract(const Duration(days: 1)),
      savePending: false,
    );
    expect(disabled.canEdit, isFalse);
    expect(disabled.footer.isEnabled, isFalse);
    expect(disabled.scheduleLocked, isTrue);
    expect(disabled.policyLocked, isTrue);
  });

  test('HostEventEditSaveRequest builds unlocked save payload', () {
    final start = DateTime(2026, 5, 22, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      meetingPoint: 'Old gate',
      startingPointLat: 19.076,
      startingPointLng: 72.8777,
      description: 'Old description',
    );
    final nextStart = DateTime(2026, 5, 23, 8, 30);

    final request = HostEventEditSaveRequest.fromForm(
      event: event,
      scheduleLocked: false,
      policyLocked: false,
      selectedStartDateTime: nextStart,
      durationMinutes: 75,
      startingPoint: const LocationCoordinate(19.08, 72.88),
      meetingPoint: ' New gate ',
      meetingLocationAddress: ' Bandstand ',
      meetingLocationPlaceId: ' place-1 ',
      locationDetails: ' Blue gate ',
      distanceText: '7.5',
      selectedPace: PaceLevel.fast,
      description: ' Updated route notes ',
      capacityText: '30',
      priceText: '250',
      admissionPreset: EventAdmissionPreset.inviteOnly,
      cohortCapsEnabled: false,
      dynamicPricingEnabled: false,
      minAgeText: '24',
      maxAgeText: '40',
      maxMenText: '',
      maxWomenText: '',
      dynamicPricingStepText: '',
      dynamicPricingMaxText: '',
      cancellationPolicyId: EventCancellationPolicyId.flexible,
      inviteCodeText: ' SOCIAL2026 ',
    );

    expect(request.includePolicy, isTrue);
    expect(request.inviteCode, 'SOCIAL2026');
    expect(request.nextEvent.startTime, nextStart);
    expect(
      request.nextEvent.endTime,
      nextStart.add(const Duration(minutes: 75)),
    );
    expect(request.nextEvent.meetingPoint, 'New gate');
    expect(request.nextEvent.meetingLocation?.address, 'Bandstand');
    expect(request.nextEvent.meetingLocation?.placeId, 'place-1');
    expect(request.nextEvent.locationDetails, 'Blue gate');
    expect(request.nextEvent.distanceKm, 7.5);
    expect(request.nextEvent.pace, PaceLevel.fast);
    expect(request.nextEvent.description, 'Updated route notes');
    expect(request.nextEvent.capacityLimit, 30);
    expect(request.nextEvent.constraints.minAge, 24);
    expect(request.nextEvent.constraints.maxAge, 40);
    expect(request.nextEvent.effectiveEventPolicy.usesInviteOnly, isTrue);
  });

  test('HostEventEditSaveRequest preserves locked schedule and policy', () {
    final start = DateTime(2026, 5, 22, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      meetingPoint: 'Old gate',
      startingPointLat: 19.076,
      startingPointLng: 72.8777,
      description: 'Old description',
      capacityLimit: 18,
      priceInPaise: 50000,
    );

    final request = HostEventEditSaveRequest.fromForm(
      event: event,
      scheduleLocked: true,
      policyLocked: true,
      selectedStartDateTime: DateTime(2026, 5, 23, 8),
      durationMinutes: 90,
      startingPoint: const LocationCoordinate(19.08, 72.88),
      meetingPoint: 'New gate',
      meetingLocationAddress: null,
      meetingLocationPlaceId: null,
      locationDetails: '',
      distanceText: '9',
      selectedPace: PaceLevel.competitive,
      description: 'Updated route notes',
      capacityText: '40',
      priceText: '900',
      admissionPreset: EventAdmissionPreset.openCapacity,
      cohortCapsEnabled: true,
      dynamicPricingEnabled: true,
      minAgeText: '30',
      maxAgeText: '44',
      maxMenText: '10',
      maxWomenText: '10',
      dynamicPricingStepText: '250',
      dynamicPricingMaxText: '1500',
      cancellationPolicyId: EventCancellationPolicyId.strict,
      inviteCodeText: 'LOCKED',
    );

    expect(request.includePolicy, isFalse);
    expect(request.inviteCode, 'LOCKED');
    expect(request.nextEvent.startTime, event.startTime);
    expect(request.nextEvent.endTime, event.endTime);
    expect(request.nextEvent.capacityLimit, event.capacityLimit);
    expect(request.nextEvent.priceInPaise, event.priceInPaise);
    expect(request.nextEvent.eventPolicy, event.eventPolicy);
    expect(request.nextEvent.constraints, event.constraints);
    expect(request.nextEvent.meetingPoint, 'New gate');
    expect(request.nextEvent.description, 'Updated route notes');
  });

  test('HostEventEditPrivateAccessState maps invite-code seed policy', () {
    final access = EventPrivateAccess(
      id: 'private-access-1',
      eventId: 'event-1',
      clubId: 'club-1',
      inviteCode: ' SOCIAL2026 ',
      createdAt: DateTime(2026),
    );

    final firstLoad = buildHostEventEditPrivateAccessState(
      admissionPreset: EventAdmissionPreset.inviteOnly,
      loadedPrivateAccess: false,
      privateAccess: AsyncData(access),
    );
    expect(firstLoad.shouldWatch, isTrue);
    expect(firstLoad.shouldMarkLoaded, isTrue);
    expect(firstLoad.inviteCodeSeed, 'SOCIAL2026');
    expect(firstLoad.privateAccess.status, CatchAsyncStatus.data);

    final alreadyLoaded = buildHostEventEditPrivateAccessState(
      admissionPreset: EventAdmissionPreset.inviteOnly,
      loadedPrivateAccess: true,
      privateAccess: AsyncData(access),
    );
    expect(alreadyLoaded.shouldWatch, isTrue);
    expect(alreadyLoaded.shouldMarkLoaded, isFalse);
    expect(alreadyLoaded.inviteCodeSeed, isNull);

    final openCapacity = buildHostEventEditPrivateAccessState(
      admissionPreset: EventAdmissionPreset.openCapacity,
      loadedPrivateAccess: false,
      privateAccess: AsyncData(access),
    );
    expect(openCapacity.shouldWatch, isFalse);
    expect(openCapacity.shouldMarkLoaded, isFalse);
    expect(openCapacity.inviteCodeSeed, isNull);
  });

  test('HostEventEditLocationState maps selected location display', () {
    const coordinate = LocationCoordinate(19.08, 72.88);

    final ready = HostEventEditLocationState.from(
      canEdit: true,
      startingPoint: coordinate,
      meetingPoint: ' New gate ',
    );
    expect(ready.canPick, isTrue);
    expect(ready.startingPoint, coordinate);
    expect(ready.hasStartingPoint, isTrue);
    expect(ready.selectedLabel, 'New gate');
    expect(ready.pickerInitialLabel, 'New gate');

    final empty = HostEventEditLocationState.from(
      canEdit: false,
      startingPoint: null,
      meetingPoint: ' ',
    );
    expect(empty.canPick, isFalse);
    expect(empty.hasStartingPoint, isFalse);
    expect(empty.selectedLabel, isEmpty);
    expect(empty.pickerInitialLabel, isNull);
  });

  test('HostEventEditFieldDisplayState maps form field display values', () {
    final state = HostEventEditFieldDisplayState.fromForm(
      canEdit: true,
      scheduleLocked: false,
      selectedDate: DateTime(2026, 5, 22),
      selectedStartTime: const TimeOfDay(hour: 7, minute: 30),
      durationMinutes: 75,
      scheduleErrorText: 'Event start must be in the future.',
      isDistanceBased: true,
      startingPoint: const LocationCoordinate(19.08, 72.88),
      meetingPoint: ' New gate ',
      locationDetails: ' Blue gate ',
      distanceText: '7.5',
      selectedPace: PaceLevel.fast,
      description: ' Updated route notes ',
      currencyCode: 'INR',
      admissionPreset: EventAdmissionPreset.balancedSingles,
      cohortCapsEnabled: false,
      dynamicPricingEnabled: true,
      cancellationPolicyId: EventCancellationPolicyId.flexible,
    );

    expect(state.schedule.dateValue, '22/05/2026');
    expect(state.schedule.startTimeValue, '7:30 AM');
    expect(state.schedule.durationMinutes, 75);
    expect(state.schedule.errorText, 'Event start must be in the future.');
    expect(state.locationDetails.location.selectedLabel, 'New gate');
    expect(state.locationDetails.location.pickerInitialLabel, 'New gate');
    expect(state.locationDetails.isDistanceBased, isTrue);
    expect(state.locationDetails.distanceText, '7.5');
    expect(state.locationDetails.selectedPace, PaceLevel.fast);
    expect(state.policy.currencyCode, 'INR');
    expect(state.policy.admissionPreset, EventAdmissionPreset.balancedSingles);
    expect(state.policy.showDynamicPricingToggle, isTrue);
    expect(state.policy.showDynamicPricingFields, isTrue);
    expect(state.policy.showCohortCapsToggle, isFalse);
    expect(state.policy.cancellationSummary, isNotEmpty);
  });

  test('HostEventEditScheduleValidationState maps start-time validation', () {
    final now = DateTime(2026, 5, 22, 7);

    final future = HostEventEditScheduleValidationState.from(
      scheduleLocked: false,
      selectedStartDateTime: now.add(const Duration(hours: 1)),
      now: now,
      invalidScheduleMessage: 'Event start must be in the future.',
    );
    expect(future.isValid, isTrue);
    expect(future.errorText, isNull);

    final past = HostEventEditScheduleValidationState.from(
      scheduleLocked: false,
      selectedStartDateTime: now.subtract(const Duration(minutes: 1)),
      now: now,
      invalidScheduleMessage: 'Event start must be in the future.',
    );
    expect(past.isValid, isFalse);
    expect(past.errorText, 'Event start must be in the future.');

    final locked = HostEventEditScheduleValidationState.from(
      scheduleLocked: true,
      selectedStartDateTime: now.subtract(const Duration(days: 1)),
      now: now,
      invalidScheduleMessage: 'Event start must be in the future.',
    );
    expect(locked.isValid, isTrue);
    expect(locked.errorText, isNull);
  });

  test('HostEventEdit intents carry typed callback payloads', () {
    expect(const HostEventEditDurationChangedIntent(75).durationMinutes, 75);
    expect(const HostEventEditMeetingPointChangedIntent('Gate').value, 'Gate');
    expect(
      const HostEventEditPaceChangedIntent(PaceLevel.fast).pace,
      PaceLevel.fast,
    );
    expect(
      const HostEventEditAdmissionPresetChangedIntent(
        EventAdmissionPreset.inviteOnly,
      ).preset,
      EventAdmissionPreset.inviteOnly,
    );
    expect(const HostEventEditCohortCapsChangedIntent(true).enabled, isTrue);
    expect(
      const HostEventEditDynamicPricingChangedIntent(true).enabled,
      isTrue,
    );
    expect(
      const HostEventEditCancellationPolicyChangedIntent(
        EventCancellationPolicyId.strict,
      ).policyId,
      EventCancellationPolicyId.strict,
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
    expect(find.byType(CatchChip, skipOffstage: false), findsWidgets);
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
