import 'dart:io';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_manual_qa_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('manual QA screen renders host and attendee panes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_manualQaTestHarness());
    await _pumpManualQaReady(tester);

    expect(find.text('Event success manual QA'), findsOneWidget);
    expect(find.text('Fixture scenario'), findsOneWidget);
    expect(_selectChip('Racket pairs', selected: true), findsOneWidget);
    expect(_fieldToggle('Micro-pods opt-out'), findsOneWidget);
    expect(_fieldToggle('Rotations opt-out'), findsOneWidget);
    expect(find.text('Attendee moment'), findsNothing);
    expect(find.text('Attendee choices'), findsOneWidget);
    expect(find.text('Host Manage'), findsOneWidget);
    expect(find.text('SETUP'), findsOneWidget);
    expect(find.text('GUESTS'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('REPORT'), findsOneWidget);
    await _tapHostSection(tester, 'Guests');
    await _scrollHostManageUntilVisible(tester, 'Participation');
    expect(find.text('Participation'), findsOneWidget);
    expect(find.text('GUEST'), findsOneWidget);
    expect(find.text('Attendee experience'), findsOneWidget);
    expect(find.text('Event companion'), findsOneWidget);
    expect(find.text('FIXTURE DATA'), findsOneWidget);

    await _tapHostSection(tester, 'Live');
    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.text('Sign in required'), findsNothing);

    await _tapHostSection(tester, 'Report');
    await _scrollHostManageUntilVisible(tester, 'Post-event host report');

    expect(find.text('Post-event host report'), findsOneWidget);
  });

  testWidgets('manual QA host next advances the paired attendee state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_manualQaTestHarness());
    await _pumpManualQaReady(tester);

    await _tapHostSection(tester, 'Live');

    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.textContaining('Step 1/4'), findsWidgets);
    expect(find.text('Check in and skill confirm'), findsWidgets);
    expect(
      find.textContaining('Know your first court and partner.'),
      findsWidgets,
    );

    await _tapHostNext(tester);

    expect(find.textContaining('Fixture host step advanced'), findsNothing);
    expect(find.textContaining('Step 2/4'), findsWidgets);
    expect(find.textContaining('Rules and first rotation'), findsWidgets);
    expect(
      find.textContaining('Know your first court and partner.'),
      findsNothing,
    );

    await _tapHostNext(tester);

    expect(find.textContaining('Step 3/4'), findsWidgets);
    expect(find.textContaining('Timed partner rounds'), findsWidgets);
    expect(find.text('Sign in required'), findsNothing);

    await tester.tap(_fieldToggle('Rotations opt-out'));
    await tester.pump();

    expect(find.text('rotations opted out'), findsOneWidget);
  });

  testWidgets('manual QA saves attendee questionnaire through fixture store', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_manualQaTestHarness());
    await _pumpManualQaReady(tester);

    final companion = find.byType(EventSuccessCompanionScreen);
    for (final answer in const [
      'Playful competition',
      'A thoughtful question',
      'Ideas and trivia',
      'Plan another activity',
    ]) {
      final option = find.descendant(
        of: companion,
        matching: find.text(answer),
      );
      await tester.ensureVisible(option);
      await tester.pump();
      await tester.tap(option);
      await tester.pump();
    }

    final saveButton = find.descendant(
      of: companion,
      matching: find.widgetWithText(CatchButton, 'Save clues'),
    );
    await tester.ensureVisible(saveButton);
    await tester.pump();
    _pressCatchButton(tester, saveButton);
    await _pumpManualQaFrames(tester, frames: 40);

    expect(
      find.descendant(
        of: companion,
        matching: find.text('A few quick questions'),
      ),
      findsNothing,
    );
    expect(saveButton, findsNothing);
    expect(find.text('Sign in required'), findsNothing);
  });

  testWidgets('manual QA host manage guests includes participant table', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_manualQaTestHarness());
    await _pumpManualQaReady(tester);

    await _tapHostSection(tester, 'Guests');
    await _scrollHostManageUntilVisible(tester, 'GUEST');

    expect(find.text('ALL'), findsWidgets);
    expect(find.text('BOOKED'), findsWidgets);
    expect(find.text('WAITLIST'), findsWidgets);
    expect(find.text('SLOTS'), findsWidgets);
    expect(find.text('GUEST'), findsOneWidget);
    expect(find.text('SIGNAL'), findsOneWidget);
    expect(find.text('HOST ACTION'), findsOneWidget);
    expect(
      find.text('Signed-up participants will appear here when they book.'),
      findsNothing,
    );
    expect(find.text('Sign in required'), findsNothing);
  });

  testWidgets('manual QA covers flagship singles live reveal', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_manualQaTestHarness());
    await _pumpManualQaReady(tester);

    await tester.tap(find.text('Singles mixer'));
    await tester.pump();

    expect(find.textContaining('Singles Mixer'), findsWidgets);
    expect(find.text('10s reveal'), findsOneWidget);

    await _tapHostSection(tester, 'Live');

    expect(find.textContaining('Step 1/4'), findsWidgets);
    expect(find.text('Quick questions'), findsWidgets);

    await _tapHostNext(tester);
    expect(find.textContaining('Step 2/4'), findsWidgets);
    expect(find.textContaining('Check in and clue card'), findsWidgets);

    await _tapHostNext(tester);
    expect(find.textContaining('Step 3/4'), findsWidgets);
    expect(find.textContaining('Rounds and reveal'), findsWidgets);
    expect(find.text('Sign in required'), findsNothing);
  });
}

Widget _manualQaTestHarness() {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      home: DefaultAssetBundle(
        bundle: _ManualQaTestAssetBundle(),
        child: const EventSuccessManualQaScreen(),
      ),
    ),
  );
}

class _ManualQaTestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (!key.startsWith('tool/demo/demo_seed/')) {
      return rootBundle.load(key);
    }
    final data = Uint8List.fromList(File(key).readAsBytesSync());
    return ByteData.sublistView(data);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (!key.startsWith('tool/demo/demo_seed/')) {
      return rootBundle.loadString(key, cache: cache);
    }
    return File(key).readAsStringSync();
  }
}

Future<void> _pumpManualQaReady(WidgetTester tester) async {
  for (var i = 0; i < 80; i += 1) {
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 25));
    if (find.text('Fixture scenario').evaluate().isNotEmpty) return;
    final error = find.textContaining('Manual QA fixture failed');
    if (error.evaluate().isNotEmpty) {
      final text = tester.widget<Text>(error.first);
      fail(text.data ?? 'Manual QA fixture failed without details.');
    }
  }
  expect(find.text('Fixture scenario'), findsOneWidget);
}

Future<void> _pumpManualQaFrames(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i += 1) {
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
  }
}

Future<void> _tapHostNext(WidgetTester tester) async {
  final nextButton = find.byKey(const ValueKey('eventSuccessNextStepButton'));
  await _scrollHostManageFinderUntilVisible(tester, nextButton);
  await tester.pump();
  _pressCatchButton(tester, nextButton);
  await tester.pump();
}

Future<void> _tapHostSection(WidgetTester tester, String label) async {
  final hostManage = find.byType(HostEventManageScreen);
  final scrollable = find
      .descendant(of: hostManage, matching: find.byType(Scrollable))
      .first;
  final section = find.descendant(
    of: hostManage,
    matching: find.text(label.toUpperCase()),
  );
  for (var i = 0; i < 12 && section.evaluate().isEmpty; i += 1) {
    await tester.drag(scrollable, const Offset(0, 180));
    await tester.pump();
  }
  await tester.ensureVisible(section.first);
  await tester.pump();
  await tester.tap(section.first);
  await _pumpManualQaFrames(tester);
}

Future<void> _scrollHostManageUntilVisible(
  WidgetTester tester,
  String label,
) async {
  await _scrollHostManageFinderUntilVisible(
    tester,
    find.descendant(
      of: find.byType(HostEventManageScreen),
      matching: find.text(label),
    ),
  );
}

Future<void> _scrollHostManageFinderUntilVisible(
  WidgetTester tester,
  Finder target,
) async {
  final hostManage = find.byType(HostEventManageScreen);
  final scrollable = find
      .descendant(of: hostManage, matching: find.byType(Scrollable))
      .first;
  for (var i = 0; i < 12; i += 1) {
    if (target.evaluate().isNotEmpty) {
      await tester.ensureVisible(target.first);
      await tester.pump();
      return;
    }
    await tester.drag(scrollable, const Offset(0, -180));
    await tester.pump();
  }
  expect(target, findsWidgets);
  await tester.pump();
}

void _pressCatchButton(WidgetTester tester, Finder finder) {
  final button = tester.widget<CatchButton>(finder.first);
  expect(button.onPressed, isNotNull);
  button.onPressed!();
}

Finder _selectChip(String label, {bool? selected}) {
  final chip = find.widgetWithText(CatchChip, label);
  if (selected == null) return chip;
  return find.descendant(
    of: chip,
    matching: find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.selected == selected,
    ),
  );
}

Finder _fieldToggle(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == label,
  );
}
