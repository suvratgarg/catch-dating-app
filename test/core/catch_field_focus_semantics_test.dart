import 'dart:ui' show SemanticsAction;

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('external focus node remains caller-owned', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpField(tester, controller: controller, focusNode: focusNode);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(() => focusNode.addListener(() {}), returnsNormally);
    expect(() => focusNode.requestFocus(), returnsNormally);
  });

  testWidgets('submission unfocuses by default', (tester) async {
    final controller = TextEditingController(text: 'Value');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var submissions = 0;

    await _pumpField(
      tester,
      controller: controller,
      focusNode: focusNode,
      onSubmitted: (_) => submissions++,
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submissions, 1);
    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('retainFocusOnSubmitted preserves native editing focus', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Value');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var submissions = 0;

    await _pumpField(
      tester,
      controller: controller,
      focusNode: focusNode,
      retainFocusOnSubmitted: true,
      onSubmitted: (_) => submissions++,
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submissions, 1);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('hidden label merges into one native editable semantics node', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final semantics = tester.ensureSemantics();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpField(tester, controller: controller, focusNode: focusNode);

    final editableNode = tester.getSemantics(find.byType(TextField));
    expect(editableNode.flagsCollection.isTextField, isTrue);
    expect(editableNode.label, 'Message');
    expect(
      editableNode.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(find.bySemanticsLabel('Message'), findsOne);
    semantics.dispose();
  });

  testWidgets('direct inputs contribute one keyboard focus stop each', (
    tester,
  ) async {
    final firstController = TextEditingController();
    final secondController = TextEditingController();
    final firstFocus = FocusNode();
    final secondFocus = FocusNode();
    addTearDown(firstController.dispose);
    addTearDown(secondController.dispose);
    addTearDown(firstFocus.dispose);
    addTearDown(secondFocus.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              CatchField.input(
                title: 'First field',
                controller: firstController,
                focusNode: firstFocus,
              ),
              CatchField.input(
                title: 'Second field',
                controller: secondController,
                focusNode: secondFocus,
              ),
            ],
          ),
        ),
      ),
    );

    final scope = FocusScope.of(tester.element(find.byType(Scaffold)));
    expect(scope.nextFocus(), isTrue);
    await tester.pump();
    expect(firstFocus.hasPrimaryFocus, isTrue);

    expect(scope.nextFocus(), isTrue);
    await tester.pump();
    expect(secondFocus.hasPrimaryFocus, isTrue);
  });

  testWidgets(
    'pressed outline appears on pointer down and focus arrives on pointer up',
    (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await _pumpField(tester, controller: controller, focusNode: focusNode);

      BoxDecoration pressedDecoration() =>
          tester
                  .widget<AnimatedContainer>(
                    find.byKey(
                      const ValueKey<String>('catch-field-active-overlay'),
                    ),
                  )
                  .decoration
              as BoxDecoration;

      expect(pressedDecoration().border, isNull);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CatchField)),
      );
      await tester.pump();

      expect(pressedDecoration().border, isNotNull);
      expect(focusNode.hasFocus, isFalse);

      await gesture.up();
      await tester.pump();

      expect(pressedDecoration().border, isNotNull);
      expect(pressedDecoration().boxShadow, isNotEmpty);
      expect(focusNode.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
    },
  );

  testWidgets('one disclosure gesture opens and focuses explicit text input', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Draft');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var open = false;
    var openChanges = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CatchField.inputActions(
              title: 'Prompt',
              controller: controller,
              focusNode: focusNode,
              open: open,
              onOpenChanged: (value) {
                openChanges++;
                setState(() => open = value);
              },
              onCancel: () => setState(() => open = false),
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Prompt')),
    );
    await tester.pump();
    expect(open, isFalse);
    expect(focusNode.hasFocus, isFalse);

    await gesture.up();
    await tester.pump();

    expect(open, isTrue);
    expect(openChanges, 1);
    expect(focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(open, isTrue);
    expect(openChanges, 1);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets(
    'one gesture cancels the previous field and focuses the next field',
    (tester) async {
      final firstController = TextEditingController(text: 'First value');
      final secondController = TextEditingController(text: 'Second value');
      final firstFocus = FocusNode();
      final secondFocus = FocusNode();
      addTearDown(firstController.dispose);
      addTearDown(secondController.dispose);
      addTearDown(firstFocus.dispose);
      addTearDown(secondFocus.dispose);
      var firstOpen = true;
      var secondOpen = false;
      var firstCancels = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  CatchField.inputActions(
                    title: 'First field',
                    controller: firstController,
                    focusNode: firstFocus,
                    open: firstOpen,
                    onOpenChanged: (value) {
                      setState(() => firstOpen = value);
                    },
                    onCancel: () {
                      firstCancels++;
                      setState(() => firstOpen = false);
                    },
                    onSubmit: () {},
                  ),
                  CatchField.inputActions(
                    title: 'Second field',
                    controller: secondController,
                    focusNode: secondFocus,
                    open: secondOpen,
                    onOpenChanged: (value) {
                      setState(() => secondOpen = value);
                    },
                    onCancel: () => setState(() => secondOpen = false),
                    onSubmit: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(firstFocus.hasFocus, isTrue);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Second field')),
      );
      await tester.pump();

      expect(firstOpen, isTrue);
      expect(secondOpen, isFalse);
      expect(firstCancels, 0);
      expect(firstFocus.hasFocus, isTrue);

      await gesture.up();
      await tester.pump();

      expect(firstOpen, isFalse);
      expect(secondOpen, isTrue);
      expect(firstCancels, 1);
      expect(secondFocus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
    },
  );

  testWidgets('onBlur fires once with the latest input value', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final blurredValues = <String>[];
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpField(
      tester,
      controller: controller,
      focusNode: focusNode,
      onBlur: blurredValues.add,
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Latest value');
    await tester.tapAt(const Offset(4, 4));
    await tester.pump();

    expect(blurredValues, <String>['Latest value']);
  });
}

Future<void> _pumpField(
  WidgetTester tester, {
  required TextEditingController controller,
  required FocusNode focusNode,
  bool retainFocusOnSubmitted = false,
  ValueChanged<String>? onSubmitted,
  ValueChanged<String>? onBlur,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: CatchField.input(
            title: 'Message',
            showLabel: false,
            inputHint: 'Message…',
            controller: controller,
            focusNode: focusNode,
            retainFocusOnSubmitted: retainFocusOnSubmitted,
            textInputAction: TextInputAction.done,
            variant: CatchFieldVariant.bare,
            onSubmitted: onSubmitted,
            onBlur: onBlur,
          ),
        ),
      ),
    ),
  );
}
