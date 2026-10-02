import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpSupportRow(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
  String? text,
  bool showErrorIcon = false,
  String? counter = '10 / 10',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: CatchTheme.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              key: const ValueKey('field-width'),
              width: width,
              child: CatchFieldSupportRow(
                text: text,
                counter: counter,
                color: Colors.black,
                showErrorIcon: showErrorIcon,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final textScale in [1.0, 2.0]) {
    for (final error in [false, true]) {
      testWidgets(
        'support without counter fills its lane at $textScale (error: $error)',
        (tester) async {
          await pumpSupportRow(
            tester,
            width: 320,
            textScale: textScale,
            text: 'Helper',
            counter: null,
            showErrorIcon: error,
          );
          final field = tester.getRect(
            find.byKey(const ValueKey('field-width')),
          );
          final rows = find
              .descendant(
                of: find.byType(CatchFieldSupportRow),
                matching: find.byType(Row),
              )
              .evaluate();
          expect(
            rows.any(
              (element) =>
                  tester.getSize(find.byWidget(element.widget)).width ==
                  field.width,
            ),
            isTrue,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('counter retains trailing alignment at normal width', (
    tester,
  ) async {
    await pumpSupportRow(tester, width: 320, text: 'Helper');
    final field = tester.getRect(find.byKey(const ValueKey('field-width')));
    final counter = tester.getRect(find.text('10 / 10'));
    final helper = tester.getRect(find.text('Helper'));
    expect(counter.right, closeTo(field.right, 0.01));
    // Different type metrics may shift glyph tops slightly; both labels must
    // still occupy the same line rather than reflowing at the normal width.
    expect((counter.center.dy - helper.center.dy).abs(), lessThan(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('counter wraps within a narrow field at large text', (
    tester,
  ) async {
    await pumpSupportRow(tester, width: 40, textScale: 2);
    final field = tester.getRect(find.byKey(const ValueKey('field-width')));
    final counter = tester.getRect(find.text('10 / 10'));
    expect(counter.width, lessThanOrEqualTo(field.width));
    expect(counter.right, closeTo(field.right, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large counter reflows below complete helper copy', (
    tester,
  ) async {
    await pumpSupportRow(tester, width: 80, textScale: 2, text: 'Try again');
    expect(find.text('Try again'), findsOneWidget);
    final helper = tester.getRect(find.text('Try again'));
    final counter = tester.getRect(find.text('10 / 10'));
    expect(counter.top, greaterThanOrEqualTo(helper.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large error and counter retain readable recovery semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await pumpSupportRow(
      tester,
      width: 80,
      textScale: 2,
      text: 'Try again',
      showErrorIcon: true,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.bySemanticsLabel('Try again'), findsOneWidget);
    final helper = tester.getRect(find.text('Try again'));
    final counter = tester.getRect(find.text('10 / 10'));
    expect(counter.top, greaterThanOrEqualTo(helper.bottom));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
