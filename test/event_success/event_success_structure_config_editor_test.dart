import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edits repeat policy and activity assignment goals', (
    tester,
  ) async {
    var value = const EventSuccessStructureConfig(
      unitKind: EventSuccessUnitKind.pairs,
      unitSize: 2,
      rotationIntervalMinutes: 15,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return EventSuccessStructureConfigEditor(
                  value: value,
                  targetAttendeeCount: 12,
                  enabled: true,
                  onChanged: (next) {
                    setState(() => value = next);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(_selectChip('Pairs', selected: true), findsOneWidget);
    expect(_selectChip('Auto', selected: true), findsOneWidget);
    expect(_selectChip('Avoid repeats', selected: true), findsOneWidget);

    await tester.tap(find.text('Fill extra rounds'));
    await tester.pump();

    expect(
      value.rotationRepeatStrategy,
      EventSuccessRotationRepeatStrategy.allowWhenExhausted,
    );
    expect(_selectChip('Fill extra rounds', selected: true), findsOneWidget);

    await tester.tap(find.text('Spread skill'));
    await tester.pump();

    expect(value.balanceActivityAttributes, [
      EventSuccessActivityAssignmentAttribute.skillBand,
    ]);
    expect(value.clusterActivityAttributes, isEmpty);
    expect(_selectChip('Spread skill', selected: true), findsOneWidget);

    await tester.tap(find.text('Skill together'));
    await tester.pump();

    expect(value.balanceActivityAttributes, isEmpty);
    expect(value.clusterActivityAttributes, [
      EventSuccessActivityAssignmentAttribute.skillBand,
    ]);
    expect(_selectChip('Skill together', selected: true), findsOneWidget);
  });
}

Finder _selectChip(String label, {bool? selected}) {
  final chip = find.widgetWithText(CatchChip, label);
  if (selected == null) return chip;
  return find.descendant(
    of: chip,
    matching: find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.selected == selected,
    ),
  );
}
