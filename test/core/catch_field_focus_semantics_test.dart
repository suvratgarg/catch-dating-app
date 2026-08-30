import 'dart:ui' show SemanticsAction;

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

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

  testWidgets(
    'empty optional input exposes one Add semantic and restores its field label on focus',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CatchField.input(
              title: 'Job title',
              controller: controller,
              focusNode: focusNode,
              isOptional: true,
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(TextField)).label,
        'Add job title, optional',
      );
      expect(find.bySemanticsLabel('Add job title, optional'), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(focusNode.hasFocus, isTrue);
      expect(tester.getSemantics(find.byType(TextField)).label, 'Job title');
      expect(find.bySemanticsLabel('Add job title, optional'), findsNothing);
      semantics.dispose();
    },
  );

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
    'toggle rows contribute one keyboard focus stop and switch node',
    (tester) async {
      final before = FocusNode(debugLabel: 'before toggle');
      final after = FocusNode(debugLabel: 'after toggle');
      final semantics = tester.ensureSemantics();
      addTearDown(before.dispose);
      addTearDown(after.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                TextButton(
                  focusNode: before,
                  onPressed: () {},
                  child: const Text('Before'),
                ),
                CatchField.toggle(
                  title: 'Show my pace',
                  value: true,
                  onChanged: (_) {},
                ),
                TextButton(
                  focusNode: after,
                  onPressed: () {},
                  child: const Text('After'),
                ),
              ],
            ),
          ),
        ),
      );

      before.requestFocus();
      await tester.pump();
      final scope = FocusScope.of(tester.element(find.byType(Scaffold)));
      expect(scope.nextFocus(), isTrue);
      await tester.pump();
      expect(before.hasFocus, isFalse);
      expect(after.hasFocus, isFalse);
      expect(find.bySemanticsLabel('Show my pace'), findsOneWidget);

      expect(scope.nextFocus(), isTrue);
      await tester.pump();
      expect(after.hasPrimaryFocus, isTrue);
      semantics.dispose();
    },
  );

  testWidgets('rounded press chrome transfers to one rounded active outline', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpField(tester, controller: controller, focusNode: focusNode);

    BoxDecoration overlayDecoration(Key key) =>
        tester.widget<AnimatedContainer>(find.byKey(key)).decoration
            as BoxDecoration;
    BoxDecoration pressedDecoration() =>
        overlayDecoration(CatchField.pressOverlayKey);
    BoxDecoration activeDecoration() =>
        overlayDecoration(const ValueKey<String>('catch-field-active-overlay'));

    expect(pressedDecoration().border, isNull);
    expect(
      pressedDecoration().borderRadius,
      BorderRadius.circular(CatchFieldTokens.tileRadius),
    );
    expect(pressedDecoration().color, Colors.transparent);
    expect(activeDecoration().border, isNull);
    expect(
      activeDecoration().borderRadius,
      BorderRadius.circular(CatchFieldTokens.tileRadius),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CatchField)),
    );
    await tester.pump();

    expect(
      pressedDecoration().border,
      CatchBorder.resolve(
        CatchTokens.editorialLight,
        CatchBorderRole.boundary,
      ).all,
    );
    expect(
      pressedDecoration().borderRadius,
      BorderRadius.circular(CatchFieldTokens.tileRadius),
    );
    expect(pressedDecoration().color, isNot(equals(Colors.transparent)));
    expect(activeDecoration().border, isNull);
    expect(focusNode.hasFocus, isFalse);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 100));
    expect(
      pressedDecoration().border,
      CatchBorder.resolve(
        CatchTokens.editorialLight,
        CatchBorderRole.boundary,
      ).all,
    );
    expect(pressedDecoration().color, isNot(equals(Colors.transparent)));

    await gesture.up();
    await tester.pump();

    // The pressed layer keeps the shared stroke through the tap frame so
    // focus activation cannot introduce a transparent flash.
    expect(
      pressedDecoration().border,
      CatchBorder.resolve(
        CatchTokens.editorialLight,
        CatchBorderRole.boundary,
      ).all,
    );
    expect(activeDecoration().border, isNull);

    await tester.pump();

    expect(pressedDecoration().border, isNull);
    expect(activeDecoration().border, isNotNull);
    expect(
      activeDecoration().borderRadius,
      BorderRadius.circular(CatchFieldTokens.tileRadius),
    );
    expect(activeDecoration().boxShadow, isNotEmpty);
    expect(focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    final activeGesture = await tester.startGesture(
      tester.getCenter(find.byType(CatchField)),
    );
    await tester.pump();

    expect(
      pressedDecoration().border,
      CatchBorder.resolve(
        CatchTokens.editorialLight,
        CatchBorderRole.boundary,
      ).all,
    );
    expect(activeDecoration().border, isNull);
    expect(pressedDecoration().borderRadius, activeDecoration().borderRadius);

    await activeGesture.up();
    await tester.pump();
  });

  testWidgets('full-bleed keyboard focus paints one inset perimeter', (
    tester,
  ) async {
    final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy = previousHighlightStrategy,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 390,
            child: CatchScreenBody(
              scrollable: false,
              pt: 0,
              pb: 0,
              child: CatchSection.fieldRows(
                first: true,
                children: [
                  CatchField.nav(title: 'Reminder timing', onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final scope = FocusScope.of(tester.element(find.byType(Scaffold)));
    expect(scope.nextFocus(), isTrue);
    await tester.pump();

    final overlayFinder = find.byKey(
      const ValueKey<String>('catch-field-active-overlay'),
    );
    final overlay = tester.widget<AnimatedContainer>(overlayFinder);
    final decoration = overlay.decoration! as BoxDecoration;
    final overlayRect = tester.getRect(overlayFinder);

    expect(
      decoration.border,
      CatchBorder.resolve(
        CatchTokens.editorialLight,
        CatchBorderRole.focus,
      ).all,
    );
    expect(decoration.borderRadius, BorderRadius.zero);
    expect(decoration.boxShadow, isEmpty);
    expect(overlayRect.left, 0);
    expect(overlayRect.right, 390);
  });

  testWidgets(
    'non-text disclosure label becomes primary only after the opening gesture',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: CatchField.control(
              title: 'Religion',
              body: 'Christian',
              isOptional: true,
              control: SizedBox(height: 80),
            ),
          ),
        ),
      );

      Color? labelColor() =>
          tester.widget<Text>(find.text('Religion')).style?.color;

      expect(labelColor(), CatchTokens.editorialLight.ink3);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Religion')),
      );
      await tester.pump();

      expect(labelColor(), CatchTokens.editorialLight.ink3);

      await gesture.up();
      await tester.pump();

      expect(labelColor(), CatchTokens.editorialLight.ink);
      expect(
        tester.widget<Text>(find.text(' · Optional')).style?.color,
        CatchTokens.editorialLight.ink3,
      );

      await tester.tap(find.text('Religion'));
      await tester.pump();

      expect(labelColor(), CatchTokens.editorialLight.ink3);
    },
  );

  testWidgets(
    'choice factory inherits the semantic active label color in dark mode',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CatchField.choices<String>(
              title: 'Languages',
              values: const ['English', 'Hindi'],
              itemLabel: (value) => value,
              selected: const {'English'},
              onSelectionChanged: (_) {},
              multi: true,
              initiallyOpen: true,
            ),
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.text('Languages')).style?.color,
        CatchTokens.editorialDark.ink,
      );
    },
  );

  testWidgets('select label inherits the root focus color resolver', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchField.select<String>(
            title: 'City',
            values: const ['Indore', 'Mumbai'],
            itemLabel: (value) => value,
            value: 'Indore',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    Text label() => tester.widget<Text>(find.text('City'));
    expect(label().style?.color, CatchTokens.editorialLight.ink3);

    await tester.tap(find.text('City'));
    await tester.pump();

    expect(label().style?.color, CatchTokens.editorialLight.ink);
  });

  testWidgets('expanded error label keeps danger precedence', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CatchField.control(
            title: 'Religion',
            body: 'Christian',
            error: 'Choose a religion',
            control: SizedBox(height: 80),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Religion'));
    await tester.pump();

    expect(
      tester.widget<Text>(find.text('Religion')).style?.color,
      CatchTokens.editorialLight.danger,
    );
  });

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
    expect(focusNode.hasFocus, isFalse);
    expect(tester.testTextInput.isVisible, isFalse);

    await pumpFeatureUi(tester);

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
      expect(secondFocus.hasFocus, isFalse);

      await pumpFeatureUi(tester);

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
