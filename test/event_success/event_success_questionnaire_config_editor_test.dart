import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects questionnaire template choices with CatchSelectChip', (
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

    expect(_selectChip('Balanced', active: true), findsOneWidget);
    expect(_selectChip('Custom', active: false), findsOneWidget);

    await tester.tap(_selectChip('Custom'));
    await tester.pump();

    expect(value.usesCustom, isTrue);
    expect(_selectChip('Custom', active: true), findsOneWidget);
    expect(find.text('Edit custom questions'), findsOneWidget);

    await tester.tap(_selectChip('Flirty'));
    await tester.pump();

    expect(value.templateId, EventSuccessQuestionnairePackLibrary.flirtyId);
    expect(_selectChip('Flirty', active: true), findsOneWidget);
    expect(_selectChip('Custom', active: false), findsOneWidget);
  });
}

Finder _selectChip(String label, {bool? active}) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchSelectChip &&
        widget.label == label &&
        (active == null || widget.active == active),
  );
}
