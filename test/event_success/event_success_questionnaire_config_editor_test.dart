import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects questionnaire templates with CatchField choices', (
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
                  onChanged: (next) => setState(() => value = next),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(_choice('Balanced', selected: true), findsNothing);
    expect(find.text('4 questions'), findsOneWidget);
    expect(find.text("Tonight I'm most up for"), findsNothing);
    await _openQuestionSetField(tester);
    expect(_choice('Balanced', selected: true), findsOneWidget);
    expect(_choice('Custom', selected: false), findsOneWidget);

    _invokeChoice(tester, 'Custom');
    await tester.pump();

    expect(value.usesCustom, isTrue);
    expect(find.text('Prompt'), findsWidgets);
    await _openQuestionSetField(tester);
    expect(_choice('Custom', selected: true), findsOneWidget);

    _invokeChoice(tester, 'Flirty');
    await tester.pump();

    expect(value.templateId, EventSuccessQuestionnairePackLibrary.flirtyId);
    await _openQuestionSetField(tester);
    expect(_choice('Flirty', selected: true), findsOneWidget);
    expect(_choice('Custom', selected: false), findsOneWidget);
    expect(find.text("Tonight I'm most up for"), findsNothing);
  });
}

void _invokeChoice(WidgetTester tester, String label) {
  tester.widgetList<CatchFieldChoiceChip>(_choice(label)).last.onPressed();
}

Future<void> _openQuestionSetField(WidgetTester tester) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == 'Question set',
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
