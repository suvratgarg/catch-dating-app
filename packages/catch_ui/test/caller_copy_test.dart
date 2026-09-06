import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('optional field labels preserve caller copy at large text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final copy = CatchFormFieldLabelCopy(
        optionalLabel: 'Facultatif',
        optionalSuffix: ' (facultatif)',
        optionalSemantics: (label) => '$label, facultatif',
      );
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: CatchTheme.light,
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: CatchFormFieldLabel(
                  label: 'Nom',
                  copy: copy,
                  isOptional: true,
                ),
              ),
            ),
          ),
        );
        expect(
          find.text('Facultatif'),
          scale == 1 ? findsOneWidget : findsNothing,
        );
        expect(
          tester.getSemantics(find.byType(CatchFormFieldLabel)).label,
          'Nom, facultatif',
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: Scaffold(
            body: CatchFormFieldLabel.inline(
              label: 'Nom',
              copy: copy,
              isOptional: true,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
      expect(find.text(' (facultatif)'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('framework recovery and debug disclosure use caller copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: CatchFrameworkErrorView(
          copy: const CatchFrameworkErrorCopy(
            title: 'Une erreur est survenue',
            message: 'Veuillez réessayer',
            debugDetailsLabel: 'Détails techniques',
          ),
          details: FlutterErrorDetails(exception: StateError('diagnostic')),
          showDebugDetails: true,
        ),
      ),
    );
    expect(find.text('Une erreur est survenue'), findsOneWidget);
    expect(find.text('Veuillez réessayer'), findsOneWidget);
    expect(find.text('Détails techniques'), findsOneWidget);
    await tester.tap(find.text('Détails techniques'));
    await tester.pumpAndSettle();
    expect(find.textContaining('diagnostic'), findsOneWidget);
  });

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
