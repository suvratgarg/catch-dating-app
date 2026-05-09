import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/runs/data/run_draft_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/create_run_form_keys.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/runs/presentation/host_run_manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:shared_preferences/shared_preferences.dart';

import '../test_pump_helpers.dart';
import 'runs_test_helpers.dart';

void main() {
  group('CreateRunScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('validates the first step when basics are missing', (
      tester,
    ) async {
      await _pumpCreateRunFlow(tester);
      await _openCreateRunFlow(tester);

      await _tapPrimaryButton(tester, 'Next');
      await tester.pump();

      expect(find.text('Required'), findsNWidgets(3));
      expect(find.text('Select a pace'), findsOneWidget);
    });

    testWidgets(
      'walks through the wizard, validates rules, submits, and pops',
      (tester) async {
        final fakeRunRepository = FakeRunRepository();
        await _pumpCreateRunFlow(
          tester,
          overrides: [
            runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          ],
        );
        await _openCreateRunFlow(tester);

        await _fillBasicsStep(tester);

        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Next');
        await tester.pump();
        expect(find.text('Required'), findsOneWidget);
        expect(find.text('Pin a starting point'), findsOneWidget);

        await _enterCreateRunText(
          tester,
          CreateRunFormKeys.meetingPoint,
          'Bandra Fort',
        );
        await _pickMapPoint(tester);
        await _enterCreateRunText(
          tester,
          CreateRunFormKeys.locationDetails,
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

        expect(find.text('Review & rules'), findsOneWidget);
        await _enterCreateRunText(tester, CreateRunFormKeys.minAge, '40');
        await _enterCreateRunText(tester, CreateRunFormKeys.maxAge, '30');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Schedule run');
        await tester.pump();

        expect(find.text('<= max'), findsOneWidget);
        expect(find.text('>= min'), findsOneWidget);

        await _enterCreateRunText(tester, CreateRunFormKeys.minAge, '21');
        await _enterCreateRunText(tester, CreateRunFormKeys.maxAge, '35');
        await _enterCreateRunText(tester, CreateRunFormKeys.maxMen, '9');
        await _enterCreateRunText(tester, CreateRunFormKeys.maxWomen, '9');
        await _pumpTestAnimation(tester);
        await _tapPrimaryButton(tester, 'Schedule run');
        await _pumpTestAnimation(tester);

        expect(find.text('Your run is live.'), findsOneWidget);
        expect(find.text('Manage run'), findsOneWidget);
        expect(
          find.textContaining('is now listed on Stride Social'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Followers can discover it from their home feed'),
          findsOneWidget,
        );
        expect(find.textContaining('visible to'), findsNothing);
        expect(fakeRunRepository.createdRun, isNotNull);
        expect(fakeRunRepository.createdRun!.runClubId, 'club-1');
        expect(fakeRunRepository.createdRun!.meetingPoint, 'Bandra Fort');
        expect(fakeRunRepository.createdRun!.startingPointLat, 19.12345);
        expect(fakeRunRepository.createdRun!.startingPointLng, 72.98765);
        expect(
          fakeRunRepository.createdRun!.locationDetails,
          'Meet at the gate',
        );
        expect(fakeRunRepository.createdRun!.distanceKm, 7.5);
        expect(fakeRunRepository.createdRun!.capacityLimit, 18);
        expect(fakeRunRepository.createdRun!.priceInPaise, 24950);
        expect(fakeRunRepository.createdRun!.pace.name, 'moderate');
        expect(fakeRunRepository.createdRun!.constraints.minAge, 21);
        expect(fakeRunRepository.createdRun!.constraints.maxAge, 35);
        expect(fakeRunRepository.createdRun!.constraints.maxMen, 9);
        expect(fakeRunRepository.createdRun!.constraints.maxWomen, 9);

        final manageRunButton = find.text('Manage run');
        await tester.ensureVisible(manageRunButton);
        await tester.tap(manageRunButton);
        await _pumpTestAnimation(tester);

        expect(find.text('HOST MANAGE'), findsOneWidget);
        expect(find.text('Roster'), findsOneWidget);
      },
    );

    testWidgets(
      'shows the past-time validation, clears it on repick, and renders mixed durations',
      (tester) async {
        final now = DateTime(2026, 5, 1, 14);
        await _pumpCreateRunFlow(
          tester,
          alwaysUse24HourFormat: true,
          now: () => now,
        );
        await _openCreateRunFlow(tester);

        await _fillBasicsStep(tester);
        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        await _enterCreateRunText(
          tester,
          CreateRunFormKeys.meetingPoint,
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
        await _pickTimeInInputMode(tester, hour: '00', minute: '01');

        expect(find.text('Choose a start time later than now'), findsOneWidget);
        expect(find.text('Select start time'), findsOneWidget);

        await _pickFutureDate(tester);
        await _acceptInitialTime(tester);

        expect(find.text('Choose a start time later than now'), findsNothing);

        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);

        expect(find.text('Review & rules'), findsOneWidget);
      },
    );

    testWidgets('picks a map location and handles back navigation', (
      tester,
    ) async {
      await _pumpCreateRunFlow(tester);
      await _openCreateRunFlow(tester);

      await _fillBasicsStep(tester);
      await _tapPrimaryButton(tester, 'Next');
      await _pumpTestAnimation(tester);

      await tester.tap(find.byKey(CreateRunFormKeys.mapPicker));
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

      expect(find.text('19.12345, 72.98765'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await _pumpTestAnimation(tester);
      expect(find.text('Run basics'), findsOneWidget);

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
      final fakeRunRepository = FakeRunRepository()
        ..createError = StateError('create failed');
      Object? uncaughtError;
      await _pumpCreateRunFlow(
        tester,
        overrides: [
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
        ],
      );
      await _openCreateRunFlow(tester);

      await runZonedGuarded(
        () async {
          await _submitValidRun(tester);
        },
        (error, stackTrace) {
          uncaughtError = error;
        },
      );

      expect(uncaughtError, isA<StateError>());
      await tester.pump();

      expect(find.text('create failed'), findsOneWidget);
      expect(find.text('Schedule run'), findsOneWidget);
    });

    testWidgets('host manage roster renders public profile rows', (
      tester,
    ) async {
      final publicProfiles = FakePublicProfileRepository()
        ..profiles = [
          buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
          buildPublicProfile(uid: 'runner-3', name: 'Avery'),
        ];
      final participationRepository = FakeRunParticipationRepository();
      final run = buildRun(
        priceInPaise: 10000,
        bookedCount: 1,
        waitlistedCount: 1,
      );
      participationRepository.runParticipations[run.id] = [
        buildRunParticipation(run: run, uid: 'runner-2'),
        buildRunParticipation(
          run: run,
          uid: 'runner-3',
          status: RunParticipationStatus.waitlisted,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            publicProfileRepositoryProvider.overrideWith(
              (ref) => publicProfiles,
            ),
            runParticipationRepositoryProvider.overrideWith(
              (ref) => participationRepository,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: HostRunManageScreen(
              runClub: buildRunClub(),
              run: run,
              onBackToSuccess: () {},
            ),
          ),
        ),
      );
      await _pumpTestAnimation(tester);

      expect(find.text('Taylor'), findsOneWidget);
      expect(find.text('Avery'), findsOneWidget);
      expect(find.text('runner-2'), findsNothing);
      expect(find.text('runner-3'), findsNothing);
      expect(find.text('PAID'), findsOneWidget);
      expect(find.text('WAITLIST'), findsOneWidget);
    });

    testWidgets('draft picker deletes persisted drafts and resumes another', (
      tester,
    ) async {
      final draftRepository = RunDraftRepository();
      await draftRepository.saveDraft(
        userId: 'runner-1',
        draft: _buildRunDraft(
          id: 'keep-draft',
          savedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          distance: '9',
          capacity: '18',
          meetingPoint: 'Keep Point',
        ),
      );
      await draftRepository.saveDraft(
        userId: 'runner-1',
        draft: _buildRunDraft(
          id: 'delete-draft',
          savedAt: DateTime.now(),
          distance: '5',
          meetingPoint: 'Delete Point',
        ),
      );

      await _pumpCreateRunFlow(tester);
      await _openCreateRunFlow(tester);

      expect(find.text('Your drafts'), findsOneWidget);
      expect(find.textContaining('Delete Point'), findsOneWidget);
      expect(find.textContaining('Keep Point'), findsOneWidget);

      await tester.tap(
        find.byKey(CreateRunFormKeys.deleteDraft('delete-draft')),
      );
      await _pumpTestAnimation(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await _pumpTestAnimation(tester);

      final remainingDrafts = await draftRepository.loadDrafts(
        runClubId: 'club-1',
        userId: 'runner-1',
      );
      expect(remainingDrafts.map((draft) => draft.id), ['keep-draft']);
      expect(find.textContaining('Delete Point'), findsNothing);
      expect(find.textContaining('Keep Point'), findsOneWidget);

      await tester.tap(find.textContaining('Keep Point'));
      await _pumpTestAnimation(tester);

      expect(find.text('Your drafts'), findsNothing);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
    });
  });
}

RunDraft _buildRunDraft({
  required String id,
  required DateTime savedAt,
  String? distance,
  String? capacity,
  String? meetingPoint,
}) {
  return RunDraft(
    id: id,
    runClubId: 'club-1',
    savedAt: savedAt,
    distance: distance,
    capacity: capacity,
    meetingPoint: meetingPoint,
  );
}

Future<void> _pumpCreateRunFlow(
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
                      builder: (_) => CreateRunScreen(
                        runClub: buildRunClub(),
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

Future<void> _openCreateRunFlow(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await _pumpTestAnimation(tester);
}

Future<void> _submitValidRun(WidgetTester tester) async {
  await _fillBasicsStep(tester);
  await _tapPrimaryButton(tester, 'Next');
  await _pumpTestAnimation(tester);

  await _enterCreateRunText(
    tester,
    CreateRunFormKeys.meetingPoint,
    'Bandra Fort',
  );
  await _pickMapPoint(tester);
  await _enterCreateRunText(
    tester,
    CreateRunFormKeys.locationDetails,
    'Meet at the gate',
  );
  await _pumpTestAnimation(tester);
  await _tapPrimaryButton(tester, 'Next');
  await _pumpTestAnimation(tester);

  await _pickFutureDate(tester);
  await _acceptInitialTime(tester);
  await _tapPrimaryButton(tester, 'Next');
  await _pumpTestAnimation(tester);

  await _enterCreateRunText(tester, CreateRunFormKeys.minAge, '21');
  await _enterCreateRunText(tester, CreateRunFormKeys.maxAge, '35');
  await _enterCreateRunText(tester, CreateRunFormKeys.maxMen, '9');
  await _enterCreateRunText(tester, CreateRunFormKeys.maxWomen, '9');
  await _pumpTestAnimation(tester);
  await _tapPrimaryButton(tester, 'Schedule run');
  await _pumpTestAnimation(tester);
}

Future<void> _pickMapPoint(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateRunFormKeys.mapPicker));
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
  await _enterCreateRunText(tester, CreateRunFormKeys.distance, '7.5');
  await _enterCreateRunText(tester, CreateRunFormKeys.capacity, '18');
  await _enterCreateRunText(tester, CreateRunFormKeys.price, '249.5');
  await tester.tap(find.text('MODERATE'));
  await _enterCreateRunText(
    tester,
    CreateRunFormKeys.description,
    'Social pacing with a coffee stop.',
  );
  await _pumpTestAnimation(tester);
}

Future<void> _enterCreateRunText(
  WidgetTester tester,
  Key fieldKey,
  String text,
) async {
  await tester.enterText(
    find.descendant(of: find.byKey(fieldKey), matching: find.byType(TextField)),
    text,
  );
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
  await tester.tap(find.byKey(CreateRunFormKeys.datePicker));
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('${(today ?? DateTime.now()).day}').hitTestable());
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('OK'));
  await _pumpTestAnimation(tester);
}

Future<void> _pickFutureDate(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateRunFormKeys.datePicker));
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
  await tester.tap(find.byKey(CreateRunFormKeys.timePicker));
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
  await tester.tap(find.byKey(CreateRunFormKeys.timePicker));
  await _pumpTestAnimation(tester);
  await tester.tap(find.text('OK'));
  await _pumpTestAnimation(tester);
}

Future<void> _pumpTestAnimation(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}
