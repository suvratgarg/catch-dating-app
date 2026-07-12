import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects questionnaire template choices with CatchChip', (
    tester,
  ) async {
    var value = const EventSuccessQuestionnaireConfig.defaultTemplate();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return EventSuccessQuestionnaireConfigEditor(
                  value: value,
                  useBottomSheetForCustom: true,
                  onChanged: (next) => setState(() => value = next),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(_selectChip('Balanced', selected: true), findsOneWidget);
    expect(_selectChip('Custom', selected: false), findsOneWidget);

    await tester.tap(_selectChip('Custom'));
    await tester.pump();

    expect(value.usesCustom, isTrue);
    expect(_selectChip('Custom', selected: true), findsOneWidget);
    expect(find.text('Edit custom questions'), findsOneWidget);

    await tester.tap(_selectChip('Flirty'));
    await tester.pump();

    expect(value.templateId, EventSuccessQuestionnairePackLibrary.flirtyId);
    expect(_selectChip('Flirty', selected: true), findsOneWidget);
    expect(_selectChip('Custom', selected: false), findsOneWidget);
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
