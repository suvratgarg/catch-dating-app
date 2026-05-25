import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_manual_qa_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:flutter/material.dart';
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

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const EventSuccessManualQaScreen(),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Event success manual QA'), findsOneWidget);
    expect(find.text('Fixture scenario'), findsOneWidget);
    expect(find.text('Attendee moment'), findsNothing);
    expect(find.text('Attendee choices'), findsOneWidget);
    expect(find.text('Host Manage'), findsOneWidget);
    expect(find.text('HOST MANAGE'), findsOneWidget);
    await _scrollHostManageUntilVisible(tester, 'Participation');
    expect(find.text('Participation'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Attendee experience'), findsOneWidget);
    expect(find.text('Event companion'), findsOneWidget);
    expect(find.text('Fixture data'), findsOneWidget);

    await _tapHostSection(tester, 'Live');
    expect(find.text('Live now'), findsOneWidget);
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

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const EventSuccessManualQaScreen(),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    await _tapHostSection(tester, 'Live');

    expect(find.text('Live now'), findsOneWidget);
    expect(
      find.textContaining('Step 1/4: Check in and skill confirm'),
      findsWidgets,
    );
    expect(find.text('Know your first court and partner.'), findsWidgets);

    await _tapHostNext(tester);

    expect(find.textContaining('Fixture host step advanced'), findsNothing);
    expect(
      find.textContaining('Step 2/4: Rules and first rotation'),
      findsWidgets,
    );
    expect(find.text('Know your first court and partner.'), findsNothing);
    expect(find.text('Social prompt'), findsOneWidget);

    await _tapHostNext(tester);

    expect(find.textContaining('Step 3/4: Timed partner rounds'), findsWidgets);
    expect(
      find.text('Play with several people at a matched skill level.'),
      findsWidgets,
    );
    expect(find.text('Waiting for the host reveal'), findsNothing);

    await _tapHostButton(tester, 'Drop 15s countdown');

    expect(find.text('countingDown'), findsWidgets);
    expect(find.text('Next reveal in 15s'), findsWidgets);

    await pumpFeatureUiFor(tester, const Duration(seconds: 2));

    expect(find.text('Next reveal in 13s'), findsWidgets);

    await _tapHostButton(tester, 'Reveal now');

    expect(find.text('revealed'), findsWidgets);
    expect(find.text('Sign in required'), findsNothing);

    await tester.tap(find.text('Rotations opt-out'));
    await tester.pump();

    expect(find.text('rotations opted out'), findsOneWidget);
    expect(find.text('Rotations paused for you'), findsWidgets);
  });

  testWidgets('manual QA saves attendee questionnaire through fixture store', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const EventSuccessManualQaScreen(),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    final companion = find.byType(EventSuccessCompanionScreen);
    final playfulOption = find.descendant(
      of: companion,
      matching: find.text('Playful competition'),
    );
    await tester.ensureVisible(playfulOption);
    await tester.pump();
    await tester.tap(playfulOption);
    await tester.pump();

    final saveButton = find.descendant(
      of: companion,
      matching: find.widgetWithText(CatchButton, 'Save clues'),
    );
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await pumpFeatureUi(tester);

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

  testWidgets('manual QA host manage live includes participant table', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const EventSuccessManualQaScreen(),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    await _tapHostSection(tester, 'Live');
    await _scrollHostManageUntilVisible(tester, 'Guest');

    expect(find.text('All'), findsWidgets);
    expect(find.text('Due'), findsWidgets);
    expect(find.text('In'), findsWidgets);
    expect(find.text('Waitlist'), findsWidgets);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Host action'), findsOneWidget);
    expect(
      find.text('Signed-up participants will appear here when they book.'),
      findsNothing,
    );
    expect(find.text('Live now'), findsOneWidget);
    expect(find.text('Sign in required'), findsNothing);
  });

  testWidgets('manual QA covers flagship singles live reveal', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const EventSuccessManualQaScreen(),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Singles mixer'));
    await tester.pump();

    expect(find.textContaining('Singles Mixer'), findsWidgets);
    expect(find.text('10s reveal'), findsOneWidget);

    await _tapHostSection(tester, 'Live');

    expect(find.textContaining('Step 1/4: Quick questions'), findsWidgets);

    await _tapHostNext(tester);
    expect(
      find.textContaining('Step 2/4: Check in and clue card'),
      findsWidgets,
    );

    await _tapHostNext(tester);
    expect(find.textContaining('Step 3/4: Rounds and reveal'), findsWidgets);
    expect(
      find.text('Meet people before seeing suggested matches.'),
      findsWidgets,
    );

    await _tapHostButton(tester, 'Drop 10s countdown');
    expect(find.text('countingDown'), findsWidgets);

    await _tapHostButton(tester, 'Reveal now');
    expect(find.text('revealed'), findsWidgets);
    expect(find.text('Sign in required'), findsNothing);
  });
}

Future<void> _tapHostNext(WidgetTester tester) async {
  final nextButton = find.byKey(const ValueKey('eventSuccessNextStepButton'));
  await _scrollHostManageFinderUntilVisible(tester, nextButton);
  await tester.pump();
  await tester.tap(nextButton.first);
  await tester.pump();
}

Future<void> _tapHostSection(WidgetTester tester, String label) async {
  final hostManage = find.byType(HostEventManageScreen);
  final scrollable = find
      .descendant(of: hostManage, matching: find.byType(Scrollable))
      .first;
  final section = find.descendant(
    of: find.descendant(
      of: hostManage,
      matching: find.byType(CatchSegmentedControl<HostEventManageSection>),
    ),
    matching: find.text(label),
  );
  for (var i = 0; i < 12 && section.evaluate().isEmpty; i += 1) {
    await tester.drag(scrollable, const Offset(0, 180));
    await tester.pump();
  }
  await tester.ensureVisible(section.first);
  await tester.pump();
  await tester.tap(section.first);
  await pumpFeatureUi(tester);
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

Future<void> _tapHostButton(WidgetTester tester, String label) async {
  final nextButton = find.widgetWithText(CatchButton, label);
  await _scrollHostManageFinderUntilVisible(tester, nextButton);
  await tester.pump();
  await tester.tap(nextButton.first);
  await tester.pump();
}
