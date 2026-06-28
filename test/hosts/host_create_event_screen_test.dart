import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_success_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/locations/data/places_repository.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:shared_preferences/shared_preferences.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

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

        expect(find.byType(CatchSelectChip), findsWidgets);
        await _fillBasicsStep(tester);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is CatchSelectChip &&
                widget.label == 'Moderate' &&
                widget.active,
          ),
          findsOneWidget,
        );

        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Next');
        await tester.pump();
        expect(find.text('Choose a meeting location'), findsOneWidget);

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
        expect(_fieldToggle('Cohort caps'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is CatchSelectChip &&
                widget.label == 'OPEN' &&
                widget.active,
          ),
          findsOneWidget,
        );
        await _enterCreateEventText(tester, CreateEventFormKeys.capacity, '18');
        await _enterCreateEventText(tester, CreateEventFormKeys.price, '249.5');
        await _enterCreateEventText(tester, CreateEventFormKeys.minAge, '40');
        await _enterCreateEventText(tester, CreateEventFormKeys.maxAge, '30');
        await _pumpTestAnimation(tester);
        expect(find.text('Live event guide'), findsNothing);
        expect(find.text('Host goal'), findsNothing);
        expect(find.text('Schedule event'), findsNothing);

        await _tapPrimaryButton(tester, 'Next');
        await tester.pump();

        expect(find.text('<= max'), findsOneWidget);
        expect(find.text('>= min'), findsOneWidget);

        await _enterCreateEventText(tester, CreateEventFormKeys.minAge, '21');
        await _enterCreateEventText(tester, CreateEventFormKeys.maxAge, '35');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        expect(find.text('Live event guide'), findsWidgets);
        expect(
          find.textContaining('Prepare the host guide for this event'),
          findsOneWidget,
        );

        await _tapPrimaryButton(tester, 'Schedule event');
        await _pumpTestAnimation(tester);

        expect(find.text('Your event is live.'), findsOneWidget);
        expect(find.text('Manage event'), findsOneWidget);
        expect(
          find.textContaining('is now listed on Stride Social'),
          findsOneWidget,
        );
        expect(
          find.textContaining('People can discover it from their home feed'),
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
        expect(fakeEventRepository.createdEvent!.constraints.maxMen, isNull);
        expect(fakeEventRepository.createdEvent!.constraints.maxWomen, isNull);
        expect(fakeEventRepository.createdEvent!.eventPolicy, isNotNull);
        expect(
          fakeEventRepository
              .createdEvent!
              .eventPolicy!
              .admissionPolicy
              .cohortCapacityLimits,
          isEmpty,
        );
        expect(
          fakeEventRepository.createdEvent!.eventPolicy!.cancellationPolicy.id,
          EventCancellationPolicyId.standard,
        );

        final manageRunButton = find.text('Manage event');
        await tester.ensureVisible(manageRunButton);
        await tester.tap(manageRunButton);
        await _pumpTestAnimation(tester);

        expect(find.text('STRIDE SOCIAL'), findsOneWidget);
        expect(find.text('SETUP'), findsWidgets);
      },
    );

    testWidgets('live guide uses capacity-aware pub quiz team plan', (
      tester,
    ) async {
      await _pumpCreateEventFlow(
        tester,
        clubOverride: buildClub(name: 'Saket Run Club').copyWith(
          hostDefaults: ClubHostDefaults(
            primaryActivityKind: ActivityKind.pubQuiz,
            eventSuccess: EventSuccessDefaults.recommendedForActivity(
              ActivityKind.pubQuiz,
              enabled: true,
              targetAttendeeCount: 50,
            ),
          ),
        ),
      );
      await _openCreateEventFlow(tester);

      await _enterCreateEventText(
        tester,
        CreateEventFormKeys.description,
        'Trivia with balanced teams.',
      );
      await _pumpTestAnimation(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await _enterCreateEventText(
        tester,
        CreateEventFormKeys.meetingPoint,
        'Quiz hall',
      );
      await _pickMapPoint(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await _pickFutureDate(tester);
      await _acceptInitialTime(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await _enterCreateEventText(tester, CreateEventFormKeys.capacity, '50');
      await _enterCreateEventText(tester, CreateEventFormKeys.price, '0');
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      expect(find.textContaining('about 10 teams'), findsWidgets);
      expect(
        find.textContaining('If 50 attend, Catch suggests 10 teams of 5.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('If 37 check in, expect 8 teams of 4-5.'),
        findsOneWidget,
      );
      expect(find.textContaining('3 teams'), findsNothing);
      expect(find.text('Advanced', skipOffstage: false), findsOneWidget);
      expect(
        find.text(
          'Optional extras you opt into intentionally.',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(
        find.text('Match clue questions', skipOffstage: false),
        findsNothing,
      );
      expect(
        find.text('"Help me say hi" requests', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Suggested first-message openers', skipOffstage: false),
        findsOneWidget,
      );

      expect(
        find.text('Team reveal countdown', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Rotation cadence', skipOffstage: false), findsNothing);
    });

    testWidgets('custom event format persists label and structure', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository();
      await _pumpCreateEventFlow(
        tester,
        clubOverride: buildClub().copyWith(
          hostDefaults: ClubHostDefaults(
            eventSuccess: EventSuccessDefaults.recommendedForActivity(
              ActivityKind.openActivity,
              enabled: true,
              targetAttendeeCount: 24,
            ),
          ),
        ),
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        ],
      );
      await _openCreateEventFlow(tester);

      await _tapActivityKind(tester, 'Open activity');
      await _pumpTestAnimation(tester);
      await _enterCreateEventText(
        tester,
        CreateEventFormKeys.customActivityLabel,
        'Salsa night',
      );
      final pairedRotationsChip = find.byKey(
        CreateEventFormKeys.interactionModel(
          EventInteractionModel.pairedRotations.name,
        ),
        skipOffstage: false,
      );
      await tester.ensureVisible(pairedRotationsChip);
      await tester.tap(pairedRotationsChip);
      await _enterCreateEventText(
        tester,
        CreateEventFormKeys.description,
        'Beginner-friendly partner rotations.',
      );
      await _pumpTestAnimation(tester);

      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);
      await _enterCreateEventText(
        tester,
        CreateEventFormKeys.meetingPoint,
        'Dance studio',
      );
      await _pickMapPoint(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await _pickFutureDate(tester);
      await _acceptInitialTime(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await _enterCreateEventText(tester, CreateEventFormKeys.capacity, '24');
      await _enterCreateEventText(tester, CreateEventFormKeys.price, '0');
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);
      await _tapPrimaryButton(tester, 'Schedule event');
      await _pumpTestAnimation(tester);

      final created = fakeEventRepository.createdEvent;
      expect(created, isNotNull);
      expect(created!.eventFormat.activityKind, ActivityKind.openActivity);
      expect(created.eventFormat.label, 'Salsa night');
      expect(
        created.eventFormat.interactionModel,
        EventInteractionModel.pairedRotations,
      );
      expect(created.eventFormat.defaultPlaybookId, isNull);
      expect(created.eventFormat.activityDetails['formatSource'], 'custom');
      expect(created.distanceKm, 0);
      final defaults = fakeEventRepository.createdEventSuccessDefaults
          ?.toJson();
      final structure = defaults?['structureConfig'] as Map<String, Object?>?;
      expect(defaults, isNotNull);
      expect(defaults!['playbookId'], 'pickleball_rotations');
      expect(structure?['unitKind'], 'pairs');
      expect(defaults['selectedModuleIds'], contains('guided_rotations'));
      expect(defaults['selectedModuleIds'], contains('live_reveal'));
    });

    testWidgets(
      'invite-only creation copy says the event is listed but booking-gated',
      (tester) async {
        final event = buildEvent(
          id: 'event-private',
          capacityLimit: 12,
          eventPolicy: EventPolicyBundle.inviteOnlyEvent(
            capacityLimit: 12,
            basePriceInPaise: 0,
          ),
        );

        await pumpEventsTestApp(
          tester,
          CreateEventSuccessScreen(
            club: buildClub(),
            event: event,
            inviteCode: 'CATCH-DELHI',
            onManageEvent: () {},
            onDone: () {},
          ),
        );

        expect(find.text('Your event is live.'), findsOneWidget);
        expect(find.text('EVENT CREATED'), findsOneWidget);
        expect(find.byIcon(CatchIcons.celebration), findsOneWidget);
        expect(
          find.textContaining('is now listed on Stride Social'),
          findsOneWidget,
        );
        expect(find.textContaining('People can discover it'), findsOneWidget);
        expect(
          find.textContaining(
            'only attendees with the invite code or private link can book',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('Followers can discover it from their home feed'),
          findsNothing,
        );
        expect(find.text('WHEN'), findsOneWidget);
        expect(find.text('WHERE'), findsOneWidget);
        expect(find.text('Carter Road'), findsOneWidget);
        expect(find.text('EVENT'), findsOneWidget);
        expect(find.text('5 km easy social run'), findsOneWidget);
        expect(find.text('CAPACITY'), findsOneWidget);
        expect(find.text('12 attendees'), findsOneWidget);
        expect(find.text('INVITE CODE'), findsOneWidget);
        expect(find.text('CATCH-DELHI'), findsOneWidget);
        expect(find.text('PRIVATE LINK'), findsOneWidget);
        expect(
          find.text(
            'https://catchdates.com/clubs/club-1/events/event-private?invite=CATCH-DELHI',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Bookings, waitlist, and attendance are tracked from Manage event.',
          ),
          findsOneWidget,
        );
        expect(find.text('Manage event'), findsOneWidget);
        expect(find.text('Back to club'), findsOneWidget);
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
      await tester.tap(find.widgetWithText(CatchButton, 'Confirm location'));
      await _pumpTestAnimation(tester);

      expect(find.text('Pinned location'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await _pumpTestAnimation(tester);
      expect(find.text('Event basics'), findsOneWidget);

      // Second back — unsaved changes dialog appears since we filled basics.
      await tester.tap(find.byTooltip('Back'));
      await _pumpTestAnimation(tester);
      await tester.tap(_dialogAction('Save draft'));
      await _pumpTestAnimation(tester);
      expect(find.text('Draft saved'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('fills the location name from a Google place selection', (
      tester,
    ) async {
      await _pumpCreateEventFlow(
        tester,
        overrides: [
          placesRepositoryProvider.overrideWithValue(
            const _FakePlacesRepository(
              suggestions: [
                PlaceAutocompleteSuggestion(
                  placeId: 'cubbon-park',
                  description: 'Cubbon Park, Bengaluru, Karnataka',
                  mainText: 'Cubbon Park',
                  secondaryText: 'Bengaluru, Karnataka',
                ),
              ],
              placeDetails: PlaceDetails(
                placeId: 'cubbon-park',
                displayName: 'Cubbon Park',
                formattedAddress: 'Cubbon Park, Bengaluru, Karnataka',
                location: LocationCoordinate(12.9763, 77.5929),
              ),
            ),
          ),
        ],
      );
      await _openCreateEventFlow(tester);

      await _fillBasicsStep(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await tester.tap(find.byKey(CreateEventFormKeys.mapPicker));
      await _pumpTestAnimation(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Search for a meeting point'),
        'Cubbon',
      );
      await pumpFeatureUiFor(tester, const Duration(milliseconds: 350));
      await tester.pump();
      await tester.tap(find.text('Cubbon Park'));
      await tester.pump();
      await tester.tap(find.widgetWithText(CatchButton, 'Confirm location'));
      await _pumpTestAnimation(tester);

      expect(find.text('Cubbon Park'), findsWidgets);
      final nameField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(CreateEventFormKeys.meetingPoint),
          matching: find.byType(TextField),
        ),
      );
      expect(nameField.controller?.text, 'Cubbon Park');
    });

    testWidgets('shows the submission error banner when creation fails', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository()
        ..createError = StateError('create failed');
      await _pumpCreateEventFlow(
        tester,
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        ],
      );
      await _openCreateEventFlow(tester);

      await _submitValidEvent(tester);

      expect(find.text('create failed'), findsOneWidget);
      expect(find.text('Schedule event'), findsOneWidget);
    });

    testWidgets('keeps create-event backend diagnostics out of the banner', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository()
        ..createError = const BackendOperationException(
          code: 'invalid-argument',
          message: 'Unable to create event right now. Please try again.',
          debugMessage:
              'functions.create event failed with firebase_functions/'
              'invalid-argument: eventSuccessDefaults: must NOT have '
              'additional properties',
          context: BackendErrorContext(
            service: BackendService.functions,
            action: 'create event',
            resource: 'events',
          ),
        );
      await _pumpCreateEventFlow(
        tester,
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        ],
      );
      await _openCreateEventFlow(tester);

      await _submitValidEvent(tester);

      expect(
        find.text('Unable to create event right now. Please try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('[DEBUG]'), findsNothing);
      expect(find.textContaining('firebase_functions'), findsNothing);
      expect(find.textContaining('additional properties'), findsNothing);
      expect(find.text('Schedule event'), findsOneWidget);
    });

    testWidgets('host manage roster renders public profile rows', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 3000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

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
          initialSection: HostEventManageSection.guests,
        ),
        overrides: [
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          publicProfileRepositoryProvider.overrideWith((ref) => publicProfiles),
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => participationRepository,
          ),
        ],
      );
      await _pumpTestAnimation(tester);

      await tester.scrollUntilVisible(
        find.text('Taylor'),
        300,
        scrollable: _hostManageScrollable(),
      );
      await _pumpTestAnimation(tester);

      expect(find.text('Taylor'), findsOneWidget);
      expect(find.text('Avery'), findsOneWidget);
      expect(find.text('runner-2'), findsNothing);
      expect(find.text('runner-3'), findsNothing);
      expect(find.textContaining('Booked'), findsWidgets);
      expect(find.textContaining('Waitlist'), findsWidgets);
    });

    testWidgets('host manage exposes lifecycle workspace sections', (
      tester,
    ) async {
      final participationRepository = FakeEventParticipationRepository();

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(),
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

      expect(find.text('SETUP'), findsOneWidget);
      expect(find.text('GUESTS'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('REPORT'), findsOneWidget);
      expect(find.text('Event success'), findsNothing);
      expect(find.text('Open event success'), findsNothing);
    });

    testWidgets('host manage live uses compact check-in workspace', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 2200);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final participationRepository = FakeEventParticipationRepository();
      final publicProfiles = FakePublicProfileRepository()
        ..profiles = [
          buildPublicProfile(name: 'Harsh'),
          buildPublicProfile(uid: 'runner-2', name: 'Manan'),
        ];
      final event = buildEvent(
        id: 'event-live-roster',
        bookedCount: 2,
        checkedInCount: 1,
        eventFormat: EventFormatSnapshot.fromActivityKind(
          ActivityKind.pickleball,
        ),
      );
      participationRepository.eventParticipations[event.id] = [
        buildEventParticipation(
          event: event,
          uid: 'runner-1',
          status: EventParticipationStatus.attended,
        ),
        buildEventParticipation(event: event, uid: 'runner-2'),
      ];
      final plan = EventSuccessPlan.defaultForEvent(
        event,
      ).copyWith(status: EventSuccessPlanStatus.live);

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(),
          event: event,
          onBackToSuccess: () {},
          initialSection: HostEventManageSection.live,
        ),
        overrides: [
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => participationRepository,
          ),
          publicProfileRepositoryProvider.overrideWith((ref) => publicProfiles),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(plan)),
          watchEventSuccessAssignmentsProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(const [])),
          watchEventSuccessRotationAssignmentsProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(const [])),
          watchEventSuccessPreferencesProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(const [])),
          watchEventSuccessWingmanRequestsProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(const [])),
        ],
        signedInUid: 'host-1',
      );
      await _pumpHostActionFrame(tester);
      await _pumpTestAnimation(tester);

      expect(find.text('LIVE NOW'), findsOneWidget);
      expect(find.text('Check guests in'), findsOneWidget);
      expect(find.text('1 of 2 arrived'), findsOneWidget);
      expect(find.text('Editable roster'), findsNothing);
      expect(find.text('GUEST'), findsNothing);
      expect(find.text('STATUS'), findsNothing);
      expect(find.text('HOST ACTION'), findsNothing);
      expect(find.text('Harsh'), findsNothing);
      expect(find.text('Manan'), findsNothing);
      expect(find.text('Host check-in QR'), findsNothing);
      expect(find.text('Live attendance'), findsNothing);
      expect(find.text('Needs check-in'), findsNothing);
      expect(find.text('Recently checked in'), findsNothing);
      expect(
        find.textContaining('Tap a booked participant to toggle check-in'),
        findsNothing,
      );
      expect(find.text('Arrival check-in'), findsNothing);
    });

    testWidgets('host manage omits duplicated demand pricing stat strip', (
      tester,
    ) async {
      final participationRepository = FakeEventParticipationRepository();
      final event = buildEvent(
        id: 'event-demand',
        bookedCount: 3,
        priceInPaise: 40000,
        eventPolicy: EventPolicyBundle.demandPricedBalancedSinglesEvent(
          capacityLimit: 20,
          basePriceInPaise: 40000,
          stepAdjustmentInPaise: 20000,
          maxAdjustmentInPaise: 100000,
        ),
      );

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(),
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

      expect(find.text('Base est.'), findsNothing);
      expect(find.text('Revenue'), findsNothing);
      expect(find.text('₹1,200'), findsNothing);
      expect(
        find.textContaining('Demand-priced bookings may settle higher'),
        findsNothing,
      );
      expect(find.text('SETUP'), findsOneWidget);
    });

    testWidgets('host manage exposes invite code and private link', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository();
      final participationRepository = FakeEventParticipationRepository();
      final event = buildEvent(
        id: 'event-private',
        eventPolicy: EventPolicyBundle.inviteOnlyEvent(
          capacityLimit: 12,
          basePriceInPaise: 0,
        ),
      );
      fakeEventRepository.privateAccessByEventId[event.id] = EventPrivateAccess(
        id: event.id,
        eventId: event.id,
        clubId: event.clubId,
        inviteCode: 'CATCH-DELHI',
        createdAt: DateTime(2026, 5),
      );

      await pumpEventsTestApp(
        tester,
        HostEventManageScreen(
          club: buildClub(),
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

      await tester.scrollUntilVisible(find.text('Private access'), 300);
      await _pumpHostActionFrame(tester);

      expect(find.text('Private access'), findsOneWidget);
      expect(find.text('CATCH-DELHI'), findsOneWidget);
      expect(find.textContaining('This event can stay listed'), findsOneWidget);
      expect(find.textContaining('?invite=CATCH-DELHI'), findsOneWidget);
      expect(
        find.widgetWithText(CatchButton, 'Share private link'),
        findsOneWidget,
      );
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
          club: buildClub(),
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

      final cancelButton = find.text('Cancel event');
      await tester.scrollUntilVisible(cancelButton, 300);
      await _pumpHostActionFrame(tester);
      await tester.tap(cancelButton.hitTestable());
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
          club: buildClub(),
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

      final deleteButton = find.text('Delete unused event');
      await tester.scrollUntilVisible(deleteButton, 300);
      await _pumpHostActionFrame(tester);
      await tester.tap(deleteButton);
      await _pumpHostActionFrame(tester);

      expect(find.text('Delete unused event?'), findsOneWidget);
      await tester.tap(_dialogAction('Delete unused event'));
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
          club: buildClub(),
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

      expect(find.text('Delete unused event'), findsNothing);
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

      expect(find.text('Resume a draft?'), findsOneWidget);
      expect(find.textContaining('Delete Point'), findsOneWidget);
      expect(find.textContaining('Keep Point'), findsOneWidget);

      await tester.tap(
        find.byKey(CreateEventFormKeys.deleteDraft('delete-draft')),
      );
      await _pumpTestAnimation(tester);
      await tester.tap(_dialogAction('Delete'));
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

      expect(find.text('Resume a draft?'), findsNothing);
      expect(find.text('9'), findsOneWidget);
    });
  });
}

Finder _fieldToggle(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == label,
  );
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

class _FakePlacesRepository implements PlacesRepository {
  const _FakePlacesRepository({
    required this.suggestions,
    required this.placeDetails,
  });

  final List<PlaceAutocompleteSuggestion> suggestions;
  final PlaceDetails placeDetails;

  @override
  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required String sessionToken,
    LocationCoordinate? bias,
    String? countryIsoCode,
  }) async {
    return suggestions;
  }

  @override
  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) async {
    return placeDetails;
  }
}

Future<void> _pumpCreateEventFlow(
  WidgetTester tester, {
  Iterable overrides = const [],
  bool alwaysUse24HourFormat = false,
  DateTime Function()? now,
  Club? clubOverride,
}) async {
  final club = clubOverride ?? buildClub();
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push('/create-event-test'),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/create-event-test',
        builder: (context, state) => CreateEventScreen(
          club: club,
          loadMapTiles: false,
          now: now ?? DateTime.now,
        ),
      ),
      GoRoute(
        path: Routes.hostAppEventManageScreen.path,
        name: Routes.hostAppEventManageScreen.name,
        builder: (context, state) => HostEventManageScreen(
          club: club,
          event: switch (state.extra) {
            final Event event => event,
            _ => buildEvent(clubId: club.id),
          },
          onBackToSuccess: () => context.pop(),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
        ...overrides,
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: alwaysUse24HourFormat),
          child: child!,
        ),
        routerConfig: router,
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
  await _enterCreateEventText(tester, CreateEventFormKeys.minAge, '21');
  await _enterCreateEventText(tester, CreateEventFormKeys.maxAge, '35');
  await _pumpTestAnimation(tester);
  await _tapPrimaryButton(tester, 'Next');
  await _pumpTestAnimation(tester);
  await _tapPrimaryButton(tester, 'Schedule event');
  await _pumpTestAnimation(tester);
}

Future<void> _pickMapPoint(WidgetTester tester) async {
  final mapPicker = find.byKey(
    CreateEventFormKeys.mapPicker,
    skipOffstage: false,
  );
  await Scrollable.ensureVisible(tester.element(mapPicker), alignment: 0.25);
  await tester.pump();
  await tester.tap(mapPicker);
  await _pumpTestAnimation(tester);

  final googleMap = tester.widget<gmaps.GoogleMap>(
    find.byType(gmaps.GoogleMap),
  );
  const selectedPoint = LocationCoordinate(19.12345, 72.98765);
  googleMap.onTap?.call(
    gmaps.LatLng(selectedPoint.latitude, selectedPoint.longitude),
  );
  await tester.pump();
  await tester.tap(find.widgetWithText(CatchButton, 'Confirm location'));
  await _pumpTestAnimation(tester);
}

Future<void> _fillBasicsStep(WidgetTester tester) async {
  await _enterCreateEventText(tester, CreateEventFormKeys.distance, '7.5');
  await _tapCreateEventChip(tester, 'Moderate');
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
  tester.testTextInput.hide();
  await tester.pump();

  final field = find.byKey(fieldKey);
  await tester.ensureVisible(field);

  final catchField = tester.widget<CatchField>(field);
  final fieldTitle = catchField.title;
  final tapTarget = fieldTitle == null
      ? field
      : find.descendant(of: field, matching: find.text(fieldTitle)).first;
  await tester.tap(tapTarget);
  await tester.pump();

  final textField = find.descendant(
    of: field,
    matching: find.byType(TextField),
  );
  await tester.enterText(textField, text);
  tester.testTextInput.hide();
  await tester.pump();
}

Future<void> _tapActivityKind(WidgetTester tester, String label) async {
  await _tapCreateEventChip(tester, label);
}

Future<void> _tapCreateEventChip(WidgetTester tester, String label) async {
  final finder = find.byWidgetPredicate(
    (widget) =>
        (widget is CatchSelectChip && widget.label == label) ||
        (widget is CatchChip && widget.label == label),
    description: 'selectable chip labeled $label',
    skipOffstage: false,
  );
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
  await tester.tap(find.byIcon(CatchIcons.keyboardOutlined));
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
  await pumpFeatureUiFor(tester, const Duration(milliseconds: 300));
}

Finder _hostManageScrollable() => find
    .descendant(
      of: find.byKey(const Key('host_event_manage_scroll_view')),
      matching: find.byType(Scrollable),
    )
    .first;

Finder _dialogAction(String label) {
  return find.descendant(
    of: find.byType(Dialog),
    matching: find.widgetWithText(CatchButton, label),
  );
}
