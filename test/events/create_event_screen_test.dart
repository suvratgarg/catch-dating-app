import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/create_event_form_keys.dart';
import 'package:catch_dating_app/events/presentation/create_event_screen.dart';
import 'package:catch_dating_app/events/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:shared_preferences/shared_preferences.dart';

import '../test_pump_helpers.dart';
import 'events_test_helpers.dart';

void main() {
  group('CreateEventScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('validates the first step when basics are missing', (
      tester,
    ) async {
      await _pumpCreateEventFlow(tester);
      await _openCreateEventFlow(tester);

      await _tapPrimaryButton(tester, 'Next');
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Select a pace'), findsOneWidget);
    });

    testWidgets(
      'walks through the wizard, validates rules, submits, and pops',
      (tester) async {
        final fakeEventRepository = FakeEventRepository();
        await _pumpCreateEventFlow(
          tester,
          overrides: [
            eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          ],
        );
        await _openCreateEventFlow(tester);

        await _fillBasicsStep(tester);

        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Next');
        await tester.pump();
        expect(find.text('Required'), findsOneWidget);
        expect(find.text('Pin a starting point'), findsOneWidget);

        await _enterCreateEventText(
          tester,
          CreateEventFormKeys.meetingPoint,
          'Bandra Fort',
        );
        await _pickMapPoint(tester);
        await _enterCreateEventText(
          tester,
          CreateEventFormKeys.locationDetails,
          'Meet at the gate',
        );
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        await _pickFutureDate(tester);
        await _acceptInitialTime(tester);
        await tester.tap(find.byTooltip('Increase duration'));
        await tester.tap(find.byTooltip('Decrease duration'));
        await tester.pump();
        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        expect(find.text('Event policy'), findsOneWidget);
        await _enterCreateEventText(tester, CreateEventFormKeys.capacity, '18');
        await _enterCreateEventText(tester, CreateEventFormKeys.price, '249.5');
        await _tapAdmissionPreset(tester, 'fixedCohortCaps');
        await _enterCreateEventText(tester, CreateEventFormKeys.minAge, '40');
        await _enterCreateEventText(tester, CreateEventFormKeys.maxAge, '30');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Schedule event');
        await tester.pump();

        expect(find.text('<= max'), findsOneWidget);
        expect(find.text('>= min'), findsOneWidget);

        await _enterCreateEventText(tester, CreateEventFormKeys.minAge, '21');
        await _enterCreateEventText(tester, CreateEventFormKeys.maxAge, '35');
        await _enterCreateEventText(tester, CreateEventFormKeys.maxMen, '9');
        await _enterCreateEventText(tester, CreateEventFormKeys.maxWomen, '9');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Schedule event');
        await _pumpTestAnimation(tester);

        expect(find.text('Your event is live.'), findsOneWidget);
        expect(find.text('Manage event'), findsOneWidget);
        expect(
          find.textContaining('is now listed on Stride Social'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Followers can discover it from their home feed'),
          findsOneWidget,
        );
        expect(find.textContaining('visible to'), findsNothing);
        expect(fakeEventRepository.createdEvent, isNotNull);
        expect(fakeEventRepository.createdEvent!.clubId, 'club-1');
        expect(fakeEventRepository.createdEvent!.meetingPoint, 'Bandra Fort');
        expect(fakeEventRepository.createdEvent!.startingPointLat, 19.12345);
        expect(fakeEventRepository.createdEvent!.startingPointLng, 72.98765);
        expect(
          fakeEventRepository.createdEvent!.locationDetails,
          'Meet at the gate',
        );
        expect(fakeEventRepository.createdEvent!.distanceKm, 7.5);
        expect(fakeEventRepository.createdEvent!.capacityLimit, 18);
        expect(fakeEventRepository.createdEvent!.priceInPaise, 24950);
        expect(fakeEventRepository.createdEvent!.pace.name, 'moderate');
        expect(fakeEventRepository.createdEvent!.constraints.minAge, 21);
        expect(fakeEventRepository.createdEvent!.constraints.maxAge, 35);
        expect(fakeEventRepository.createdEvent!.constraints.maxMen, 9);
        expect(fakeEventRepository.createdEvent!.constraints.maxWomen, 9);
        expect(fakeEventRepository.createdEvent!.eventPolicy, isNotNull);
        expect(
          fakeEventRepository
              .createdEvent!
              .eventPolicy!
              .admissionPolicy
              .cohortCapacityLimits,
          {'menInterestedInWomen': 9, 'womenInterestedInMen': 9},
        );
        expect(
          fakeEventRepository.createdEvent!.eventPolicy!.cancellationPolicy.id,
          EventCancellationPolicyId.standard,
        );

        final manageRunButton = find.text('Manage event');
        await tester.ensureVisible(manageRunButton);
        await tester.tap(manageRunButton);
        await _pumpTestAnimation(tester);

        expect(find.text('HOST MANAGE'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await _pumpTestAnimation(tester);
        expect(find.text('Roster'), findsOneWidget);
      },
    );

    testWidgets(
      'shows the past-time validation, clears it on repick, and renders mixed durations',
      (tester) async {
        final now = DateTime(2026, 5, 1, 14);
        await _pumpCreateEventFlow(
          tester,
          alwaysUse24HourFormat: true,
          now: () => now,
        );
        await _openCreateEventFlow(tester);

        await _fillBasicsStep(tester);
        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        await _enterCreateEventText(
          tester,
          CreateEventFormKeys.meetingPoint,
          'Bandra Fort',
        );
        await _pickMapPoint(tester);
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        await tester.tap(find.byTooltip('Increase duration'));
        await tester.tap(find.byTooltip('Increase duration'));
        await tester.pump();

        expect(find.text('1h 30m'), findsOneWidget);

        await _pickTodayDate(tester, today: now);
        await _pickTimeInInputMode(tester, hour: '1', minute: '59');

        expect(find.text('Choose a start time later than now'), findsOneWidget);
        expect(find.text('Select start time'), findsOneWidget);

        await _pickFutureDate(tester);
        await _acceptInitialTime(tester);

        expect(find.text('Choose a start time later than now'), findsNothing);

        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        expect(find.text('Event policy'), findsOneWidget);
      },
    );

    testWidgets('picks a map location and handles back navigation', (
      tester,
    ) async {
      await _pumpCreateEventFlow(tester);
      await _openCreateEventFlow(tester);

      await _fillBasicsStep(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await tester.tap(find.byKey(CreateEventFormKeys.mapPicker));
      await _pumpTestAnimation(tester);

      final googleMap = tester.widget<gmaps.GoogleMap>(
        find.byType(gmaps.GoogleMap),
      );
      const selectedPoint = LocationCoordinate(19.12345, 72.98765);
      googleMap.onTap?.call(
        gmaps.LatLng(selectedPoint.latitude, selectedPoint.longitude),
      );
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await _pumpTestAnimation(tester);

      expect(find.text('Starting point pinned'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await _pumpTestAnimation(tester);
      expect(find.text('Event basics'), findsOneWidget);

      // Second back — unsaved changes dialog appears since we filled basics.
      await tester.tap(find.byTooltip('Back'));
      await _pumpTestAnimation(tester);
      await tester.tap(find.text('Discard'));
      await _pumpTestAnimation(tester);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('shows the submission error banner when creation fails', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository()
        ..createError = StateError('create failed');
      Object? uncaughtError;
      await _pumpCreateEventFlow(
        tester,
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        ],
      );
      await _openCreateEventFlow(tester);

      await runZonedGuarded(
        () async {
          await _submitValidEvent(tester);
        },
        (error, stackTrace) {
          uncaughtError = error;
        },
      );

      expect(uncaughtError, isA<StateError>());
      await tester.pump();

      expect(find.text('create failed'), findsOneWidget);
      expect(find.text('Schedule event'), findsOneWidget);
    });

    testWidgets('host manage roster renders public profile rows', (
      tester,
    ) async {
      final publicProfiles = FakePublicProfileRepository()
        ..profiles = [
          buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
          buildPublicProfile(uid: 'runner-3', name: 'Avery'),
        ];
      final participationRepository = FakeEventParticipationRepository();
      final event = buildEvent(
        priceInPaise: 10000,
        bookedCount: 1,
        waitlistedCount: 1,
      );
      participationRepository.eventParticipations[event.id] = [
        buildEventParticipation(event: event, uid: 'runner-2'),
        buildEventParticipation(
          event: event,
          uid: 'runner-3',
          status: EventParticipationStatus.waitlisted,
        ),
      ];

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(),
          event: event,
          onBackToSuccess: () {},
        ),
        overrides: [
          publicProfileRepositoryProvider.overrideWith((ref) => publicProfiles),
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => participationRepository,
          ),
        ],
      );
      await _pumpTestAnimation(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await _pumpTestAnimation(tester);

      expect(find.text('Taylor'), findsOneWidget);
      expect(find.text('Avery'), findsOneWidget);
      expect(find.text('runner-2'), findsNothing);
      expect(find.text('runner-3'), findsNothing);
      expect(find.text('PAID'), findsOneWidget);
      expect(find.text('WAITLIST'), findsOneWidget);
    });

    testWidgets('host manage exposes the live event success entry', (
      tester,
    ) async {
      final participationRepository = FakeEventParticipationRepository();

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(hostUserId: 'host-1'),
          event: buildEvent(id: 'event-preview'),
          onBackToSuccess: () {},
        ),
        overrides: [
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => participationRepository,
          ),
        ],
        signedInUid: 'host-1',
      );
      await _pumpHostActionFrame(tester);

      await tester.scrollUntilVisible(find.text('Event success'), 300);
      await _pumpHostActionFrame(tester);

      expect(find.text('Event success'), findsOneWidget);
      expect(find.text('Open event success'), findsOneWidget);
    });

    testWidgets('host manage confirms and cancels an active event', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository();
      final participationRepository = FakeEventParticipationRepository();
      final event = buildEvent(id: 'event-cancel', bookedCount: 1);

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(hostUserId: 'host-1'),
          event: event,
          onBackToSuccess: () {},
        ),
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => participationRepository,
          ),
        ],
        signedInUid: 'host-1',
      );
      await _pumpHostActionFrame(tester);

      final cancelButton = find.widgetWithText(CatchButton, 'Cancel event');
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await _pumpHostActionFrame(tester);

      expect(find.text('Cancel this event?'), findsOneWidget);
      await tester.tap(_dialogAction('Cancel event'));
      await _pumpHostActionFrame(tester);

      expect(fakeEventRepository.hostCancelledEventId, 'event-cancel');
      expect(find.text('Event cancelled.'), findsOneWidget);
    });

    testWidgets('host manage confirms and deletes an unused event', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository();
      final participationRepository = FakeEventParticipationRepository();
      final event = buildEvent(id: 'event-delete');
      var returned = false;

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(hostUserId: 'host-1'),
          event: event,
          onBackToSuccess: () => returned = true,
        ),
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => participationRepository,
          ),
        ],
        signedInUid: 'host-1',
      );
      await _pumpHostActionFrame(tester);

      final deleteButton = find.widgetWithText(CatchButton, 'Delete event');
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await _pumpHostActionFrame(tester);

      expect(find.text('Delete this event?'), findsOneWidget);
      await tester.tap(_dialogAction('Delete event'));
      await _pumpHostActionFrame(tester);

      expect(fakeEventRepository.deletedEventId, 'event-delete');
      expect(returned, isTrue);
    });

    testWidgets('host manage hides delete when event activity is visible', (
      tester,
    ) async {
      final participationRepository = FakeEventParticipationRepository();
      final event = buildEvent(id: 'event-with-activity', bookedCount: 1);

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(hostUserId: 'host-1'),
          event: event,
          onBackToSuccess: () {},
        ),
        overrides: [
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => participationRepository,
          ),
        ],
        signedInUid: 'host-1',
      );
      await _pumpHostActionFrame(tester);

      expect(find.widgetWithText(CatchButton, 'Delete event'), findsNothing);
      expect(
        find.textContaining('Delete is unavailable once an event has bookings'),
        findsOneWidget,
      );
    });

    testWidgets('draft picker deletes persisted drafts and resumes another', (
      tester,
    ) async {
      final draftRepository = EventDraftRepository(ErrorLogger());
      await draftRepository.saveDraft(
        userId: 'runner-1',
        draft: _buildEventDraft(
          id: 'keep-draft',
          savedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          distance: '9',
          capacity: '18',
          meetingPoint: 'Keep Point',
        ),
      );
      await draftRepository.saveDraft(
        userId: 'runner-1',
        draft: _buildEventDraft(
          id: 'delete-draft',
          savedAt: DateTime.now(),
          distance: '5',
          meetingPoint: 'Delete Point',
        ),
      );

      await _pumpCreateEventFlow(tester);
      await _openCreateEventFlow(tester);

      expect(find.text('Your drafts'), findsOneWidget);
      expect(find.textContaining('Delete Point'), findsOneWidget);
      expect(find.textContaining('Keep Point'), findsOneWidget);

      await tester.tap(
        find.byKey(CreateEventFormKeys.deleteDraft('delete-draft')),
      );
      await _pumpTestAnimation(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await _pumpTestAnimation(tester);

      final remainingDrafts = await draftRepository.loadDrafts(
        clubId: 'club-1',
        userId: 'runner-1',
      );
      expect(remainingDrafts.map((draft) => draft.id), ['keep-draft']);
      expect(find.textContaining('Delete Point'), findsNothing);
      expect(find.textContaining('Keep Point'), findsOneWidget);

      await tester.tap(find.textContaining('Keep Point'));
      await _pumpTestAnimation(tester);

      expect(find.text('Your drafts'), findsNothing);
      expect(find.text('9'), findsOneWidget);
    });
  });
}

EventDraft _buildEventDraft({
  required String id,
  required DateTime savedAt,
  String? distance,
  String? capacity,
  String? meetingPoint,
}) {
  return EventDraft(
    id: id,
    clubId: 'club-1',
    savedAt: savedAt,
    distance: distance,
    capacity: capacity,
    meetingPoint: meetingPoint,
  );
}

Future<void> _pumpCreateEventFlow(
  WidgetTester tester, {
  Iterable overrides = const [],
  bool alwaysUse24HourFormat = false,
  DateTime Function()? now,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: alwaysUse24HourFormat),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CreateEventScreen(
                        club: buildClub(),
                        loadMapTiles: false,
                        now: now ?? DateTime.now,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await _pumpTestAnimation(tester);
}

Future<void> _openCreateEventFlow(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await _pumpTestAnimation(tester);
}

Future<void> _submitValidEvent(WidgetTester tester) async {
  await _fillBasicsStep(tester);
  await _tapPrimaryButton(tester, 'Next');
  await _pumpTestAnimation(tester);

  await _enterCreateEventText(
    tester,
    CreateEventFormKeys.meetingPoint,
    'Bandra Fort',
  );
  await _pickMapPoint(tester);
  await _enterCreateEventText(
    tester,
    CreateEventFormKeys.locationDetails,
    'Meet at the gate',
  );
  await _pumpTestAnimation(tester);
  await _tapPrimaryButton(tester, 'Next');
  await _pumpTestAnimation(tester);

  await _pickFutureDate(tester);
  await _acceptInitialTime(tester);
  await _tapPrimaryButton(tester, 'Next');
  await _pumpTestAnimation(tester);

  await _enterCreateEventText(tester, CreateEventFormKeys.capacity, '18');
  await _enterCreateEventText(tester, CreateEventFormKeys.price, '249.5');
  await _tapAdmissionPreset(tester, 'fixedCohortCaps');
  await _enterCreateEventText(tester, CreateEventFormKeys.minAge, '21');
  await _enterCreateEventText(tester, CreateEventFormKeys.maxAge, '35');
  await _enterCreateEventText(tester, CreateEventFormKeys.maxMen, '9');
  await _enterCreateEventText(tester, CreateEventFormKeys.maxWomen, '9');
  await _pumpTestAnimation(tester);
  await _tapPrimaryButton(tester, 'Schedule event');
  await _pumpTestAnimation(tester);
}

Future<void> _pickMapPoint(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateEventFormKeys.mapPicker));
  await _pumpTestAnimation(tester);

  final googleMap = tester.widget<gmaps.GoogleMap>(
    find.byType(gmaps.GoogleMap),
  );
  const selectedPoint = LocationCoordinate(19.12345, 72.98765);
  googleMap.onTap?.call(
    gmaps.LatLng(selectedPoint.latitude, selectedPoint.longitude),
  );
  await tester.pump();
  await tester.tap(find.text('Confirm'));
  await _pumpTestAnimation(tester);
}

Future<void> _fillBasicsStep(WidgetTester tester) async {
  await _enterCreateEventText(tester, CreateEventFormKeys.distance, '7.5');
  await tester.tap(find.text('MODERATE'));
  await _enterCreateEventText(
    tester,
    CreateEventFormKeys.description,
    'Social pacing with a coffee stop.',
  );
  await _pumpTestAnimation(tester);
}

Future<void> _enterCreateEventText(
  WidgetTester tester,
  Key fieldKey,
  String text,
) async {
  final field = find.descendant(
    of: find.byKey(fieldKey),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field);
  await tester.pump();
  await tester.enterText(field, text);
}

Future<void> _tapAdmissionPreset(WidgetTester tester, String presetName) async {
  final finder = find.byKey(CreateEventFormKeys.admissionPreset(presetName));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await _pumpTestAnimation(tester);
}

Future<void> _tapPrimaryButton(WidgetTester tester, String label) async {
  await _dismissKeyboard(tester);
  final buttonFinder = find.widgetWithText(CatchButton, label);
  await tester.ensureVisible(buttonFinder);
  await tester.tap(buttonFinder);
  await _pumpTestAnimation(tester);
}

Future<void> _dismissKeyboard(WidgetTester tester) async {
  tester.testTextInput.hide();
  await tester.pump();
}

Future<void> _pickTodayDate(WidgetTester tester, {DateTime? today}) async {
  await tester.tap(find.byKey(CreateEventFormKeys.datePicker));
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('${(today ?? DateTime.now()).day}').hitTestable());
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('OK'));
  await _pumpTestAnimation(tester);
}

Future<void> _pickFutureDate(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateEventFormKeys.datePicker));
  await _pumpTestAnimation(tester);
  await tester.tap(find.byTooltip('Next month'));
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('1').hitTestable());
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('OK'));
  await _pumpTestAnimation(tester);
}

Future<void> _pickTimeInInputMode(
  WidgetTester tester, {
  required String hour,
  required String minute,
}) async {
  await tester.tap(find.byKey(CreateEventFormKeys.timePicker));
  await _pumpTestAnimation(tester);
  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await _pumpTestAnimation(tester);

  final timeFields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(EditableText),
  );
  await tester.enterText(timeFields.at(0), hour);
  await tester.enterText(timeFields.at(1), minute);
  await tester.tap(find.text('OK'));
  await _pumpTestAnimation(tester);
}

Future<void> _acceptInitialTime(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateEventFormKeys.timePicker));
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('OK'));
  await _pumpTestAnimation(tester);
}

Future<void> _pumpTestAnimation(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

Future<void> _pumpHostActionFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Finder _dialogAction(String label) {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text(label),
  );
}
