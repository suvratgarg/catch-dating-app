import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_pump_helpers.dart';
import 'test_support.dart';

void main() {
  testWidgets('CatchField preserves the last state when control is released', (
    tester,
  ) async {
    var controlled = true;
    late VoidCallback releaseControl;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            releaseControl = () => setState(() => controlled = false);
            return CatchField.control(
              title: 'Capacity',
              open: controlled ? true : null,
              onOpenChanged: (_) {},
              control: const Text('Capacity choices'),
            );
          },
        ),
      ),
    );

    expect(find.text('Capacity choices').hitTestable(), findsOneWidget);

    releaseControl();
    await tester.pump();

    expect(find.text('Capacity choices').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Capacity'));
    await _pumpCatchFieldMotion(tester);

    expect(find.text('Capacity choices'), findsNothing);
    expect(find.text('Capacity choices', skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField closed control subtree cannot retain focus', (
    tester,
  ) async {
    final controlFocus = FocusNode();
    addTearDown(controlFocus.dispose);
    var open = true;
    late void Function(bool value) setOpen;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            setOpen = (value) => setState(() => open = value);
            return CatchField.control(
              title: 'Age range',
              open: open,
              onOpenChanged: setOpen,
              control: TextField(focusNode: controlFocus),
            );
          },
        ),
      ),
    );

    controlFocus.requestFocus();
    await tester.pump();
    expect(controlFocus.hasFocus, isTrue);

    setOpen(false);
    await tester.pump();
    expect(controlFocus.hasFocus, isFalse);

    await _pumpCatchFieldMotion(tester);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextField, skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField choices preserves an explicit body override', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'Distances',
          body: '5K and beyond',
          values: const ['5K', '10K'],
          itemLabel: (value) => value,
          selected: const {'5K', '10K'},
          multi: true,
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.text('5K and beyond'), findsOneWidget);
    expect(find.text('5K · 10K'), findsNothing);
  });

  testWidgets('CatchField choices forwards helper and per-item accent', (
    tester,
  ) async {
    const accent = Color(0xFF8C5BFF);
    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'Format',
          helperText: 'Pick the format guests will see.',
          values: const ['Social', 'Competitive'],
          itemLabel: (value) => value,
          itemAccent: (value) => value == 'Social' ? accent : null,
          selected: const {'Social'},
          initiallyOpen: true,
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Pick the format guests will see.'), findsOneWidget);
    final chip = tester.widget<CatchChip>(
      find.byKey(const ValueKey('catch-field-choice-Social')),
    );
    expect(chip.accent, accent);
    expect(chip.selected, isTrue);
  });

  testWidgets(
    'CatchField optionCards keeps each title and description in one target',
    (tester) async {
      var selected = 'open';
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => CatchField.optionCards<String>(
              title: 'Admission format',
              values: const ['open', 'invite'],
              itemTitle: (value) => value == 'open' ? 'Open' : 'Invite only',
              itemDescription: (value) => value == 'open'
                  ? 'Anyone eligible can book until capacity.'
                  : 'Only people with the invite code can book.',
              selected: selected,
              initiallyOpen: true,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      );

      final openCard = tester.widget<CatchOptionCard>(
        find.byKey(const ValueKey('catch-field-option-card-Open')),
      );
      final inviteCard = tester.widget<CatchOptionCard>(
        find.byKey(const ValueKey('catch-field-option-card-Invite only')),
      );
      expect(openCard.description, 'Anyone eligible can book until capacity.');
      expect(openCard.selected, isTrue);
      expect(
        inviteCard.description,
        'Only people with the invite code can book.',
      );
      expect(inviteCard.selected, isFalse);

      await tester.tap(
        find.byKey(const ValueKey('catch-field-option-card-Invite only')),
      );
      await tester.pump();
      expect(selected, 'invite');
      expect(
        tester
            .widget<CatchOptionCard>(
              find.byKey(
                const ValueKey('catch-field-option-card-Invite only'),
                skipOffstage: false,
              ),
            )
            .selected,
        isTrue,
      );
    },
  );

  testWidgets('CatchField stepper reports bounded changes', (tester) async {
    num value = 168;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchField.stepper(
            title: 'Height',
            body: '$value cm',
            value: value,
            min: 167,
            max: 169,
            step: 2,
            unit: 'cm',
            initiallyOpen: true,
            decreaseSemanticLabel: 'Decrease height',
            increaseSemanticLabel: 'Increase height',
            onChanged: (next) => setState(() => value = next),
            onCancel: () {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Increase height'));
    await tester.pump();
    expect(value, 169);
    expect(find.text('169 cm'), findsNWidgets(2));
    final decreaseVisual = tester.getRect(
      find.byKey(const ValueKey('catch-field-stepper-Decrease height-visual')),
    );
    final decreaseHit = tester.getRect(
      find.byKey(
        const ValueKey('catch-field-stepper-Decrease height-focus-outline'),
      ),
    );
    final stepperValue = tester.getRect(
      find.byKey(const ValueKey('catch-field-stepper-value')),
    );
    final increaseVisual = tester.getRect(
      find.byKey(const ValueKey('catch-field-stepper-Increase height-visual')),
    );
    final increaseHit = tester.getRect(
      find.byKey(
        const ValueKey('catch-field-stepper-Increase height-focus-outline'),
      ),
    );
    expect(
      stepperValue.left - decreaseVisual.right,
      closeTo(CatchFieldTokens.stepperGap, 0.1),
    );
    expect(
      increaseVisual.left - stepperValue.right,
      closeTo(CatchFieldTokens.stepperGap, 0.1),
    );
    expect(decreaseVisual.center, decreaseHit.center);
    expect(increaseVisual.center, increaseHit.center);
    expectMinimumAccessibleTarget(
      tester,
      find.byKey(
        const ValueKey('catch-field-stepper-Decrease height-focus-outline'),
      ),
    );
    expectMinimumAccessibleTarget(
      tester,
      find.byKey(
        const ValueKey('catch-field-stepper-Increase height-focus-outline'),
      ),
    );

    final increase = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Increase height',
      ),
    );
    expect(increase.properties.enabled, isFalse);
    expect(
      tester.widget<Icon>(find.byIcon(CatchIcons.addRounded)).size,
      CatchFieldTokens.stepperGlyphExtent,
    );
  });

  testWidgets('CatchField stepper hold cadence matches the handoff boundary', (
    tester,
  ) async {
    var steps = 0;
    await tester.pumpWidget(
      _wrap(
        CatchFieldStepper(
          value: 168,
          min: 100,
          max: 220,
          decreaseSemanticLabel: 'Decrease height',
          increaseSemanticLabel: 'Increase height',
          onChanged: (_) => steps += 1,
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.bySemanticsLabel('Increase height')),
    );
    await tester.pump();
    expect(steps, 1);

    await tester.pump(
      CatchFieldTokens.repeatDelay - const Duration(milliseconds: 1),
    );
    expect(steps, 1);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));
    expect(steps, 2);

    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1000));
    expect(steps, 11);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 99));
    expect(steps, 11);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));
    expect(steps, 12);
    await tester.pump(
      CatchFieldTokens.repeatAccelerated - const Duration(milliseconds: 1),
    );
    expect(steps, 12);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));
    expect(steps, 13);
    await gesture.up();
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1000));
    expect(steps, 13);
  });

  testWidgets('CatchField stepper stops touch repeat after drag exit', (
    tester,
  ) async {
    var steps = 0;
    await tester.pumpWidget(
      _wrap(
        CatchFieldStepper(
          value: 168,
          min: 100,
          max: 220,
          decreaseSemanticLabel: 'Decrease height',
          increaseSemanticLabel: 'Increase height',
          onChanged: (_) => steps += 1,
        ),
      ),
    );

    final target = find.bySemanticsLabel('Increase height');
    final gesture = await tester.startGesture(tester.getCenter(target));
    await tester.pump();
    expect(steps, 1);

    await gesture.moveTo(
      tester.getRect(target).bottomRight + const Offset(8, 8),
    );
    await tester.pump(
      CatchFieldTokens.repeatDelay + const Duration(seconds: 1),
    );
    expect(steps, 1);
    await gesture.up();
  });

  testWidgets('CatchField commit buttons paint immediate outer focus rings', (
    tester,
  ) async {
    final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy = previousHighlightStrategy,
    );

    await tester.pumpWidget(
      _wrap(
        const CatchField.control(
          title: 'Height',
          body: '168 cm',
          initiallyOpen: true,
          control: Text('Height control'),
          onCancel: _noop,
          onSubmit: _noop,
        ),
      ),
    );

    for (final key in const [
      ValueKey('catch-field-cancel'),
      ValueKey('catch-field-done'),
    ]) {
      final buttonRoot = find.byKey(key);
      final textButtonFinder = find.descendant(
        of: buttonRoot,
        matching: find.byType(TextButton),
      );
      final buttonRect = tester.getRect(textButtonFinder);
      tester.widget<TextButton>(textButtonFinder).focusNode!.requestFocus();
      await tester.pump();

      final outline = find.descendant(
        of: buttonRoot,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter.runtimeType.toString() ==
                  '_CatchFieldFocusOutlinePainter',
        ),
      );
      expect(outline, findsOneWidget);
      expect(tester.getRect(textButtonFinder), buttonRect);
      expect(CatchFieldTokens.focusRingWidth, 2);
      expect(CatchFieldTokens.focusRingOffset, 2);
    }
  });

  testWidgets('CatchField single choice closes after the handoff delay', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'City',
          values: const ['Indore', 'Mumbai'],
          itemLabel: (value) => value,
          selected: const {'Indore'},
          onSelectionChanged: (_) {},
          initiallyOpen: true,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('catch-field-choice-Mumbai')));
    await tester.pump(
      CatchFieldTokens.singleChoiceCloseDelay - CatchFieldTokens.fast,
    );
    expect(find.text('Mumbai').hitTestable(), findsOneWidget);

    await tester.pump(CatchFieldTokens.fast);
    await _pumpCatchFieldMotion(tester);
    expect(find.text('Mumbai'), findsNothing);
  });

  testWidgets('CatchField local control cancel closes before callback', (
    tester,
  ) async {
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          initiallyOpen: true,
          control: const Text('Height control'),
          onCancel: () => cancelCount++,
          onSubmit: () {},
        ),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await _pumpCatchFieldMotion(tester);

    expect(cancelCount, 1);
    expect(find.text('Height control'), findsNothing);
    expect(find.text('Height control', skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField local control Done submits and closes', (
    tester,
  ) async {
    var submitCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          initiallyOpen: true,
          control: const Text('Height control'),
          onCancel: () {},
          onSubmit: () => submitCount++,
        ),
      ),
    );

    await tester.tap(find.text('Done'));
    await _pumpCatchFieldMotion(tester);

    expect(submitCount, 1);
    expect(find.text('Height control'), findsNothing);
    expect(find.text('Height control', skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField controlled Done leaves disclosure parent-owned', (
    tester,
  ) async {
    var submitCount = 0;
    final openChanges = <bool>[];

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          open: true,
          onOpenChanged: openChanges.add,
          control: const Text('Height control'),
          onCancel: () {},
          onSubmit: () => submitCount++,
        ),
      ),
    );

    await tester.tap(find.text('Done'));
    await _pumpCatchFieldMotion(tester);

    expect(submitCount, 1);
    expect(openChanges, isEmpty);
    expect(find.text('Height control'), findsOneWidget);
  });

  testWidgets('CatchField local control reports open and cancel changes', (
    tester,
  ) async {
    final openChanges = <bool>[];

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          control: const Text('Height control'),
          onOpenChanged: openChanges.add,
          onCancel: () {},
          onSubmit: () {},
        ),
      ),
    );

    await tester.tap(find.text('Height'));
    await _pumpCatchFieldMotion(tester);
    expect(openChanges, <bool>[true]);

    await tester.tap(find.text('Cancel'));
    await _pumpCatchFieldMotion(tester);
    expect(openChanges, <bool>[true, false]);
  });

  testWidgets('CatchField control cancels after an outside pointer is lifted', (
    tester,
  ) async {
    var open = true;
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              CatchField.control(
                title: 'Height',
                open: open,
                onOpenChanged: (value) => setState(() => open = value),
                control: const Text('Height control'),
                onCancel: () {
                  cancelCount++;
                  setState(() => open = false);
                },
                onSubmit: () {},
              ),
              const SizedBox(height: 80),
              const Text('Outside target'),
            ],
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Outside target')),
    );
    await tester.pump();

    expect(open, isTrue);
    expect(cancelCount, 0);

    await gesture.up();
    await tester.pump();

    expect(open, isFalse);
    expect(cancelCount, 1);
  });

  testWidgets('CatchField control stays open after an outside drag', (
    tester,
  ) async {
    var open = true;
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              CatchField.control(
                title: 'Height',
                open: open,
                onOpenChanged: (value) => setState(() => open = value),
                control: const Text('Height control'),
                onCancel: () {
                  cancelCount++;
                  setState(() => open = false);
                },
                onSubmit: () {},
              ),
              const SizedBox(height: 120),
              const Text('Outside drag target'),
            ],
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Outside drag target')),
    );
    await gesture.moveBy(const Offset(48, 0));
    await gesture.up();
    await tester.pump();

    expect(open, isTrue);
    expect(cancelCount, 0);
  });

  testWidgets('CatchField ignores Escape while an explicit save is loading', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Saving value');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var open = true;
    var openChanges = 0;
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchField.inputActions(
            title: 'Prompt',
            controller: controller,
            focusNode: focusNode,
            open: open,
            onOpenChanged: (value) {
              openChanges++;
              setState(() => open = value);
            },
            onCancel: () {
              cancelCount++;
              setState(() => open = false);
            },
            onSubmit: () {},
            isLoading: true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(open, isTrue);
    expect(openChanges, 0);
    expect(cancelCount, 0);
  });

  testWidgets('CatchField explicit-save expansion animates through height', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Catch me if you can');
    addTearDown(controller.dispose);
    var expanded = false;
    late void Function(bool value) setExpanded;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            setExpanded = (value) => setState(() => expanded = value);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 360,
                child: CatchField.inputActions(
                  icon: CatchIcons.formatQuoteRounded,
                  title: 'A perfect event with me looks like...',
                  controller: controller,
                  open: expanded,
                  onOpenChanged: setExpanded,
                  supporting: const Text('19 / 300'),
                  secondaryAction: const Text('Change prompt'),
                  onCancel: () => setExpanded(false),
                  onSubmit: () {},
                ),
              ),
            );
          },
        ),
      ),
    );

    final field = find.byType(CatchField);
    final collapsedHeight = tester.getSize(field).height;
    final anchoredTop = tester.getTopLeft(field).dy;

    setExpanded(true);
    await tester.pump();
    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final midpointHeight = tester.getSize(field).height;
    expect(midpointHeight, greaterThan(collapsedHeight));

    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final expandedHeight = tester.getSize(field).height;
    expect(midpointHeight, lessThan(expandedHeight));
    expect(tester.getTopLeft(field).dy, anchoredTop);

    setExpanded(false);
    await tester.pump();
    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final collapsingHeight = tester.getSize(field).height;
    expect(collapsingHeight, greaterThan(collapsedHeight));
    expect(collapsingHeight, lessThan(expandedHeight));

    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    await tester.pump();
    expect(tester.getSize(field).height, collapsedHeight);
    expect(tester.getTopLeft(field).dy, anchoredTop);
  });

  testWidgets('CatchField cancels an in-flight reveal when it closes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    var open = false;
    late void Function(bool value) setOpen;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchFieldVisibilityScope(
            bottomObstruction: 120,
            child: StatefulBuilder(
              builder: (context, setState) {
                setOpen = (value) => setState(() => open = value);
                return ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 460),
                    CatchField.control(
                      title: 'Diet',
                      body: 'Jain',
                      open: open,
                      onOpenChanged: setOpen,
                      control: const SizedBox(height: 180),
                      onCancel: () => setOpen(false),
                      onSubmit: _noop,
                    ),
                    const SizedBox(height: 160),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Diet'));
    await tester.pump();
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
    expect(scrollController.offset, greaterThan(0));

    setOpen(false);
    await tester.pump();
    final offsetAfterClose = scrollController.offset;
    await tester.pump(CatchFieldTokens.reveal);

    expect(scrollController.offset, lessThanOrEqualTo(offsetAfterClose + 0.1));
  });

  testWidgets('CatchField automatic reveal yields to direct user scrolling', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    var open = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchFieldVisibilityScope(
            bottomObstruction: 120,
            child: StatefulBuilder(
              builder: (context, setState) => ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 460),
                  CatchField.control(
                    title: 'Diet',
                    body: 'Jain',
                    open: open,
                    onOpenChanged: (value) => setState(() => open = value),
                    control: const SizedBox(height: 180),
                    onCancel: _noop,
                    onSubmit: _noop,
                  ),
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Diet'));
    await tester.pump();
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
    expect(scrollController.offset, greaterThan(0));

    final drag = await tester.startGesture(const Offset(200, 300));
    await drag.moveBy(const Offset(0, -40));
    await tester.pump();
    expect(scrollController.position.isScrollingNotifier.value, isTrue);
    final offsetDuringDrag = scrollController.offset;
    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    expect(scrollController.offset, closeTo(offsetDuringDrag, 0.1));

    await drag.up();
    await pumpFeatureUi(tester);
    expect(open, isTrue);
  });

  testWidgets('CatchField reveal jumps immediately with reduced motion', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    var open = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: CatchFieldVisibilityScope(
              bottomObstruction: 120,
              child: StatefulBuilder(
                builder: (context, setState) => ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 460),
                    CatchField.control(
                      title: 'Diet',
                      body: 'Jain',
                      open: open,
                      onOpenChanged: (value) => setState(() => open = value),
                      control: const SizedBox(height: 180),
                      onCancel: _noop,
                      onSubmit: _noop,
                    ),
                    const SizedBox(height: 160),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Diet'));
    await tester.pump();
    await tester.pump();

    expect(scrollController.offset, greaterThan(0));
    expect(
      tester.getRect(find.byKey(const ValueKey('catch-field-done'))).bottom,
      lessThanOrEqualTo(472.1),
    );
    final offsetAfterReveal = scrollController.offset;
    await tester.pump(CatchFieldTokens.reveal);
    expect(scrollController.offset, closeTo(offsetAfterReveal, 0.1));
  });

  testWidgets('CatchField renders label, helper text, changes, and errors', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    var latestValue = '';

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchField.input(
            title: 'Event title',
            placeholder: 'Short and memorable',
            helperText: 'Shows on event cards',
            validator: (value) =>
                value == null || value.isEmpty ? "Title can't be empty" : null,
            onChanged: (value) => latestValue = value,
          ),
        ),
      ),
    );

    expect(find.text('Event title'), findsNothing);
    expect(find.text('Add event title'), findsOneWidget);
    expect(find.text('Short and memorable'), findsNothing);
    expect(find.text('Shows on event cards'), findsOneWidget);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump(CatchMotion.fast);
    expect(find.text('Event title'), findsOneWidget);
    expect(find.text('Short and memorable'), findsOneWidget);
    expect(find.text('Shows on event cards'), findsOneWidget);

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text("Title can't be empty"), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sunrise Seawall 7K');
    await tester.pump();
    expect(latestValue, 'Sunrise Seawall 7K');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('CatchField exposes a keyboard done action by default', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Asha');
    addTearDown(controller.dispose);
    var submitted = '';

    await tester.pumpWidget(
      _wrap(
        CatchField.input(
          title: 'Name',
          controller: controller,
          onSubmitted: (value) => submitted = value,
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.textInputAction, TextInputAction.done);
    expect(editableText.focusNode.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, 'Asha');
    expect(editableText.focusNode.hasFocus, isFalse);
  });

  testWidgets('CatchField error renders once with danger label styling', (
    tester,
  ) async {
    const error = 'Use a six character invite code.';

    await tester.pumpWidget(
      _wrap(
        const CatchField.input(
          title: 'Invite code',
          initialValue: 'ABC',
          error: error,
        ),
      ),
    );

    expect(find.text(error), findsOneWidget);
    expect(find.byType(CatchControlShell), findsNothing);

    final label = tester.widget<Text>(find.text('Invite code'));
    expect(label.style?.color, CatchTokens.editorialLight.danger);
  });

  testWidgets(
    'CatchField disables expansion motion when reduced motion is on',
    (tester) async {
      final controller = TextEditingController(text: 'Answer');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: CatchField.inputActions(
              title: 'Prompt',
              controller: controller,
              open: true,
              onOpenChanged: (_) {},
              supporting: const Text('6 / 300'),
              onCancel: () {},
              onSubmit: () {},
            ),
          ),
        ),
      );

      final expansion = tester.widget<TweenAnimationBuilder<double>>(
        find.byKey(const ValueKey('catch-field-expansion')),
      );
      expect(expansion.duration, Duration.zero);
      final opacity = tester.widget<AnimatedOpacity>(
        find.byKey(const ValueKey('catch-field-control-opacity')),
      );
      expect(opacity.duration, Duration.zero);
    },
  );

  testWidgets(
    'CatchField.choices pins single, multi, disabled, and caller-owned selection',
    (tester) async {
      var selected = <String>{'Run'};
      var reports = 0;
      late StateSetter update;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CatchField.choices<String>(
                title: 'Activities',
                values: const ['Run', 'Walk'],
                itemLabel: (value) => value,
                selected: selected,
                initiallyOpen: true,
                onSelectionChanged: (next) {
                  reports += 1;
                  setState(() => selected = next);
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('catch-field-choice-Walk')));
      await tester.pump();
      expect(selected, {'Walk'});
      expect(reports, 1);

      update(() => selected = {'Run', 'Walk'});
      expect(selected, {'Run', 'Walk'});

      await tester.pumpWidget(
        _wrap(
          CatchField.choices<String>(
            title: 'Locked activities',
            values: const ['Run', 'Walk'],
            itemLabel: (value) => value,
            selected: selected,
            multi: true,
            enabled: false,
            initiallyOpen: true,
            onSelectionChanged: (_) => reports += 1,
          ),
        ),
      );
      await tester.tap(
        find.byKey(const ValueKey('catch-field-choice-Run')),
        warnIfMissed: false,
      );
      expect(reports, 1);
    },
  );

  testWidgets(
    'CatchField.stepper pins formatter, bounds, and semantic labels',
    (tester) async {
      var value = 2;
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => CatchField.stepper(
              title: 'Guests',
              value: value,
              min: 1,
              max: 3,
              formatter: (next) => '${next.toInt()} guests',
              decreaseSemanticLabel: 'Decrease guests',
              increaseSemanticLabel: 'Increase guests',
              initiallyOpen: true,
              onChanged: (next) => setState(() => value = next.toInt()),
            ),
          ),
        ),
      );

      expect(find.text('2 guests'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Increase guests'));
      await tester.pump();
      expect(value, 3);
      expect(find.text('3 guests'), findsOneWidget);
      expect(find.bySemanticsLabel('Increase guests'), findsOneWidget);
    },
  );

  testWidgets('CatchField Escape cancels an open editor', (tester) async {
    final controller = TextEditingController(text: 'Draft');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var cancels = 0;
    await tester.pumpWidget(
      _wrap(
        CatchField.inputActions(
          title: 'Bio',
          controller: controller,
          focusNode: focusNode,
          open: true,
          onOpenChanged: (_) {},
          onCancel: () => cancels += 1,
          onSubmit: () {},
        ),
      ),
    );

    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _pumpCatchFieldMotion(tester);
    expect(cancels, 1);
  });

  for (final scale in [1.3, 2.0]) {
    testWidgets('CatchField control remains usable at ${scale}x text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 280,
            child: CatchField.control(
              title: 'Preferred group size',
              body: 'Four people for a comfortable conversation',
              initiallyOpen: true,
              control: CatchFieldStepper(
                value: 4,
                decreaseSemanticLabel: 'Decrease group size',
                increaseSemanticLabel: 'Increase group size',
                onChanged: (_) {},
              ),
            ),
          ),
          textScale: scale,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('CatchField control lanes mirror in RTL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Directionality(
          textDirection: TextDirection.rtl,
          child: CatchFieldStepper(
            value: 4,
            decreaseSemanticLabel: 'Decrease group size',
            increaseSemanticLabel: 'Increase group size',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(
      tester.getCenter(find.bySemanticsLabel('Decrease group size')).dx,
      greaterThan(
        tester.getCenter(find.bySemanticsLabel('Increase group size')).dx,
      ),
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

void _noop() {}
