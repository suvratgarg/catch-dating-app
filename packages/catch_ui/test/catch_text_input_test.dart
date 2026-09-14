import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final decorationEnabled in [false, true]) {
    for (final status in CatchTextInputStatus.values) {
      testWidgets('$status with decoration enabled=$decorationEnabled', (
        tester,
      ) async {
        final controller = TextEditingController(text: 'Original');
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CatchTextInput(
                controller: controller,
                focusNode: focus,
                status: status,
                decoration: InputDecoration(enabled: decorationEnabled),
              ),
            ),
          ),
        );
        final enabled =
            status == CatchTextInputStatus.enabled ||
            status == CatchTextInputStatus.inherited && decorationEnabled;
        await tester.tap(find.byType(CatchTextInput));
        await tester.pump();
        expect(focus.hasFocus, enabled);
        expect(tester.testTextInput.isVisible, enabled);
        if (enabled) {
          await tester.enterText(find.byType(TextField), 'Edited');
          expect(controller.text, 'Edited');
        } else {
          expect(controller.text, 'Original');
        }
      });
    }
  }

  for (final (mode, editable, focusable, selectable) in [
    (CatchTextInputMode.editable, true, true, true),
    (CatchTextInputMode.readOnly, false, true, true),
    (CatchTextInputMode.inactive, false, false, true),
    (CatchTextInputMode.editableWithoutSelection, true, true, false),
    (CatchTextInputMode.readOnlyWithoutSelection, false, true, false),
    (CatchTextInputMode.inactiveWithoutSelection, false, false, false),
  ]) {
    testWidgets(
      '$mode preserves editing, focus, selection and cursor defaults',
      (tester) async {
        final controller = TextEditingController(text: 'Original');
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CatchTextInput(
                controller: controller,
                focusNode: focus,
                mode: mode,
              ),
            ),
          ),
        );
        await tester.tap(find.byType(CatchTextInput));
        await tester.pump();
        expect(focus.hasFocus, focusable);
        expect(tester.testTextInput.isVisible, editable);
        final native = tester.widget<EditableText>(find.byType(EditableText));
        expect(native.enableInteractiveSelection, selectable);
        expect(native.showCursor, editable);
        if (editable) {
          await tester.enterText(find.byType(TextField), 'Edited');
          expect(controller.text, 'Edited');
        } else {
          expect(controller.text, 'Original');
        }
      },
    );
  }
}
