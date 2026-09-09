import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('number stepper uses caller tooltips and keeps range controls', (
    tester,
  ) async {
    final changes = <num>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: Scaffold(
          body: CatchStepper(
            value: 0,
            min: 0,
            max: 2,
            valueLabelBuilder: (value) => '$value places',
            decreaseSemanticLabel: 'Réduire',
            increaseSemanticLabel: 'Augmenter',
            onChanged: changes.add,
          ),
        ),
      ),
    );
    expect(find.byTooltip('Réduire'), findsOneWidget);
    expect(find.byTooltip('Augmenter'), findsOneWidget);
    await tester.tap(find.byTooltip('Réduire'));
    expect(changes, isEmpty);
    await tester.tap(find.byTooltip('Augmenter'));
    expect(changes, [1]);
  });

  testWidgets('optional field labels preserve caller copy at large text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final copy = CatchFieldLabelTextCopy(
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
                child: CatchFieldLabelText(
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
          tester.getSemantics(find.byType(CatchFieldLabelText)).label,
          'Nom, facultatif',
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: Scaffold(
            body: CatchFieldLabelText.inline(
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
        home: CatchFrameworkErrorState(
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
          body: CatchAttributionRow(
            brandLabel: 'Notre marque',
            trailing: 'À partager',
          ),
        ),
      ),
    );
    expect(find.text('Notre marque'), findsOneWidget);
    expect(find.text('À partager'), findsOneWidget);
  });
}
