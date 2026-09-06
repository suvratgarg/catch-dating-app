import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('share-card footer renders caller-owned brand copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: const Scaffold(
          body: CatchShareCardFooter(
            brandLabel: 'Notre marque',
            trailing: 'À partager',
          ),
        ),
      ),
    );
    expect(find.text('Notre marque'), findsOneWidget);
    expect(find.text('À partager'), findsOneWidget);
  });

  testWidgets('step progress formats the clamped one-based counter', (
    tester,
  ) async {
    final calls = <(int, int)>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: Scaffold(
          body: CatchStepProgress(
            currentStep: 99,
            totalSteps: 5,
            counterLabelBuilder: (step, total) {
              calls.add((step, total));
              return 'Étape $step sur $total';
            },
          ),
        ),
      ),
    );
    expect(calls, [(5, 5)]);
    expect(find.text('Étape 5 sur 5'), findsOneWidget);
  });

  testWidgets('hidden step counter does not request copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: Scaffold(
          body: CatchStepProgress(
            currentStep: 0,
            totalSteps: 3,
            showCounter: false,
            counterLabelBuilder: (_, _) =>
                throw StateError('Hidden counters must not request copy'),
          ),
        ),
      ),
    );
    expect(find.byType(AnimatedContainer), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
