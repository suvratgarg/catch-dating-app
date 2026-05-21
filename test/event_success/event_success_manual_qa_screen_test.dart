import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_manual_qa_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    expect(find.text('Event success manual QA'), findsOneWidget);
    expect(find.text('Fixture scenario'), findsOneWidget);
    expect(find.text('Host surface'), findsOneWidget);
    expect(find.text('Attendee moment'), findsNothing);
    expect(find.text('Attendee choices'), findsOneWidget);
    expect(find.text('Host config and controls'), findsOneWidget);
    expect(find.text('Attendee experience'), findsOneWidget);
    expect(find.text('Event companion'), findsOneWidget);
    expect(find.text('Fixture data'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(CatchSegmentedControl<EventSuccessHostTab>),
        matching: find.text('Live'),
      ),
    );
    await tester.pump();
    final regenerateRotationsButton = find.byKey(
      const ValueKey('eventSuccessGenerateRotationsButton'),
    );
    await tester.ensureVisible(regenerateRotationsButton);
    await tester.pump();
    await tester.tap(regenerateRotationsButton);
    await tester.pump();

    expect(
      find.textContaining('Fixture rotations regenerated'),
      findsOneWidget,
    );
    expect(find.text('Sign in required'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(CatchSegmentedControl<EventSuccessHostTab>),
        matching: find.text('Report'),
      ),
    );
    await tester.pump();

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

    await tester.tap(
      find.descendant(
        of: find.byType(CatchSegmentedControl<EventSuccessHostTab>),
        matching: find.text('Live'),
      ),
    );
    await tester.pump();

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

    await _tapHostButton(tester, 'Reveal now');

    expect(find.text('revealed'), findsWidgets);
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

    await tester.tap(find.text('Singles mixer'));
    await tester.pump();

    expect(find.textContaining('Singles Mixer'), findsWidgets);
    expect(find.text('10s reveal'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(CatchSegmentedControl<EventSuccessHostTab>),
        matching: find.text('Live'),
      ),
    );
    await tester.pump();

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
  await _tapHostButton(tester, 'Next');
}

Future<void> _tapHostButton(WidgetTester tester, String label) async {
  final nextButton = find.widgetWithText(CatchButton, label);
  await tester.ensureVisible(nextButton);
  await tester.pump();
  await tester.tap(nextButton);
  await tester.pump();
}
