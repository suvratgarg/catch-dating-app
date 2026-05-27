import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_agenda_list.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_photo_header.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_stats_grid.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_hero_tile.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/events/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/events/presentation/widgets/picker_tile.dart';
import 'package:catch_dating_app/events/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/events/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/events/presentation/widgets/when_step.dart';
import 'package:catch_dating_app/events/presentation/widgets/when_where_card.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'events_test_helpers.dart';

void main() {
  group('Events widgets', () {
    testWidgets('basic input widgets render their states and handle taps', (
      tester,
    ) async {
      var pickerTapped = false;
      var mapTapped = false;
      var decreased = false;
      var increased = false;

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              const FieldLabel('Distance'),
              PickerTile(
                icon: CatchIcons.calendarTodayOutlined,
                value: null,
                placeholder: 'Select a date',
                onTap: () => pickerTapped = true,
              ),
              PickerTile(
                icon: CatchIcons.scheduleOutlined,
                value: '23/04/2026',
                placeholder: 'Unused',
                onTap: () {},
              ),
              MapPinTile(startingPoint: null, onTap: () => mapTapped = true),
              MapPinTile(
                startingPoint: const LocationCoordinate(19.076, 72.8777),
                selectedLabel: 'Bandra Fort',
                onTap: () {},
              ),
              CatchNumberStepper(
                value: 75,
                onDecrease: () => decreased = true,
                onIncrease: () => increased = true,
                decreaseTooltip: 'Decrease duration',
                increaseTooltip: 'Increase duration',
                formatValue: (minutes) => '${minutes.round()} min',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Select a date'), findsOneWidget);
      expect(find.text('23/04/2026'), findsOneWidget);
      expect(find.text('Choose on map'), findsOneWidget);
      expect(find.text('Bandra Fort'), findsOneWidget);
      expect(find.text('75 min'), findsOneWidget);
      expect(
        tester.getSize(find.widgetWithText(PickerTile, 'Select a date')).height,
        CatchControlMetrics.mdMinHeight,
      );
      expect(
        tester
            .getSize(find.widgetWithText(CatchNumberStepper, '75 min'))
            .height,
        CatchControlMetrics.mdMinHeight,
      );
      expect(
        tester.getSize(find.widgetWithText(MapPinTile, 'Choose on map')).height,
        CatchControlMetrics.mdMinHeight,
      );
      expect(
        tester.getSize(find.widgetWithText(MapPinTile, 'Bandra Fort')).height,
        CatchControlMetrics.mdMinHeight,
      );

      await tester.tap(find.text('Select a date'));
      await tester.tap(find.text('Choose on map'));
      await tester.tap(find.byTooltip('Decrease duration'));
      await tester.tap(find.byTooltip('Increase duration'));
      await tester.pump();

      expect(pickerTapped, isTrue);
      expect(mapTapped, isTrue);
      expect(decreased, isTrue);
      expect(increased, isTrue);
    });

    testWidgets(
      'requirements, stats, date card, and photo header render event details',
      (tester) async {
        final event = buildEvent(
          startTime: DateTime(2025, 4, 23, 6, 30),
          endTime: DateTime(2025, 4, 23, 7, 45),
          meetingPoint: 'Bandra Fort',
          locationDetails: 'Meet by the parking lot',
          distanceKm: 5.5,
          bookedCount: 3,
          constraints: const EventConstraints(
            minAge: 21,
            maxAge: 35,
            maxMen: 8,
            maxWomen: 10,
          ),
        );

        await pumpEventsTestApp(
          tester,
          Scaffold(
            body: ListView(
              children: [
                RequirementsRow(event: event),
                const SizedBox(height: 16),
                EventStatsGrid(event: event),
                const SizedBox(height: 16),
                WhenWhereCard(event: event),
                const SizedBox(height: 16),
                SizedBox(height: 320, child: EventPhotoHeader(event: event)),
              ],
            ),
          ),
        );

        expect(find.text('Requirements'), findsOneWidget);
        expect(find.text('AGE 21–35'), findsOneWidget);
        expect(find.text('MAX 8 MEN'), findsOneWidget);
        expect(find.text('MAX 10 WOMEN'), findsOneWidget);
        expect(find.byType(CatchMetricStrip), findsOneWidget);
        expect(find.text('5.5'), findsOneWidget);
        expect(find.text('Pace level'), findsOneWidget);
        expect(find.text('3/20'), findsOneWidget);
        expect(find.text('6:30 AM – 7:45 AM'), findsOneWidget);
        expect(find.text('Wednesday, 23 Apr'), findsOneWidget);
        expect(find.text('Bandra Fort'), findsOneWidget);
        expect(find.text('Meet by the parking lot'), findsOneWidget);
        expect(find.text('Wednesday Morning Run'), findsNothing);
        expect(find.text('3/20 spots'), findsNothing);
        expect(find.text('5.5km'), findsNothing);
      },
    );

    testWidgets('stats strip adapts its labels for non-distance events', (
      tester,
    ) async {
      final event = buildEvent(
        eventFormat: EventFormatSnapshot.fromActivityKind(
          ActivityKind.pickleball,
        ),
      );

      await pumpEventsTestApp(
        tester,
        Scaffold(body: EventStatsGrid(event: event)),
      );

      expect(find.text('Pickleball'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Skill level'), findsOneWidget);
      expect(find.text('0/20'), findsOneWidget);
      expect(find.text('Distance'), findsNothing);
      expect(find.text('Pace level'), findsNothing);
      expect(find.text('km'), findsNothing);
    });

    testWidgets('location card opens map only when exact coordinates exist', (
      tester,
    ) async {
      var tapped = false;
      final mappedRun = buildEvent(
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: WhenWhereCard(
            event: mappedRun,
            onLocationTap: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(CatchIcons.chevronRightRounded), findsOneWidget);

      await tester.tap(find.text('Race Course Road main gate'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('location card hides map affordance without coordinates', (
      tester,
    ) async {
      var tapped = false;

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: WhenWhereCard(
            event: buildEvent(meetingPoint: 'Race Course Road main gate'),
            onLocationTap: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(CatchIcons.chevronRightRounded), findsNothing);

      await tester.tap(find.text('Race Course Road main gate'));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('event location map centers a pinned event and labels it', (
      tester,
    ) async {
      final event = buildEvent(
        meetingPoint: 'Race Course Road main gate',
        locationDetails: 'Look for the Catch demo pacer near the entrance.',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );

      await pumpEventsTestApp(
        tester,
        EventLocationMapScreen(event: event, enableNetworkTiles: false),
      );

      expect(find.text('Event location'), findsNothing);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byIcon(CatchIcons.locationOnRounded), findsOneWidget);
      expect(find.text('Race Course Road main gate'), findsOneWidget);
      expect(
        find.text('Look for the Catch demo pacer near the entrance.'),
        findsOneWidget,
      );
    });

    testWidgets('event location map keeps directions as an explicit action', (
      tester,
    ) async {
      Uri? openedUri;
      LaunchMode? openedMode;
      final event = buildEvent(
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );

      await pumpEventsTestApp(
        tester,
        EventLocationMapScreen(event: event, enableNetworkTiles: false),
        overrides: [
          externalUrlLauncherProvider.overrideWithValue((
            uri, {
            mode = LaunchMode.platformDefault,
          }) async {
            openedUri = uri;
            openedMode = mode;
            return true;
          }),
        ],
      );

      await tester.tap(find.text('Get directions'));
      await tester.pump();

      expect(openedMode, LaunchMode.externalApplication);
      expect(
        openedUri.toString(),
        'https://www.google.com/maps/dir/?api=1&destination=22.7196%2C75.8577&travelmode=walking',
      );
    });

    testWidgets('requirements row hides itself when there are no constraints', (
      tester,
    ) async {
      await pumpEventsTestApp(
        tester,
        Scaffold(body: RequirementsRow(event: buildEvent())),
      );

      expect(find.text('Requirements'), findsNothing);
    });

    testWidgets('requirements row renders min-only and max-only age chips', (
      tester,
    ) async {
      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              RequirementsRow(
                event: buildEvent(
                  constraints: const EventConstraints(minAge: 21),
                ),
              ),
              RequirementsRow(
                event: buildEvent(
                  constraints: const EventConstraints(maxAge: 35),
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('21+ YEARS'), findsOneWidget);
      expect(find.text('UP TO 35 YEARS'), findsOneWidget);
    });

    testWidgets('when step renders schedule validation text', (tester) async {
      final dateController = TextEditingController(text: '23/04/2026');
      final startTimeController = TextEditingController(text: '6:30 AM');
      addTearDown(dateController.dispose);
      addTearDown(startTimeController.dispose);

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: WhenStep(
            formKey: GlobalKey<FormState>(),
            dateController: dateController,
            startTimeController: startTimeController,
            durationMinutes: 60,
            onPickDate: _noop,
            onPickTime: _noop,
            onDecreaseDuration: _noop,
            onIncreaseDuration: _noop,
            formatDuration: (minutes) => '$minutes min',
            scheduleErrorText: 'Start time must be in the future',
          ),
        ),
      );

      expect(find.text('Start time must be in the future'), findsOneWidget);
    });

    testWidgets('agenda and progress widgets render and handle selection', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 5);
      final event = buildEvent(
        id: 'event-7',
        startTime: DateTime(now.year, now.month, now.day, 8),
        endTime: DateTime(now.year, now.month, now.day, 9),
        distanceKm: 7,
        bookedCount: 2,
      );
      String? selectedEventId;
      var footerTapped = false;

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: ListView(
            children: [
              const CatchStepProgress(currentStep: 1, totalSteps: 4),
              StepperFooter(
                isLastStep: false,
                isLoading: false,
                onNext: () => footerTapped = true,
              ),
              const StepperFooter(
                isLastStep: true,
                isLoading: true,
                onNext: _noop,
              ),
              SizedBox(
                height: 240,
                child: EventAgendaList(
                  events: [event],
                  badgeLabel: 'VIEW',
                  today: now,
                  onEventSelected: (selected) => selectedEventId = selected.id,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('7km · Easy · 2/20 spots'), findsOneWidget);
      expect(find.text('VIEW'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Schedule event'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CatchButton && widget.isLoading,
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('7km · Easy · 2/20 spots'));
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(selectedEventId, 'event-7');
      expect(footerTapped, isTrue);
    });

    testWidgets(
      'stepper footer blends into page and keeps actions inside width',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpEventsTestApp(
          tester,
          Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: StepperFooter(
              isLastStep: true,
              isLoading: false,
              onNext: _noop,
              onSaveDraft: _noop,
              lastStepLabel: 'Schedule event',
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Save Draft'), findsOneWidget);
        expect(find.text('Schedule event'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(StepperFooter),
            matching: find.byType(Divider),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(StepperFooter),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is ColoredBox &&
                  widget.color == CatchTokens.sunsetLight.bg,
            ),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('agenda list sorts events and forwards selected-event taps', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 5);
      final laterRun = buildEvent(
        id: 'event-later',
        startTime: DateTime(now.year, now.month, now.day, 10),
        endTime: DateTime(now.year, now.month, now.day, 11),
        meetingPoint: 'Later start',
      );
      final soonerRun = buildEvent(
        id: 'event-sooner',
        startTime: DateTime(now.year, now.month, now.day, 8),
        endTime: DateTime(now.year, now.month, now.day, 9),
        meetingPoint: 'Sooner start',
      );
      String? tappedEventId;

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: SizedBox(
            height: 360,
            child: EventAgendaList(
              events: [laterRun, soonerRun],
              today: now,
              onEventSelected: (selected) => tappedEventId = selected.id,
            ),
          ),
        ),
      );

      expect(
        tester.getTopLeft(find.text('Sooner start')).dy <
            tester.getTopLeft(find.text('Later start')).dy,
        isTrue,
      );

      await tester.tap(find.text('Sooner start'));
      await tester.pump();

      expect(tappedEventId, 'event-sooner');
    });

    testWidgets('agenda list renders provided club names by default', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 5);
      final event = buildEvent(
        id: 'event-with-club',
        startTime: DateTime(now.year, now.month, now.day, 8),
        meetingPoint: 'Global surface start',
      );

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: SizedBox(
            height: 300,
            child: EventAgendaList(
              events: [event],
              today: now,
              clubNameBuilder: (_) => 'Stride Social',
            ),
          ),
        ),
      );

      expect(find.text('Global surface start'), findsOneWidget);
      expect(find.text('Stride Social'), findsOneWidget);
    });

    testWidgets('event hero tile renders key details and forwards taps', (
      tester,
    ) async {
      final surfaceKey = UniqueKey();
      var tapped = false;
      final event = buildEvent(
        startTime: DateTime.now().add(const Duration(days: 3)),
        meetingPoint: 'Sea Link promenade',
        distanceKm: 8,
      );

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: SizedBox(
            width: 360,
            child: EventHeroTile(
              surfaceKey: surfaceKey,
              data: EventTileData.fromEvent(
                event: event,
                status: EventTileStatus.recommended,
                clubName: 'Stride Social',
                positionLabel: 'FEATURED',
              ),
              viewerInterestedInGenders: const [Gender.woman],
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.textContaining('NEXT EVENT'), findsOneWidget);
      expect(find.text(event.title), findsOneWidget);
      expect(find.text('Stride Social'), findsOneWidget);
      expect(find.text('Sea Link promenade'), findsOneWidget);
      expect(find.text('8km · Easy'), findsOneWidget);
      expect(find.text('0 attendees confirmed'), findsOneWidget);
      expect(find.text('FEATURED'), findsOneWidget);

      await tester.tap(find.byKey(surfaceKey));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'event photo header uses the shared branded fallback without a photo',
      (tester) async {
        final event = buildEvent();

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: const [CatchTokens.sunsetLight]),
            home: Scaffold(
              body: SizedBox(
                height: 320,
                child: EventPhotoHeader(event: event),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(CatchIcons.directionsRun), findsNothing);
        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets('event photo header does not duplicate event detail copy', (
      tester,
    ) async {
      final event = buildEvent(
        meetingPoint: 'Deuce',
        eventFormat: EventFormatSnapshot.fromActivityKind(
          ActivityKind.pickleball,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [CatchTokens.sunsetLight]),
          home: Scaffold(
            body: SizedBox(height: 320, child: EventPhotoHeader(event: event)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(CatchIcons.sportsTennis), findsNothing);
      expect(find.text(event.title), findsNothing);
      expect(find.text('Deuce'), findsNothing);
      expect(find.text('Pickleball'), findsNothing);
      expect(find.text('0/20 spots'), findsNothing);
    });

    testWidgets('event photo header prefers activity artwork over photo', (
      tester,
    ) async {
      final event = buildEvent(
        photoUrl: 'https://img.example/events/event-1.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [CatchTokens.sunsetLight]),
          home: Scaffold(
            body: SizedBox(height: 320, child: EventPhotoHeader(event: event)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsNothing);
      expect(find.text(event.title), findsNothing);
    });

    testWidgets('who is going shows the empty upcoming state', (tester) async {
      final fakeParticipationRepository = FakeEventParticipationRepository();

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: WhoIsGoing(
            event: buildEvent(bookedCount: 0),
            userProfile: buildUser(),
          ),
        ),
        overrides: [
          eventParticipationRepositoryProvider.overrideWith(
            (ref) => fakeParticipationRepository,
          ),
        ],
      );

      expect(find.text("Who's going"), findsOneWidget);
      expect(find.text('0/20'), findsOneWidget);
      expect(find.text('No attendees yet'), findsOneWidget);
      expect(find.text('Be the first to book this event.'), findsOneWidget);
      expect(find.textContaining('Swiping unlocks'), findsNothing);
    });

    testWidgets(
      'who is going loads profiles and shows overflow for past events',
      (tester) async {
        final fakePublicProfileRepository = FakePublicProfileRepository()
          ..profiles = List.generate(
            7,
            (index) =>
                buildPublicProfile(uid: 'runner-$index', name: 'Runner $index'),
          );
        final fakeParticipationRepository = FakeEventParticipationRepository();
        final event = buildEvent(
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          bookedCount: 1,
        );
        fakeParticipationRepository.eventParticipations[event.id] =
            List.generate(
              8,
              (index) => buildEventParticipation(
                event: event,
                uid: 'runner-$index',
                createdAt: DateTime(2026, 5, 6, 7, index),
              ),
            );

        await pumpEventsTestApp(
          tester,
          Scaffold(
            body: WhoIsGoing(event: event, userProfile: buildUser()),
          ),
          overrides: [
            publicProfileRepositoryProvider.overrideWith(
              (ref) => fakePublicProfileRepository,
            ),
            eventParticipationRepositoryProvider.overrideWith(
              (ref) => fakeParticipationRepository,
            ),
          ],
        );
        await tester.pump();

        expect(fakePublicProfileRepository.lastRequestedUids, hasLength(7));
        expect(find.text('8/20'), findsOneWidget);
        expect(find.text('+1'), findsOneWidget);
        expect(
          find.text(
            'The swipe window is open for 24 hours after the event finishes.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}

void _noop() {}
