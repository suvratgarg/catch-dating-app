import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchChip.tag renders passive compact metadata', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatchChip.tag(label: 'Easy', leading: Icon(Icons.bolt_rounded)),
      ),
    );

    final chip = _chip('Easy');
    final tokens = CatchTokens.of(tester.element(chip));
    final decoration = _chipDecoration(tester, chip);
    final semantics = _chipSemantics(tester, chip);

    expect(decoration.color, tokens.surface);
    expect(decoration.border?.top.color, tokens.line2);
    expect(decoration.boxShadow, isEmpty);
    expect(semantics.properties.button, isNull);
    expect(semantics.properties.selected, isNull);
    expect(
      find.descendant(of: chip, matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets(
    'CatchChip.selectable requests parent-owned selection and renders the selected inverse fill',
    (tester) async {
      const accent = Color(0xFF7A3B20);
      var selected = false;
      bool? requestedSelection;
      late StateSetter rebuild;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return CatchChip.selectable(
                label: 'Trail run',
                selected: selected,
                accent: accent,
                onChanged: (next) => requestedSelection = next,
              );
            },
          ),
        ),
      );

      final chip = _chip('Trail run');
      expect(_chipSemantics(tester, chip).properties.selected, isFalse);

      await tester.tap(chip);
      await tester.pump();

      expect(requestedSelection, isTrue);
      expect(
        _chipSemantics(tester, chip).properties.selected,
        isFalse,
        reason: 'CatchChip must not own or mutate selection state.',
      );

      rebuild(() => selected = requestedSelection!);
      await tester.pumpAndSettle();

      final selectedDecoration = _chipDecoration(tester, chip);
      final tokens = CatchTokens.of(tester.element(chip));
      final label = tester.widget<Text>(find.text('Trail run'));
      final scale = tester.widget<AnimatedScale>(
        find.descendant(of: chip, matching: find.byType(AnimatedScale)),
      );

      expect(_chipSemantics(tester, chip).properties.selected, isTrue);
      expect(_chipSemantics(tester, chip).properties.button, isTrue);
      expect(_chipSemantics(tester, chip).properties.enabled, isTrue);
      expect(selectedDecoration.color, accent);
      expect(selectedDecoration.border?.top.color, Colors.transparent);
      expect(selectedDecoration.boxShadow, isNotEmpty);
      expect(label.style?.color, tokens.onFill(accent));
      expect(label.overflow, TextOverflow.ellipsis);
      expect(
        scale.scale,
        1,
        reason: 'Selection must not permanently scale layout.',
      );
    },
  );

  testWidgets(
    'CatchChip.activity renders registry-backed soft and solid chips',
    (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrap(
          Wrap(
            children: [
              const CatchChip.activity(activityKind: ActivityKind.socialRun),
              CatchChip.activity(
                activityKind: ActivityKind.pickleball,
                emphasis: CatchChipEmphasis.solid,
                label: 'Primary court',
                onTap: () => taps += 1,
              ),
            ],
          ),
        ),
      );

      final softChip = _chip('Social run');
      final solidChip = _chip('Primary court');
      final softActivity = ActivityPalette.resolve(
        tester.element(softChip),
        ActivityKind.socialRun,
      );
      final solidActivity = ActivityPalette.resolve(
        tester.element(solidChip),
        ActivityKind.pickleball,
      );

      expect(_chipDecoration(tester, softChip).color, softActivity.soft);
      expect(_chipDecoration(tester, solidChip).color, solidActivity.accent);
      expect(
        find.descendant(
          of: softChip,
          matching: find.byIcon(softActivity.glyph),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: solidChip,
          matching: find.byIcon(solidActivity.glyph),
        ),
        findsOneWidget,
      );
      expect(_chipSemantics(tester, softChip).properties.button, isNull);
      expect(_chipSemantics(tester, solidChip).properties.button, isTrue);

      await tester.tap(solidChip);
      await tester.pump();

      expect(taps, 1);
    },
  );

  testWidgets('CatchChip.removable exposes one whole-chip removal action', (
    tester,
  ) async {
    var removals = 0;

    await tester.pumpWidget(
      _wrap(CatchChip.removable(label: 'Easy', onRemove: () => removals += 1)),
    );

    final chip = _chip('Easy');
    final semantics = _chipSemantics(tester, chip);

    expect(
      find.descendant(of: chip, matching: find.byIcon(CatchIcons.closeRounded)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: chip, matching: find.byType(InkWell)),
      findsOneWidget,
    );
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.selected, isNull);
    expect(semantics.properties.label, contains('Easy'));

    await tester.tap(find.text('Easy'));
    await tester.pump();

    expect(removals, 1);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

Finder _chip(String label) => find.widgetWithText(CatchChip, label);

BoxDecoration _chipDecoration(WidgetTester tester, Finder chip) {
  return tester
          .widget<AnimatedContainer>(
            find.descendant(of: chip, matching: find.byType(AnimatedContainer)),
          )
          .decoration!
      as BoxDecoration;
}

Semantics _chipSemantics(WidgetTester tester, Finder chip) {
  return tester.widget<Semantics>(
    find
        .descendant(
          of: chip,
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.label != null,
          ),
        )
        .first,
  );
}
