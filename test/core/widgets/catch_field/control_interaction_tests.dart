part of 'control_test.dart';

void _registerControlInteractionTests() {
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
                copy: catchFieldCopy(AppLocalizationsEn()),
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
                copy: catchFieldCopy(AppLocalizationsEn()),
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
            copy: catchFieldCopy(AppLocalizationsEn()),
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
                      copy: catchFieldCopy(AppLocalizationsEn()),
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
    await tester.pump(CatchMotion.base);

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
                    copy: catchFieldCopy(AppLocalizationsEn()),
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
      Duration(milliseconds: CatchMotion.base.inMilliseconds ~/ 2),
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
                      copy: catchFieldCopy(AppLocalizationsEn()),
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
    await tester.pump(CatchMotion.base);
    expect(scrollController.offset, closeTo(offsetAfterReveal, 0.1));
  });
}
