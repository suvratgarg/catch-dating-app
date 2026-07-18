import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_index_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchIndexRow owns selected button semantics and activation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchIndexRow(
            title: 'Running',
            semanticLabel: 'Running events',
            selected: true,
            onTap: () => taps += 1,
          ),
        ),
      ),
    );

    final semanticsWidget = tester.widget<Semantics>(
      find.descendant(
        of: find.byType(CatchIndexRow),
        matching: find.byType(Semantics),
      ).first,
    );
    expect(semanticsWidget.properties.label, 'Running events');
    expect(semanticsWidget.properties.button, isTrue);
    expect(semanticsWidget.properties.enabled, isTrue);
    expect(semanticsWidget.properties.selected, isTrue);
    await tester.tap(find.byType(CatchIndexRow));
    expect(taps, 1);
    semantics.dispose();
  });
}
