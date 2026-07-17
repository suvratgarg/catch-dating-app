import 'dart:math' as math;

import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_pump_helpers.dart';
import 'test_support.dart';

void main() {
  testWidgets('CatchField choices wrap and report caller-owned selection', (
    tester,
  ) async {
    Set<String>? nextSelection;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 280,
          child: CatchField.choices<String>(
            title: 'Languages',
            body: 'English',
            values: const ['English', 'Hindi', 'Marathi', 'Gujarati'],
            itemLabel: (value) => value,
            selected: const {'English'},
            multi: true,
            initiallyOpen: true,
            onSelectionChanged: (selection) => nextSelection = selection,
            onCancel: () {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    final chipTops = [
      for (final label in const ['English', 'Hindi', 'Marathi', 'Gujarati'])
        tester.getTopLeft(find.byKey(ValueKey('catch-field-choice-$label'))).dy,
    ];
    expect(chipTops.toSet().length, greaterThan(1));
    final chipRects = [
      for (final label in const ['English', 'Hindi', 'Marathi', 'Gujarati'])
        tester.getRect(find.byKey(ValueKey('catch-field-choice-$label'))),
    ];
    final firstRowTop = chipRects.map((rect) => rect.top).reduce(math.min);
    final firstRowBottom = chipRects
        .where((rect) => (rect.top - firstRowTop).abs() < 0.1)
        .map((rect) => rect.bottom)
        .reduce(math.max);
    final secondRowTop = chipRects
        .where((rect) => rect.top > firstRowTop + 0.1)
        .map((rect) => rect.top)
        .reduce(math.min);
    expect(
      secondRowTop - firstRowBottom,
      closeTo(CatchFieldTokens.chipRunSpacing, 0.1),
    );
    final englishRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-choice-English')),
    );
    final englishLabel = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('catch-field-choice-English')),
        matching: find.text('English'),
      ),
    );
    expect(
      englishRect.height,
      closeTo(CatchFieldTokens.chipVisualMinHeight, 2.1),
    );
    expect(englishLabel.style?.fontWeight, FontWeight.w600);
    expect(englishLabel.style?.color, CatchTokens.editorialLight.primaryInk);
    final fieldRect = tester.getRect(find.byType(CatchField));
    final controlRect = tester.getRect(
      find.byWidgetPredicate((widget) => widget is CatchFieldChoiceControl),
    );
    expect(
      controlRect.right,
      closeTo(fieldRect.right - CatchFieldTokens.rowHorizontalPadding, 0.1),
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.byKey(const ValueKey('catch-field-control-opacity')),
          )
          .duration,
      CatchFieldTokens.standard,
    );

    await tester.tap(find.byKey(const ValueKey('catch-field-choice-Hindi')));
    expect(nextSelection, const {'English', 'Hindi'});
  });

  testWidgets('CatchField disclosure validation follows its commit bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Languages',
          body: 'English',
          control: const Text('Language control'),
          initiallyOpen: true,
          error: 'Choose at least one language.',
          onCancel: () {},
          onSubmit: () {},
        ),
      ),
    );

    final doneRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-done')),
    );
    final errorRect = tester.getRect(
      find.text('Choose at least one language.'),
    );

    expect(errorRect.top, greaterThan(doneRect.bottom));
    expect(
      find.byKey(const ValueKey('catch-field-root-support')),
      findsOneWidget,
    );
  });

  testWidgets('CatchField clearable choice does not imply Optional copy', (
    tester,
  ) async {
    var selected = <String>{'Indore'};

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchField.choices<String>(
            title: 'City',
            values: const ['Indore', 'Mumbai'],
            itemLabel: (value) => value,
            selected: selected,
            allowEmptySelection: true,
            initiallyOpen: true,
            onSelectionChanged: (next) => setState(() => selected = next),
            onCancel: () {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Optional'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('catch-field-choice-Indore')));
    await tester.pump();
    expect(selected, isEmpty);
    expect(find.textContaining('Optional'), findsNothing);
  });

  testWidgets(
    'CatchField standardizes empty input and choice Add rows at rest',
    (tester) async {
      final inputKey = GlobalKey();
      final multilineInputKey = GlobalKey();
      final choiceKey = GlobalKey();

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchField.input(
                  key: inputKey,
                  title: 'Job title',
                  icon: CatchIcons.workOutline,
                  isOptional: true,
                ),
                CatchField.input(
                  key: multilineInputKey,
                  title: 'Review',
                  minLines: 2,
                  maxLines: 4,
                  isOptional: true,
                ),
                CatchField.choices<String>(
                  key: choiceKey,
                  title: 'Workout',
                  values: const ['Never', 'Often'],
                  itemLabel: (value) => value,
                  selected: const {},
                  onSelectionChanged: (_) {},
                  addable: true,
                  isOptional: true,
                  icon: CatchIcons.fitnessCenterOutlined,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Add job title · Optional'), findsOneWidget);
      expect(find.text('Add review · Optional'), findsOneWidget);
      expect(find.text('Add workout · Optional'), findsOneWidget);
      expect(find.text('Job title'), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.text('Workout'), findsNothing);
      expect(
        tester.getSize(find.byKey(inputKey)).height,
        closeTo(tester.getSize(find.byKey(choiceKey)).height, 0.1),
      );
      expect(
        tester.getSize(find.byKey(multilineInputKey)).height,
        closeTo(tester.getSize(find.byKey(choiceKey)).height, 0.1),
      );
      expect(
        tester.getCenter(find.byIcon(CatchIcons.workOutline)).dy,
        closeTo(tester.getCenter(find.text('Add job title · Optional')).dy, 1),
      );

      final addText = tester.widget<Text>(
        find.text('Add job title · Optional'),
      );
      final spans = (addText.textSpan! as TextSpan).children!;
      expect(spans.first.style?.color, CatchTokens.editorialLight.primary);
      expect(spans.first.style?.fontSize, 14);
      expect(spans.first.style?.fontWeight, FontWeight.w600);
      expect(spans.last.style?.color, CatchTokens.editorialLight.ink3);
      expect(spans.last.style?.fontWeight, FontWeight.w500);

      final multilineTextField = find.descendant(
        of: find.byKey(multilineInputKey),
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(multilineTextField).minLines, isNull);
      expect(tester.widget<TextField>(multilineTextField).maxLines, 1);

      await tester.tap(multilineTextField);
      await tester.pump();

      expect(tester.widget<TextField>(multilineTextField).minLines, 2);
      expect(tester.widget<TextField>(multilineTextField).maxLines, 4);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Add review · Optional'), findsNothing);
    },
  );

  testWidgets('CatchField syncs external controller edits into validation', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchField.input(
            title: 'Date of birth',
            controller: controller,
            readOnly: true,
            onTap: () => controller.text = '15/04/1997',
            validator: (value) =>
                value == null || value.isEmpty ? 'Pick a date' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);

    await tester.tap(find.text('Date of birth'));
    await tester.pump();

    expect(controller.text, '15/04/1997');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('CatchField row counter appears on focus or error', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'ABC');
    addTearDown(controller.dispose);

    Widget field({String? error}) => _wrap(
      CatchField.input(
        title: 'Invite code',
        controller: controller,
        maxLength: 10,
        error: error,
      ),
    );

    await tester.pumpWidget(field());
    expect(find.text('3 / 10'), findsNothing);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('3 / 10'), findsOneWidget);

    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.text('3 / 10'), findsNothing);

    await tester.pumpWidget(field(error: 'Use a valid code.'));
    await tester.pump();
    expect(find.text('3 / 10'), findsOneWidget);
  });

  testWidgets('CatchField underline counter remains focus-only', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Hello');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        CatchField.input(
          title: 'Bio',
          controller: controller,
          variant: CatchFieldVariant.underline,
          maxLength: 20,
          error: 'Review this value.',
        ),
      ),
    );

    expect(find.text('5 / 20'), findsNothing);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('5 / 20'), findsOneWidget);

    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.text('5 / 20'), findsNothing);
  });

  testWidgets('CatchField renders optional field marker', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatchField.input(
          title: 'Bio',
          isOptional: true,
          placeholder: 'Share a little about yourself',
        ),
      ),
    );

    expect(find.text('Bio'), findsNothing);
    expect(find.text('Add bio · Optional'), findsOneWidget);
    expect(find.text(' · Optional'), findsNothing);
    expect(find.text('Optional'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Add bio, optional',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump(CatchMotion.fast);

    expect(find.text('Bio'), findsOneWidget);
    expect(find.text(' · Optional'), findsOneWidget);
    expect(find.text('Share a little about yourself'), findsOneWidget);
  });

  testWidgets(
    'CatchField keeps empty native text entry mounted through focus',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: CatchField.input(
              title: 'Public name',
              controller: controller,
              inputHint: 'e.g. Aanya',
            ),
          ),
        ),
      );

      expect(find.text('Public name'), findsNothing);
      expect(find.text('Add public name'), findsOneWidget);
      expect(find.text('e.g. Aanya'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      final inputElement = tester.element(find.byType(TextField));

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.element(find.byType(TextField)), same(inputElement));
      expect(find.text('Public name'), findsOneWidget);
      expect(find.text('e.g. Aanya'), findsOneWidget);

      var editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.focusNode.hasFocus, isTrue);

      await tester.enterText(find.byType(TextField), 'Aanya');
      await tester.pump();

      expect(controller.text, 'Aanya');
      editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.style.fontSize, 14);
      expect(editableText.style.fontWeight, FontWeight.w700);

      await tester.enterText(find.byType(TextField), '');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(controller.text, isEmpty);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.element(find.byType(TextField)), same(inputElement));
      expect(find.text('Public name'), findsNothing);
      expect(find.text('Add public name'), findsOneWidget);
    },
  );

  testWidgets('CatchField keeps labels out of focused input hints', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchField.input(title: 'Instagram', inputHint: 'Instagram'),
        ),
      ),
    );

    expect(find.text('Add instagram'), findsOneWidget);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump(CatchMotion.fast);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, isNull);
    expect(find.text('Instagram'), findsOneWidget);
  });

  testWidgets('CatchField row multiline input uses textarea typography', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchField.input(
            title: 'Answer',
            initialValue: 'Catch me if you can',
            maxLines: 3,
            minLines: 2,
          ),
        ),
      ),
    );

    var editable = tester.widget<EditableText>(find.byType(EditableText));
    var field = tester.widget<TextField>(find.byType(TextField));
    expect(editable.style.fontSize, CatchFieldTokens.valueFontSize);
    expect(editable.style.fontWeight, FontWeight.w500);
    expect(editable.style.height, CatchFieldTokens.multilineValueLineHeight);
    expect(field.decoration?.hintStyle?.fontWeight, FontWeight.w500);
    expect(
      field.decoration?.hintStyle?.height,
      CatchFieldTokens.multilineValueLineHeight,
    );

    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchField.input(title: 'Display name', initialValue: 'Aanya'),
        ),
      ),
    );

    editable = tester.widget<EditableText>(find.byType(EditableText));
    field = tester.widget<TextField>(find.byType(TextField));
    expect(editable.style.fontWeight, FontWeight.w700);
    expect(editable.style.height, CatchFieldTokens.valueLineHeight);
    expect(field.decoration?.hintStyle?.fontWeight, FontWeight.w700);
    expect(
      field.decoration?.hintStyle?.height,
      CatchFieldTokens.valueLineHeight,
    );
  });

  testWidgets('CatchField collapsed text entry reports focus changes', (
    tester,
  ) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: CatchField.input(
            title: 'Public name',
            inputHint: 'e.g. Aanya',
            onFocusChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump(CatchMotion.fast);

    expect(changes, <bool>[true]);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(changes, <bool>[true, false]);
  });

  testWidgets(
    'CatchField expands collapsed text entry when validation fails before focus',
    (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _wrap(
          Form(
            key: formKey,
            child: const SizedBox(
              width: 320,
              child: CatchField.input(
                title: 'Public name',
                inputHint: 'e.g. Aanya',
                validator: _requiredPublicName,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Public name'), findsNothing);
      expect(find.text('Add public name'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      final inputElement = tester.element(find.byType(TextField));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.element(find.byType(TextField)), same(inputElement));
      expect(find.text('Public name'), findsOneWidget);
      expect(find.text('e.g. Aanya'), findsOneWidget);
      expect(find.text('Public name is required'), findsOneWidget);
    },
  );

  testWidgets(
    'CatchField expands initial text and collapses after external clear',
    (tester) async {
      final controller = TextEditingController(text: 'Aanya');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: CatchField.input(
              title: 'Public name',
              controller: controller,
              inputHint: 'e.g. Aanya',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);

      controller.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Public name'), findsNothing);
      expect(find.text('Add public name'), findsOneWidget);
    },
  );

  testWidgets(
    'CatchField populated clear target does not change collapsed row height',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchField.input(
                  key: ValueKey('plain-populated-field'),
                  title: 'Public name',
                  initialValue: 'Run',
                ),
                CatchField.input(
                  key: ValueKey('clearable-populated-field'),
                  title: 'Display name',
                  initialValue: 'Run',
                  showClearButton: true,
                ),
              ],
            ),
          ),
        ),
      );

      final plainHeight = tester
          .getSize(find.byKey(const ValueKey('plain-populated-field')))
          .height;
      final clearableHeight = tester
          .getSize(find.byKey(const ValueKey('clearable-populated-field')))
          .height;
      final clearableEditable = find.descendant(
        of: find.byKey(const ValueKey('clearable-populated-field')),
        matching: find.byType(EditableText),
      );

      expect(clearableHeight, closeTo(plainHeight, 0.1));
      expect(find.byTooltip('Clear Display name'), findsOneWidget);
      expect(
        tester.getCenter(find.byTooltip('Clear Display name')).dy,
        closeTo(tester.getCenter(clearableEditable).dy, 0.5),
      );
    },
  );

  testWidgets('CatchField compact input centers hint and icon vertically', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Center(
          child: SizedBox(
            width: 320,
            child: CatchField.input(
              title: 'Search',
              showLabel: false,
              placeholder: 'Search by name',
              size: CatchFieldSize.compact,
              prefixIcon: Icon(CatchIcons.searchRounded, size: 18),
            ),
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(TextField));
    final hintRect = tester.getRect(find.text('Search by name'));
    final iconRect = tester.getRect(find.byIcon(CatchIcons.searchRounded));

    expect(
      (hintRect.center.dy - fieldRect.center.dy).abs(),
      lessThanOrEqualTo(2),
    );
    expect(
      (iconRect.center.dy - fieldRect.center.dy).abs(),
      lessThanOrEqualTo(2),
    );
  });

  testWidgets('CatchField keeps a same-name hint when its label is hidden', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchField.input(
            title: 'Search for a meeting point',
            showLabel: false,
            placeholder: 'Search for a meeting point',
            size: CatchFieldSize.floating,
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search for a meeting point'), findsOneWidget);
  });

  testWidgets('CatchField.select validates and reports selection changes', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    CityOption? selected;

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchField.select<CityOption>(
            title: 'City',
            values: defaultCityOptions,
            itemLabel: (city) => city.label,
            value: selected,
            prefixIcon: Icon(CatchIcons.locationOnOutlined),
            validator: (value) => value == null ? 'Please select a city' : null,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    final iconRect = tester.getRect(find.byIcon(CatchIcons.locationOnOutlined));
    final titleRect = tester.getRect(find.text('City'));
    final valueRect = tester.getRect(find.text('Select city'));
    final chevronRect = tester.getRect(
      find.byIcon(CatchIcons.expandMoreRounded),
    );

    expect(iconRect.right, lessThan(titleRect.left));
    expect((titleRect.left - valueRect.left).abs(), lessThanOrEqualTo(1));
    expect(chevronRect.center.dy, closeTo(valueRect.center.dy, 0.1));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please select a city'), findsOneWidget);

    final label = tester.widget<Text>(find.text('City'));
    final value = tester.widget<Text>(find.text('Select city'));
    final chevron = tester.widget<Icon>(
      find.byIcon(CatchIcons.expandMoreRounded),
    );
    final iconTheme = IconTheme.of(
      tester.element(find.byIcon(CatchIcons.locationOnOutlined)),
    );

    expect(label.style?.color, CatchTokens.editorialLight.danger);
    expect(value.style?.color, CatchTokens.editorialLight.ink3);
    expect(chevron.color, CatchTokens.editorialLight.ink3);
    expect(chevron.size, CatchFieldTokens.disclosureGlyphExtent);
    final rotation = tester.widget<AnimatedRotation>(
      find.ancestor(
        of: find.byIcon(CatchIcons.expandMoreRounded),
        matching: find.byType(AnimatedRotation),
      ),
    );
    expect(rotation.duration, CatchFieldTokens.reveal);
    expect(iconTheme.color, CatchTokens.editorialLight.ink2);

    await tester.tap(find.byIcon(CatchIcons.expandMoreRounded));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Mumbai').hitTestable());
    await pumpFeatureUi(tester);

    expect(selected, cityOptionByName('mumbai')!);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets(
    'CatchField.select exposes button semantics with label and value',
    (tester) async {
      final selected = cityOptionByName('mumbai')!;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: CatchField.select<CityOption>(
              title: 'City',
              values: defaultCityOptions,
              itemLabel: (city) => city.label,
              value: selected,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'City' &&
              widget.properties.value == 'Mumbai',
        ),
      );

      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isTrue);
    },
  );

  testWidgets('CatchField.select disabled state does not open menu', (
    tester,
  ) async {
    final selected = cityOptionByName('mumbai')!;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: CatchField.select<CityOption>(
            title: 'City',
            values: defaultCityOptions,
            itemLabel: (city) => city.label,
            value: selected,
            enabled: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'City' &&
            widget.properties.value == 'Mumbai',
      ),
    );

    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.enabled, isFalse);
    expect(semantics.properties.onTap, isNull);

    expect(find.text('Delhi'), findsNothing);
  });

  testWidgets('CatchField.select clears form state when options remove value', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final mumbai = cityOptionByName('mumbai')!;
    var selected = mumbai;
    var values = [mumbai, cityOptionByName('delhi')!];
    late StateSetter updateState;

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return SizedBox(
                width: 320,
                child: CatchField.select<CityOption>(
                  title: 'City',
                  values: values,
                  itemLabel: (city) => city.label,
                  value: selected,
                  validator: (value) =>
                      value == null ? 'Please select a city' : null,
                  onChanged: (value) {
                    if (value != null) selected = value;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Mumbai'), findsOneWidget);
    expect(formKey.currentState!.validate(), isTrue);

    updateState(() {
      values = [cityOptionByName('delhi')!];
    });
    await tester.pump();
    await tester.pump();

    expect(find.text('Select city'), findsOneWidget);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Please select a city'), findsOneWidget);
  });

  test('CatchField guards ambiguous form configuration', () {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    expect(
      () => CatchField.input(
        title: 'Name',
        controller: controller,
        initialValue: 'Aanya',
      ),
      throwsAssertionError,
    );

    expect(
      () => CatchField.select<String>(
        title: 'Activity',
        values: const ['Run', 'Run'],
        itemLabel: (value) => value,
      ),
      throwsAssertionError,
    );
  });

  testWidgets('CatchField.select opens the shared CatchMenu panel', (
    tester,
  ) async {
    CityOption? selected = cityOptionByName('ahmedabad');

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 240,
          child: CatchField.select<CityOption>(
            title: 'City',
            values: defaultCityOptions,
            value: selected,
            itemLabel: (city) => city.label,
            prefixIcon: Icon(CatchIcons.locationOnOutlined),
            showLabel: false,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(CatchIcons.expandMoreRounded));
    await pumpFeatureUi(tester);

    // Select renders through the shared CatchMenu panel, not raw Material
    // menu items; the selected option carries the shared check affordance.
    expect(find.byType(CatchMenu<Object?>), findsOneWidget);
    expect(find.byType(MenuItemButton), findsNothing);
    expect(find.byIcon(CatchIcons.check), findsOneWidget);

    final other = defaultCityOptions.firstWhere(
      (city) => city != cityOptionByName('ahmedabad'),
    );
    await tester.tap(find.text(other.label));
    await pumpFeatureUi(tester);

    expect(selected, other);
    expect(find.byType(CatchMenu<Object?>), findsNothing);
  });

  testWidgets(
    'CatchField.input pins controller, formatter, submit, validator, and support',
    (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();
      String? submitted;
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          Form(
            key: formKey,
            child: CatchField.input(
              title: 'Invite code',
              controller: controller,
              autofocus: true,
              helperText: 'Three digits',
              maxLength: 3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => value == null || value.length != 3
                  ? 'Enter three digits'
                  : null,
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      );

      expect(find.text('Three digits'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1a234');
      await tester.pump();
      expect(controller.text, '123');
      expect(find.text('3 / 3'), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, '123');
      expect(formKey.currentState!.validate(), isTrue);

      controller.text = '12';
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter three digits'), findsOneWidget);
    },
  );

  testWidgets(
    'CatchField.inputActions commits, cancels to its snapshot, and disables while saving',
    (tester) async {
      final controller = TextEditingController(text: 'Original');
      var original = controller.text;
      var open = false;
      var saving = false;
      var submits = 0;
      late StateSetter update;
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CatchField.inputActions(
                title: 'Bio',
                controller: controller,
                open: open,
                onOpenChanged: (next) => setState(() {
                  open = next;
                  if (next) original = controller.text;
                }),
                isLoading: saving,
                onCancel: () => setState(() {
                  controller.text = original;
                  open = false;
                }),
                onSubmit: () => setState(() {
                  submits += 1;
                  open = false;
                }),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(CatchField));
      await _pumpCatchFieldMotion(tester);
      await tester.enterText(find.byType(TextField), 'Committed');
      await tester.tap(find.byKey(const ValueKey('catch-field-done')));
      await _pumpCatchFieldMotion(tester);
      expect(submits, 1);
      expect(open, isFalse);

      await tester.tap(find.byType(CatchField));
      await _pumpCatchFieldMotion(tester);
      await tester.enterText(find.byType(TextField), 'Discarded');
      await tester.tap(find.byKey(const ValueKey('catch-field-cancel')));
      await _pumpCatchFieldMotion(tester);
      expect(controller.text, 'Committed');

      update(() {
        open = true;
        saving = true;
      });
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('catch-field-done')),
        warnIfMissed: false,
      );
      expect(submits, 1);
    },
  );

  for (final scale in [1.3, 2.0]) {
    testWidgets('CatchField input remains usable at ${scale}x text', (
      tester,
    ) async {
      final controller = TextEditingController(
        text: 'A long club description that must remain editable',
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 280,
            child: CatchField.input(
              title: 'Description',
              controller: controller,
              maxLines: 3,
            ),
          ),
          textScale: scale,
        ),
      );

      expect(tester.takeException(), isNull);
      expectMinimumAccessibleTarget(tester, find.byType(TextField));
    });
  }

  testWidgets('CatchField input lanes mirror in RTL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 280,
            child: CatchField.input(
              title: 'City',
              initialValue: 'Mumbai',
              prefixIcon: Icon(CatchIcons.locationOnOutlined),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getCenter(find.byIcon(CatchIcons.locationOnOutlined)).dx,
      greaterThan(tester.getCenter(find.byType(EditableText)).dx),
    );
  });
}

Widget _wrap(Widget child, {ThemeData? theme, double textScale = 1}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

Future<void> _pumpCatchFieldMotion(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(CatchFieldTokens.reveal);
  await tester.pump();
}

String? _requiredPublicName(String? value) {
  return value == null || value.isEmpty ? 'Public name is required' : null;
}
