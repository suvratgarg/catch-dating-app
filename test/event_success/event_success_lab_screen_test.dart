import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_lab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('labels the event success lab as preview-only WIP', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const EventSuccessLabScreen()),
    );

    expect(find.text('Event Success Lab'), findsOneWidget);
    expect(find.text('Event Success Layer'), findsOneWidget);
    expect(find.text('Work in progress'), findsOneWidget);
    expect(find.text('Preview only'), findsOneWidget);
    expect(find.text('Dev/staging route'), findsOneWidget);
    expect(find.text('No Firestore writes'), findsOneWidget);
    expect(find.text('No booking changes'), findsOneWidget);
  });

  testWidgets('renders non-running playbooks for product iteration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const EventSuccessLabScreen(
          playbooks: [
            EventSuccessPlaybookLibrary.pickleball,
            EventSuccessPlaybookLibrary.pubQuiz,
          ],
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Pickleball Partner Rotations'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Pickleball Partner Rotations'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pub Quiz Team Mixer'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Pub Quiz Team Mixer'), findsOneWidget);
  });

  testWidgets('renders the actual WIP feature blocks', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const EventSuccessLabScreen()),
    );

    expect(find.text('Actual WIP feature blocks'), findsOneWidget);
    expect(find.text('Host setup flow'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Live host mode'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Live host mode'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Attendee companion'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Attendee companion'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Post-event host report'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Post-event host report'), findsOneWidget);
  });

  testWidgets('host setup flow can change formats and flag missing gates', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: EventSuccessHostSetupFlow()),
        ),
      ),
    );

    expect(find.text('Social Event Lite'), findsOneWidget);
    await tester.tap(find.text('Pickleball'));
    await tester.pumpAndSettle();

    expect(find.text('Pickleball Partner Rotations'), findsOneWidget);

    final checkInSwitch = find.bySemanticsLabel(
      'Attendance and live roster tool',
    );
    expect(checkInSwitch, findsOneWidget);

    await tester.scrollUntilVisible(checkInSwitch, 300);
    await tester.tap(checkInSwitch);
    await tester.pumpAndSettle();

    expect(find.text('Needs work'), findsOneWidget);
    expect(
      find.text('Add check-in before using attendance for follow-up.'),
      findsOneWidget,
    );
  });

  testWidgets('shows host coach recommendations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const EventSuccessLabScreen()),
    );

    await tester.scrollUntilVisible(
      find.text('Host coach sample'),
      800,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Sample debrief'), findsOneWidget);
    expect(find.text('Tighten arrival and attendance capture'), findsOneWidget);
    expect(
      find.text('Create more social permission during the event'),
      findsOneWidget,
    );
  });
}
