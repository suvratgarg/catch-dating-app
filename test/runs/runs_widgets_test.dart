import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/run_schedule_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/duration_stepper.dart';
import 'package:catch_dating_app/runs/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/runs/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/runs/presentation/widgets/picker_tile.dart';
import 'package:catch_dating_app/runs/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_photo_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_stats_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/schedule_day_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/schedule_run_card.dart';
import 'package:catch_dating_app/runs/presentation/widgets/step_progress_bar.dart';
import 'package:catch_dating_app/runs/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_step.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_where_card.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

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
                startingPoint: const LatLng(19.076, 72.8777),
                onTap: () {},
              ),
              DurationStepper(
                minutes: 75,
                onDecrease: () => decreased = true,
                onIncrease: () => increased = true,
                formatDuration: (minutes) => '$minutes min',
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
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.tap(find.byIcon(Icons.add_rounded));
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
          signedUpUserIds: const ['a', 'b', 'c'],
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

    testWidgets('schedule and progress widgets render and handle selection', (
      tester,
    ) async {
      final now = DateTime.now();
      final run = buildRun(
        id: 'run-7',
        startTime: DateTime(now.year, now.month, now.day, 8),
        endTime: DateTime(now.year, now.month, now.day, 9),
        distanceKm: 7,
        signedUpUserIds: const ['runner-1', 'runner-2'],
      );
      String? selectedRunId;
      var footerTapped = false;

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: ListView(
            children: [
              ScheduleDayHeader(day: now),
              ScheduleRunCard(
                run: run,
                isSelected: true,
                onTap: () => selectedRunId = run.id,
              ),
              const StepProgressBar(currentStep: 1, totalSteps: 4),
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
                width: 900,
                height: 500,
                child: RunScheduleGrid(
                  runs: [run],
                  selectedRunId: run.id,
                  onRunSelected: (selected) => selectedRunId = selected.id,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.textContaining('km · Easy'), findsWidgets);
      expect(find.text('08:00–09:00'), findsWidgets);
      expect(find.text('2/20'), findsWidgets);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Schedule run'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('7km · Easy').first);
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(selectedRunId, 'run-7');
      expect(footerTapped, isTrue);
    });

    testWidgets('schedule grid forwards taps to the selected-run callback', (
      tester,
    ) async {
      final now = DateTime.now();
      final run = buildRun(
        id: 'run-grid',
        startTime: DateTime(now.year, now.month, now.day, 8),
        endTime: DateTime(now.year, now.month, now.day, 9),
        distanceKm: 7,
      );
      String? tappedRunId;

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: SizedBox(
            width: 900,
            height: 500,
            child: RunScheduleGrid(
              runs: [run],
              onRunSelected: (selected) => tappedRunId = selected.id,
            ),
          ),
        ),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(RunScheduleGrid),
          matching: find.text('7km · Easy'),
        ),
      );
      await tester.pump();

      expect(tappedRunId, run.id);
    });

    testWidgets('run photo header repaints when the token palette changes', (
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
          theme: ThemeData(extensions: const [CatchTokens.editorialLight]),
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
      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: WhoIsRunning(
            run: buildRun(signedUpUserIds: const []),
            appUser: buildUser(),
          ),
        ),
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
        final run = buildRun(
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          signedUpUserIds: const [
            'runner-0',
            'runner-1',
            'runner-2',
            'runner-3',
            'runner-4',
            'runner-5',
            'runner-6',
            'runner-7',
          ],
        );

        await pumpRunsTestApp(
          tester,
          Scaffold(
            body: WhoIsRunning(run: run, appUser: buildUser()),
          ),
          overrides: [
            publicProfileRepositoryProvider.overrideWith(
              (ref) => fakePublicProfileRepository,
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
