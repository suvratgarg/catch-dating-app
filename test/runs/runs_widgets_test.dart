import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/run_location_map_screen.dart';
import 'package:catch_dating_app/runs/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/runs/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/runs/presentation/widgets/picker_tile.dart';
import 'package:catch_dating_app/runs/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_agenda_list.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_photo_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_stats_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_step.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_where_card.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'runs_test_helpers.dart';

void main() {
  group('Runs widgets', () {
    testWidgets('basic input widgets render their states and handle taps', (
      tester,
    ) async {
      var pickerTapped = false;
      var mapTapped = false;
      var decreased = false;
      var increased = false;

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              const FieldLabel('Distance'),
              PickerTile(
                icon: Icons.calendar_today_outlined,
                value: null,
                placeholder: 'Select a date',
                onTap: () => pickerTapped = true,
              ),
              PickerTile(
                icon: Icons.schedule_outlined,
                value: '23/04/2026',
                placeholder: 'Unused',
                onTap: () {},
              ),
              MapPinTile(startingPoint: null, onTap: () => mapTapped = true),
              MapPinTile(
                startingPoint: const LocationCoordinate(19.076, 72.8777),
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
      expect(find.text('Pin exact starting point on map'), findsOneWidget);
      expect(find.text('19.07600, 72.87770'), findsOneWidget);
      expect(find.text('75 min'), findsOneWidget);

      await tester.tap(find.text('Select a date'));
      await tester.tap(find.text('Pin exact starting point on map'));
      await tester.tap(find.byTooltip('Decrease duration'));
      await tester.tap(find.byTooltip('Increase duration'));
      await tester.pump();

      expect(pickerTapped, isTrue);
      expect(mapTapped, isTrue);
      expect(decreased, isTrue);
      expect(increased, isTrue);
    });

    testWidgets(
      'requirements, stats, date card, and photo header render run details',
      (tester) async {
        final run = buildRun(
          startTime: DateTime(2025, 4, 23, 6, 30),
          endTime: DateTime(2025, 4, 23, 7, 45),
          meetingPoint: 'Bandra Fort',
          locationDetails: 'Meet by the parking lot',
          distanceKm: 5.5,
          bookedCount: 3,
          constraints: const RunConstraints(
            minAge: 21,
            maxAge: 35,
            maxMen: 8,
            maxWomen: 10,
          ),
        );

        await pumpRunsTestApp(
          tester,
          Scaffold(
            body: ListView(
              children: [
                RequirementsRow(run: run),
                const SizedBox(height: 16),
                RunStatsGrid(run: run),
                const SizedBox(height: 16),
                WhenWhereCard(run: run),
                const SizedBox(height: 16),
                SizedBox(height: 320, child: RunPhotoHeader(run: run)),
              ],
            ),
          ),
        );

        expect(find.text('Requirements'), findsOneWidget);
        expect(find.text('AGE 21–35'), findsOneWidget);
        expect(find.text('MAX 8 MEN'), findsOneWidget);
        expect(find.text('MAX 10 WOMEN'), findsOneWidget);
        expect(find.text('5.5'), findsOneWidget);
        expect(find.text('Pace level'), findsOneWidget);
        expect(find.text('3/20'), findsOneWidget);
        expect(find.text('06:30 – 07:45'), findsOneWidget);
        expect(find.text('Wednesday, 23 Apr'), findsOneWidget);
        expect(find.text('Bandra Fort'), findsNWidgets(2));
        expect(find.text('Meet by the parking lot'), findsOneWidget);
        expect(find.text('Wednesday Morning Run'), findsOneWidget);
        expect(find.text('3/20 spots'), findsOneWidget);
        expect(find.text('5.5km'), findsOneWidget);
      },
    );

    testWidgets('location card opens map only when exact coordinates exist', (
      tester,
    ) async {
      var tapped = false;
      final mappedRun = buildRun(
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: WhenWhereCard(
            run: mappedRun,
            onLocationTap: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      await tester.tap(find.text('Race Course Road main gate'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('location card hides map affordance without coordinates', (
      tester,
    ) async {
      var tapped = false;

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: WhenWhereCard(
            run: buildRun(meetingPoint: 'Race Course Road main gate'),
            onLocationTap: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

      await tester.tap(find.text('Race Course Road main gate'));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('run location map centers a pinned run and labels it', (
      tester,
    ) async {
      final run = buildRun(
        meetingPoint: 'Race Course Road main gate',
        locationDetails: 'Look for the Catch demo pacer near the entrance.',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );

      await pumpRunsTestApp(
        tester,
        RunLocationMapScreen(run: run, enableNetworkTiles: false),
      );

      expect(find.text('Run location'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      expect(find.text('Race Course Road main gate'), findsOneWidget);
      expect(
        find.text('Look for the Catch demo pacer near the entrance.'),
        findsOneWidget,
      );
    });

    testWidgets('run location map keeps directions as an explicit action', (
      tester,
    ) async {
      Uri? openedUri;
      LaunchMode? openedMode;
      final run = buildRun(
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );

      await pumpRunsTestApp(
        tester,
        RunLocationMapScreen(run: run, enableNetworkTiles: false),
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
      await pumpRunsTestApp(
        tester,
        Scaffold(body: RequirementsRow(run: buildRun())),
      );

      expect(find.text('Requirements'), findsNothing);
    });

    testWidgets('requirements row renders min-only and max-only age chips', (
      tester,
    ) async {
      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              RequirementsRow(
                run: buildRun(constraints: const RunConstraints(minAge: 21)),
              ),
              RequirementsRow(
                run: buildRun(constraints: const RunConstraints(maxAge: 35)),
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
      final startTimeController = TextEditingController(text: '06:30');
      addTearDown(dateController.dispose);
      addTearDown(startTimeController.dispose);

      await pumpRunsTestApp(
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
      final run = buildRun(
        id: 'run-7',
        startTime: DateTime(now.year, now.month, now.day, 8),
        endTime: DateTime(now.year, now.month, now.day, 9),
        distanceKm: 7,
        bookedCount: 2,
      );
      String? selectedRunId;
      var footerTapped = false;

      await pumpRunsTestApp(
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
                child: RunAgendaList(
                  runs: [run],
                  badgeLabel: 'VIEW',
                  today: now,
                  onRunSelected: (selected) => selectedRunId = selected.id,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('7km · Easy · 2/20'), findsOneWidget);
      expect(find.text('VIEW'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Schedule run'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CatchButton && widget.isLoading,
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('7km · Easy · 2/20'));
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(selectedRunId, 'run-7');
      expect(footerTapped, isTrue);
    });

    testWidgets(
      'stepper footer blends into page and keeps actions inside width',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpRunsTestApp(
          tester,
          Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: StepperFooter(
              isLastStep: true,
              isLoading: false,
              onNext: _noop,
              onSaveDraft: _noop,
              lastStepLabel: 'Schedule run',
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Save Draft'), findsOneWidget);
        expect(find.text('Schedule run'), findsOneWidget);
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

    testWidgets('agenda list sorts runs and forwards selected-run taps', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 5);
      final laterRun = buildRun(
        id: 'run-later',
        startTime: DateTime(now.year, now.month, now.day, 10),
        endTime: DateTime(now.year, now.month, now.day, 11),
        meetingPoint: 'Later start',
      );
      final soonerRun = buildRun(
        id: 'run-sooner',
        startTime: DateTime(now.year, now.month, now.day, 8),
        endTime: DateTime(now.year, now.month, now.day, 9),
        meetingPoint: 'Sooner start',
      );
      String? tappedRunId;

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: SizedBox(
            height: 360,
            child: RunAgendaList(
              runs: [laterRun, soonerRun],
              today: now,
              onRunSelected: (selected) => tappedRunId = selected.id,
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

      expect(tappedRunId, 'run-sooner');
    });

    testWidgets('run photo header repaints when the token mode changes', (
      tester,
    ) async {
      final run = buildRun();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [CatchTokens.sunsetLight]),
          home: Scaffold(
            body: SizedBox(height: 320, child: RunPhotoHeader(run: run)),
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [CatchTokens.sunsetDark]),
          home: Scaffold(
            body: SizedBox(height: 320, child: RunPhotoHeader(run: run)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('who is running shows the empty upcoming state', (
      tester,
    ) async {
      final fakeParticipationRepository = FakeRunParticipationRepository();

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: WhoIsRunning(
            run: buildRun(bookedCount: 0),
            userProfile: buildUser(),
          ),
        ),
        overrides: [
          runParticipationRepositoryProvider.overrideWith(
            (ref) => fakeParticipationRepository,
          ),
        ],
      );

      expect(find.text("Who's running"), findsOneWidget);
      expect(find.text('0/20'), findsOneWidget);
      expect(
        find.text('No one has booked yet — be the first!'),
        findsOneWidget,
      );
      expect(
        find.text('Swiping unlocks for 24 hours after the run finishes.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'who is running loads profiles and shows overflow for past runs',
      (tester) async {
        final fakePublicProfileRepository = FakePublicProfileRepository()
          ..profiles = List.generate(
            7,
            (index) =>
                buildPublicProfile(uid: 'runner-$index', name: 'Runner $index'),
          );
        final fakeParticipationRepository = FakeRunParticipationRepository();
        final run = buildRun(
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          bookedCount: 1,
        );
        fakeParticipationRepository.runParticipations[run.id] = List.generate(
          8,
          (index) => buildRunParticipation(
            run: run,
            uid: 'runner-$index',
            createdAt: DateTime(2026, 5, 6, 7, index),
          ),
        );

        await pumpRunsTestApp(
          tester,
          Scaffold(
            body: WhoIsRunning(run: run, userProfile: buildUser()),
          ),
          overrides: [
            publicProfileRepositoryProvider.overrideWith(
              (ref) => fakePublicProfileRepository,
            ),
            runParticipationRepositoryProvider.overrideWith(
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
            'The swipe window is open for 24 hours after the run finishes.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}

void _noop() {}
