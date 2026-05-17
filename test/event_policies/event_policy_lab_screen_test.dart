import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/event_policies/presentation/event_policy_lab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('renders the invite-only fixture without live booking actions', (
    tester,
  ) async {
    await _pumpLab(tester);

    expect(find.text('Event policy lab'), findsOneWidget);
    expect(find.text('In development'), findsOneWidget);
    expect(find.text('No live writes'), findsOneWidget);
    expect(find.text('Invite-only private event'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -420));
    await pumpFeatureUi(tester);

    expect(find.text('Guest without invite'), findsOneWidget);
    expect(find.text('Invite required'), findsWidgets);
    expect(find.text('Guest with invite'), findsOneWidget);
    expect(find.text('Admitted'), findsOneWidget);
    expect(find.text('₹500'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await pumpFeatureUi(tester);

    expect(find.text('Cancellation outcomes'), findsOneWidget);
    expect(find.text('Attendee cancels 12h before'), findsOneWidget);
    expect(find.text('Host cancels event'), findsOneWidget);
    expect(find.text('Made complete'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches to demand pricing and exposes exact preview rows', (
    tester,
  ) async {
    await _pumpLab(tester);

    final demandScenario = find.byKey(
      EventPolicyLabKeys.scenarioCard('demand_priced_balanced_event'),
    );
    await tester.ensureVisible(demandScenario);
    await tester.tap(demandScenario);
    await pumpFeatureUi(tester);

    expect(find.text('Demand-priced balanced event'), findsWidgets);
    expect(find.text('Man in high-demand cohort'), findsOneWidget);
    expect(find.text('Woman in balancing cohort'), findsOneWidget);
    expect(find.text('Waitlisted'), findsOneWidget);
    expect(find.text('Ratio limit reached'), findsOneWidget);
    expect(find.text('₹1,000'), findsWidgets);
    expect(find.text('₹300'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await pumpFeatureUi(tester);

    expect(
      find.text('Demand-priced attendee cancels 36h before'),
      findsOneWidget,
    );
    expect(find.text('50% credit'), findsOneWidget);
    expect(find.text('Host cancels demand-priced event'), findsOneWidget);
    expect(find.text('Made complete'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await pumpFeatureUi(tester);

    expect(find.byKey(EventPolicyLabKeys.debugOutput), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the same lab layout on a wider viewport', (tester) async {
    await _pumpLab(tester, size: const Size(900, 1600));

    expect(find.text('Host configuration'), findsOneWidget);
    expect(find.text('Policy shape'), findsOneWidget);
    expect(find.text('Preview outcomes'), findsOneWidget);
    expect(find.text('Cancellation outcomes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpLab(
  WidgetTester tester, {
  Size size = const Size(390, 1200),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const EventPolicyLabScreen()),
  );
  await pumpFeatureUi(tester);
}
