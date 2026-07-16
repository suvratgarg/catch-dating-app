import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
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

    expect(_choice('Pairs', selected: true), findsOneWidget);
    expect(_choice('Auto', selected: true), findsOneWidget);
    expect(_choice('Avoid repeats', selected: true), findsOneWidget);

    _invokeChoice(tester, 'Fill extra rounds');
    await tester.pump();

    expect(
      value.rotationRepeatStrategy,
      EventSuccessRotationRepeatStrategy.allowWhenExhausted,
    );
    await _openField(tester, 'Repeat policy');
    expect(_choice('Fill extra rounds', selected: true), findsOneWidget);

    _invokeChoice(tester, 'Spread skill');
    await tester.pump();

    expect(value.balanceActivityAttributes, [
      EventSuccessActivityAssignmentAttribute.skillBand,
    ]);
    expect(value.clusterActivityAttributes, isEmpty);
    expect(_choice('Spread skill', selected: true), findsOneWidget);

    _invokeChoice(tester, 'Skill together');
    await tester.pump();

    expect(value.balanceActivityAttributes, isEmpty);
    expect(value.clusterActivityAttributes, [
      EventSuccessActivityAssignmentAttribute.skillBand,
    ]);
    expect(_choice('Skill together', selected: true), findsOneWidget);
  });
}

void _invokeChoice(WidgetTester tester, String label) {
  tester.widgetList<CatchFieldChoiceChip>(_choice(label)).last.onPressed();
}

Future<void> _openField(WidgetTester tester, String title) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == title,
  );
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pump(kThemeAnimationDuration);
  await tester.pump();
}

Finder _choice(String label, {bool? selected}) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchFieldChoiceChip &&
        widget.label == label &&
        (selected == null || widget.selected == selected),
  );
}
