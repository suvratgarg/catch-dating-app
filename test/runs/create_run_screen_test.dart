import 'dart:async';

import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'runs_test_helpers.dart';

void main() {
  group('CreateRunScreen', () {
    testWidgets('validates the first step when basics are missing', (
      tester,
    ) async {
      await _pumpCreateRunFlow(tester);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

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
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await _fillBasicsStep(tester);

        await _tapPrimaryButton(tester, 'Next');
        await tester.pumpAndSettle();
        await _tapPrimaryButton(tester, 'Next');
        await tester.pump();
        expect(find.text('Required'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField).at(0), 'Bandra Fort');
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Meet at the gate',
        );
        await tester.pumpAndSettle();
        await _tapPrimaryButton(tester, 'Next');
        await tester.pumpAndSettle();

        await _pickFutureDate(tester);
        await _acceptInitialTime(tester);
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.tap(find.byIcon(Icons.remove_rounded));
        await tester.pump();
        await _tapPrimaryButton(tester, 'Next');
        await tester.pumpAndSettle();

        expect(find.text('Review & rules'), findsOneWidget);
        await tester.enterText(find.byType(TextFormField).at(0), '40');
        await tester.enterText(find.byType(TextFormField).at(1), '30');
        await tester.pumpAndSettle();
        await _tapPrimaryButton(tester, 'Schedule run');
        await tester.pump();

        expect(find.text('<= max'), findsOneWidget);
        expect(find.text('>= min'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField).at(0), '21');
        await tester.enterText(find.byType(TextFormField).at(1), '35');
        await tester.enterText(find.byType(TextFormField).at(2), '9');
        await tester.enterText(find.byType(TextFormField).at(3), '9');
        await tester.pumpAndSettle();
        await _tapPrimaryButton(tester, 'Schedule run');
        await tester.pumpAndSettle();

        expect(find.text('Your run is live.'), findsOneWidget);
        expect(find.text('Manage run'), findsOneWidget);
        expect(fakeRunRepository.createdRun, isNotNull);
        expect(fakeRunRepository.createdRun!.runClubId, 'club-1');
        expect(fakeRunRepository.createdRun!.meetingPoint, 'Bandra Fort');
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

        await tester.tap(find.text('Manage run'));
        await tester.pumpAndSettle();

        expect(find.text('HOST MANAGE'), findsOneWidget);
        expect(find.text('Roster'), findsOneWidget);
      },
    );

    testWidgets(
      'shows the past-time validation, clears it on repick, and renders mixed durations',
      (tester) async {
        await _pumpCreateRunFlow(tester, alwaysUse24HourFormat: true);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await _fillBasicsStep(tester);
        await _tapPrimaryButton(tester, 'Next');
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), 'Bandra Fort');
        await tester.pumpAndSettle();
        await _tapPrimaryButton(tester, 'Next');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();

        expect(find.text('1h 30m'), findsOneWidget);

        await _pickTodayDate(tester);
        await _pickTimeInInputMode(tester, hour: '00', minute: '01');
        await _tapPrimaryButton(tester, 'Next');

        expect(find.text('Start time must be in the future'), findsOneWidget);

        await _pickFutureDate(tester);

        expect(find.text('Start time must be in the future'), findsNothing);

        await _tapPrimaryButton(tester, 'Next');
        await tester.pumpAndSettle();

        expect(find.text('Review & rules'), findsOneWidget);
      },
    );

    testWidgets('picks a map location and handles back navigation', (
      tester,
    ) async {
      await _pumpCreateRunFlow(tester);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await _fillBasicsStep(tester);
      await _tapPrimaryButton(tester, 'Next');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pin exact starting point on map'));
      await tester.pumpAndSettle();

      final flutterMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
      const selectedPoint = LatLng(19.12345, 72.98765);
      flutterMap.options.onTap?.call(
        const TapPosition(Offset.zero, Offset.zero),
        selectedPoint,
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('19.12345, 72.98765'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Run basics'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
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
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

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

      expect(find.text('Bad state: create failed'), findsOneWidget);
      expect(find.text('Schedule run'), findsOneWidget);
    });
  });
}

Future<void> _pumpCreateRunFlow(
  WidgetTester tester, {
  Iterable overrides = const [],
  bool alwaysUse24HourFormat = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
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
  await tester.pumpAndSettle();
}

Future<void> _submitValidRun(WidgetTester tester) async {
  await _fillBasicsStep(tester);
  await _tapPrimaryButton(tester, 'Next');
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), 'Bandra Fort');
  await tester.enterText(find.byType(TextFormField).at(1), 'Meet at the gate');
  await tester.pumpAndSettle();
  await _tapPrimaryButton(tester, 'Next');
  await tester.pumpAndSettle();

  await _pickFutureDate(tester);
  await _acceptInitialTime(tester);
  await _tapPrimaryButton(tester, 'Next');
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), '21');
  await tester.enterText(find.byType(TextFormField).at(1), '35');
  await tester.enterText(find.byType(TextFormField).at(2), '9');
  await tester.enterText(find.byType(TextFormField).at(3), '9');
  await tester.pumpAndSettle();
  await _tapPrimaryButton(tester, 'Schedule run');
  await tester.pumpAndSettle();
}

Future<void> _fillBasicsStep(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), '7.5');
  await tester.enterText(find.byType(TextFormField).at(1), '18');
  await tester.enterText(find.byType(TextFormField).at(2), '249.5');
  await tester.tap(find.text('MODERATE'));
  await tester.enterText(
    find.byType(TextFormField).at(3),
    'Social pacing with a coffee stop.',
  );
  await tester.pumpAndSettle();
}

Future<void> _tapPrimaryButton(WidgetTester tester, String label) async {
  await _dismissKeyboard(tester);
  final buttonFinder = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(buttonFinder);
  await tester.tap(buttonFinder, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _dismissKeyboard(WidgetTester tester) async {
  tester.testTextInput.hide();
  await tester.pump();
}

Future<void> _pickTodayDate(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.calendar_today_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.text('${DateTime.now().day}').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _pickFutureDate(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.calendar_today_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Next month'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _pickTimeInInputMode(
  WidgetTester tester, {
  required String hour,
  required String minute,
}) async {
  await tester.tap(find.byIcon(Icons.schedule_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await tester.pumpAndSettle();

  final timeFields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(EditableText),
  );
  await tester.enterText(timeFields.at(0), hour);
  await tester.enterText(timeFields.at(1), minute);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _acceptInitialTime(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.schedule_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}
