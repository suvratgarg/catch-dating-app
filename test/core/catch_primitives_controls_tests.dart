part of 'catch_primitives_test.dart';

void _registerCatchPrimitivesControlsTests() {
  testWidgets('CatchField sortable owns inline hierarchy and handle lane', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchFieldLanes.single(
            child: CatchField.sortable(
              title: 'Full name',
              metadata: 'Short text · Required',
              reorderHandle: const SizedBox(
                key: ValueKey('sortable-handle'),
                child: Icon(Icons.drag_indicator_rounded),
              ),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final inline = find.textContaining('Full name', findRichText: true);
    expect(inline, findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const ValueKey('sortable-handle'))).dx,
      lessThan(tester.getTopLeft(inline).dx),
    );
    final chevron = find.byIcon(CatchIcons.chevronRightRounded);
    expect(chevron, findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const ValueKey('sortable-handle'))).dy,
      closeTo(tester.getCenter(inline).dy, 0.5),
    );
    expect(
      tester.getCenter(chevron).dy,
      closeTo(tester.getCenter(inline).dy, 0.5),
    );
  });

  testWidgets('Catch map reveal opens a veil and respects reduced motion', (
    tester,
  ) async {
    final animation = AnimationController(
      vsync: tester,
      duration: CatchMotion.slow,
      value: 0.5,
    );
    addTearDown(animation.dispose);

    Widget transition({required bool reduceMotion}) {
      return _wrap(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Builder(
            builder: (context) => CatchMapRevealTransition(
              animation: animation,
              child: const Text('Map surface'),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(transition(reduceMotion: false));
    expect(find.byKey(const ValueKey('catch_map_reveal.veil')), findsOneWidget);
    final mapRect = tester.getRect(find.text('Map surface'));
    animation.value = 0.8;
    await tester.pump();
    expect(tester.getRect(find.text('Map surface')), mapRect);

    await tester.pumpWidget(transition(reduceMotion: true));
    expect(
      find.byKey(const ValueKey('catch_map_reveal.reduced')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('catch_map_reveal.veil')), findsNothing);
  });

  testWidgets('Catch typography does not inherit underline decoration', (
    tester,
  ) async {
    late final List<TextStyle> styles;
    late final TextStyle kicker;
    late final TextStyle kickerLarge;
    late final TextStyle monoCapsLabel;
    late final TextStyle badgeCaps;

    await tester.pumpWidget(
      _wrap(
        DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.underline),
          child: Builder(
            builder: (context) {
              styles = [
                CatchTextStyles.display(context),
                CatchTextStyles.headline(context),
                CatchTextStyles.headlineS(context),
                CatchTextStyles.eventTitle(context),
                CatchTextStyles.consoleTitle(context),
                CatchTextStyles.hint(context),
                CatchTextStyles.titleL(context),
                CatchTextStyles.name(context),
                CatchTextStyles.bodyL(context),
                CatchTextStyles.bodyS(context),
                CatchTextStyles.labelL(context),
                CatchTextStyles.monoLabel(context),
                CatchTextStyles.monoLabelS(context),
                CatchTextStyles.mono(context),
                CatchTextStyles.badge(context),
              ];
              kicker = CatchTextStyles.kicker(context);
              kickerLarge = CatchTextStyles.kickerLg(context);
              monoCapsLabel = CatchTextStyles.monoCapsLabel(context);
              badgeCaps = CatchTextStyles.badgeCaps(context);
              return const Text('Typography sample');
            },
          ),
        ),
      ),
    );

    expect(styles.map((style) => style.decoration).toSet(), {
      TextDecoration.none,
    });
    expect(styles.map((style) => style.letterSpacing).toSet(), {0});
    expect(kicker.letterSpacing, 1.76);
    expect(kickerLarge.letterSpacing, 2.16);
    expect(monoCapsLabel.letterSpacing, 1.43);
    expect(badgeCaps.letterSpacing, 0.72);
  });

  testWidgets('CatchKicker renders uppercase mono eyebrow sizes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchKicker(
          label: 'Was at · Sundowner 5K',
          color: Colors.red,
          size: CatchKickerSize.lg,
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('WAS AT · SUNDOWNER 5K'));
    final context = tester.element(find.text('WAS AT · SUNDOWNER 5K'));
    expect(text.style?.color, Colors.red);
    expect(
      text.style?.fontSize,
      CatchTextStyles.kickerLg(context, color: Colors.red).fontSize,
    );
  });

  testWidgets(
    'CatchButton supports size, full width, tap, and loading states',
    (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchButton(
                  label: 'Join event',
                  onPressed: () => taps++,
                  size: CatchButtonSize.lg,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                CatchButton(
                  label: 'Loading',
                  onPressed: () => taps++,
                  isLoading: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.widgetWithText(CatchButton, 'Join event')).height,
        56,
      );
      expect(
        tester.getSize(find.widgetWithText(CatchButton, 'Join event')).width,
        240,
      );
      expect(find.byType(CatchButtonLabel), findsOneWidget);
      expect(find.byType(CatchButtonLoadingDots), findsOneWidget);

      await tester.tap(find.text('Join event'));
      await tester.pump();
      expect(taps, 1);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is CatchButton && widget.label == 'Loading',
        ),
      );
      await tester.pump();
      expect(taps, 1);
      expect(find.text('Loading'), findsNothing);
    },
  );

  testWidgets('CatchButton exposes named rounded editorial geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchButton(
          key: const ValueKey('rounded-button'),
          label: 'Review & publish',
          shape: CatchButtonShape.rounded,
          onPressed: () {},
        ),
      ),
    );

    final decoration = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('rounded-button')),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      (decoration.decoration as BoxDecoration).borderRadius,
      BorderRadius.circular(CatchRadius.md),
    );
  });

  testWidgets('CatchButton reflows full-width labels at large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 220,
          child: CatchButton(
            key: const ValueKey('large-text-button'),
            label: 'Review every submitted response',
            fullWidth: true,
            onPressed: () {},
          ),
        ),
        textScale: 2,
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('large-text-button'))).height,
      greaterThan(CatchSpacing.s12),
    );
    final label = tester.widget<CatchButtonLabel>(
      find.byType(CatchButtonLabel),
    );
    expect(label.allowMultiline, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CatchButton resolves transitions under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: CatchButton(
            key: const ValueKey('reduced-motion-button'),
            label: 'Continue',
            onPressed: () {},
          ),
        ),
      ),
    );

    final button = find.byKey(const ValueKey('reduced-motion-button'));
    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(of: button, matching: find.byType(AnimatedScale)),
          )
          .duration,
      CatchMotion.none,
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.descendant(of: button, matching: find.byType(AnimatedOpacity)),
          )
          .duration,
      CatchMotion.none,
    );
    expect(
      tester
          .widget<AnimatedSwitcher>(
            find.descendant(
              of: button,
              matching: find.byType(AnimatedSwitcher),
            ),
          )
          .duration,
      CatchMotion.none,
    );
  });

  testWidgets('CatchButton pairs primary activity accent with white ink', (
    tester,
  ) async {
    const accent = Color(0xFF116466);

    await tester.pumpWidget(
      _wrap(
        CatchButton(
          key: const ValueKey('accent-button'),
          label: 'Run crew',
          onPressed: () {},
          accentColor: accent,
        ),
      ),
    );

    final buttonFinder = find.byKey(const ValueKey('accent-button'));
    final buttonBox = tester.widget<DecoratedBox>(
      find.descendant(of: buttonFinder, matching: find.byType(DecoratedBox)),
    );
    final buttonLabel = tester.widget<Text>(
      find.descendant(of: buttonFinder, matching: find.text('Run crew')),
    );
    final decoration = buttonBox.decoration as BoxDecoration;

    expect(decoration.color, accent);
    expect(buttonLabel.style?.color, CatchTokens.editorialWhite);
  });

  testWidgets(
    'CatchBottomAction forwards activity accent to the primary button',
    (tester) async {
      const accent = Color(0xFF116466);

      await tester.pumpWidget(
        _wrap(
          CatchBottomAction(
            label: 'Join event',
            onPressed: () {},
            buttonAccentColor: accent,
            buttonShape: CatchButtonShape.rounded,
          ),
        ),
      );

      expect(find.byType(CatchBottomAction), findsOneWidget);
      final button = tester.widget<CatchButton>(
        find.widgetWithText(CatchButton, 'Join event'),
      );
      expect(button.accentColor, accent);
      expect(button.shape, CatchButtonShape.rounded);
    },
  );

  testWidgets('CatchBottomAction renders catch line and footnote', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchBottomAction(
          label: 'Confirm',
          onPressed: () {},
          catchLine: 'free to join',
          footnote: 'No charge until approval.',
        ),
      ),
    );

    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('FREE TO JOIN'), findsOneWidget);
    expect(find.text('No charge until approval.'), findsOneWidget);
  });

  testWidgets(
    'CatchBottomActionOverlay pins controls over a soft scroll fade',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(
          SizedBox.expand(
            child: CatchBottomActionOverlay(
              body: ListView(
                padding: CatchInsets.formStepBodyWithBottomActions,
                children: const [
                  SizedBox(height: 560),
                  Text('Last form field'),
                ],
              ),
              actions: CatchButton(label: 'Next', onPressed: () {}),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      final scrim = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('catch_bottom_action_overlay.scrim')),
      );
      final gradient = (scrim.decoration as BoxDecoration).gradient;
      expect(gradient, isA<LinearGradient>());
      final colors = (gradient! as LinearGradient).colors;
      expect(colors.first.a, CatchOpacity.none);
      expect(colors.last.a, CatchOpacity.visible);

      final bodyRect = tester.getRect(
        find.byKey(const ValueKey('catch_bottom_action_overlay.body')),
      );
      final scrimRect = tester.getRect(
        find.byKey(const ValueKey('catch_bottom_action_overlay.scrim')),
      );
      final actionsRect = tester.getRect(
        find.byKey(const ValueKey('catch_bottom_action_overlay.actions')),
      );
      expect(scrimRect.top, lessThan(bodyRect.bottom));
      expect(actionsRect.top, greaterThan(scrimRect.top));
      expect(actionsRect.bottom, lessThanOrEqualTo(bodyRect.bottom));
      expect(actionsRect.left, greaterThanOrEqualTo(CatchSpacing.screenPx));
      expect(actionsRect.right, lessThanOrEqualTo(320 - CatchSpacing.screenPx));

      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pump();
      expect(find.text('Last form field').hitTestable(), findsOneWidget);
    },
  );

  testWidgets('CatchIconButton renders handoff icon button variants', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchIconButton.icon(
              key: const ValueKey('bordered-icon-button'),
              icon: CatchIcons.search,
              tooltip: 'Search events',
              onTap: () => taps++,
            ),
            CatchIconButton.icon(
              key: const ValueKey('active-icon-button'),
              icon: CatchIcons.favoriteRounded,
              active: true,
              accent: CatchTokens.editorialLight.danger,
              onTap: () {},
            ),
            CatchIconButton.icon(
              key: const ValueKey('float-icon-button'),
              icon: CatchIcons.close,
              variant: CatchIconButtonVariant.float,
              onTap: () {},
            ),
            CatchIconButton.icon(
              key: const ValueKey('plain-icon-button'),
              icon: CatchIcons.more,
              variant: CatchIconButtonVariant.plain,
              borderColor: CatchTokens.editorialLight.line2,
              disabled: true,
              onTap: () => taps++,
            ),
          ],
        ),
      ),
    );

    final borderedFinder = find.byKey(const ValueKey('bordered-icon-button'));
    final floatFinder = find.byKey(const ValueKey('float-icon-button'));
    final plainFinder = find.byKey(const ValueKey('plain-icon-button'));
    final tokens = CatchTokens.of(tester.element(borderedFinder));
    final borderedSurface = tester.widget<CatchSurface>(
      find.descendant(of: borderedFinder, matching: find.byType(CatchSurface)),
    );
    final activeIconTheme = tester.widget<IconTheme>(
      find
          .ancestor(
            of: find.byIcon(CatchIcons.favoriteRounded),
            matching: find.byType(IconTheme),
          )
          .first,
    );
    final floatSurface = tester.widget<CatchSurface>(
      find.descendant(of: floatFinder, matching: find.byType(CatchSurface)),
    );
    final plainSurface = tester.widget<CatchSurface>(
      find.descendant(of: plainFinder, matching: find.byType(CatchSurface)),
    );

    expect(
      tester.getSize(borderedFinder),
      const Size.square(CatchLayout.iconButtonSize),
    );
    expect(borderedSurface.backgroundColor, tokens.surface);
    final restingBorder = CatchBorder.interactive(
      tokens,
      CatchInteractiveBorderState.resting,
    );
    expect(borderedSurface.borderSpec?.color, restingBorder.color);
    expect(borderedSurface.borderSpec?.width, restingBorder.width);
    expect(activeIconTheme.data.color, CatchTokens.editorialLight.danger);
    expect(floatSurface.backgroundColor, isNot(tokens.surface));
    expect(floatSurface.boxShadow, CatchElevation.iconButtonFloat);
    expect(plainSurface.backgroundColor, Colors.transparent);
    expect(plainSurface.borderSpec?.color, tokens.line2);
    expect(
      plainSurface.borderSpec?.width,
      CatchBorder.resolve(tokens, CatchBorderRole.boundary).width,
    );
    expect(find.byTooltip('Search events'), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.search));
    await tester.pump();
    await tester.tap(find.byIcon(CatchIcons.more));
    await tester.pump();

    expect(taps, 1);
  });

  test(
    'compact-control constructors reject invalid count and label states',
    () {
      expect(
        () => CatchIconButton.counted(
          icon: CatchIcons.notificationsRounded,
          count: -1,
        ),
        throwsAssertionError,
      );
      expect(
        () => CatchCountPill.label(label: '   ', onPressed: () {}),
        throwsAssertionError,
      );
      expect(
        () =>
            CatchCountPill.label(label: 'Filters', count: -1, onPressed: () {}),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'CatchIconButton.counted owns typed counts, target size, and semantics',
    (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchIconButton.counted(
                key: const ValueKey('zero-count-icon-button'),
                icon: CatchIcons.notificationsNoneRounded,
                count: 0,
                tooltip: 'Notifications',
                onTap: () => taps++,
              ),
              CatchIconButton.counted(
                key: const ValueKey('counted-icon-button'),
                icon: CatchIcons.tuneRounded,
                count: 3,
                tooltip: 'Filters, 3 active',
                onTap: () => taps++,
              ),
              CatchIconButton.counted(
                icon: CatchIcons.notificationsRounded,
                count: 124,
                tooltip: 'Notifications, 124 unread',
                onTap: () {},
              ),
            ],
          ),
        ),
      );

      final counted = find.byKey(const ValueKey('counted-icon-button'));
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Filters, 3 active',
        ),
      );

      expect(find.text('0'), findsNothing);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(
        tester.getSize(counted),
        const Size.square(CatchIconButton.defaultSize),
      );
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isTrue);

      await tester.tap(counted);
      await tester.pump();
      expect(taps, 1);
    },
  );

  testWidgets('CatchCountPill.label stays interactive and at least 44px', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        CatchCountPill.label(
          key: const ValueKey('labelled-count-pill'),
          icon: CatchIcons.tuneRounded,
          label: 'Filters',
          count: 3,
          semanticLabel: 'Filters, 3 active',
          onPressed: () => taps++,
        ),
        textScale: 2,
      ),
    );

    final pill = find.byKey(const ValueKey('labelled-count-pill'));
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Filters, 3 active',
      ),
    );

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(tester.getSize(pill).height, greaterThanOrEqualTo(44));
    expect(
      tester
          .getRect(find.text('Filters'))
          .overlaps(tester.getRect(find.text('3'))),
      isFalse,
    );
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.enabled, isTrue);

    await tester.tap(pill);
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('CatchButton renders all catalog variants', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Wrap(
          children: [
            CatchButton(label: 'Primary', onPressed: null),
            CatchButton(
              label: 'Secondary',
              onPressed: null,
              variant: CatchButtonVariant.secondary,
            ),
            CatchButton(
              label: 'Ghost',
              onPressed: null,
              variant: CatchButtonVariant.ghost,
            ),
            CatchButton(
              label: 'Danger',
              onPressed: null,
              variant: CatchButtonVariant.danger,
            ),
            CatchButton(
              label: 'Light',
              onPressed: null,
              variant: CatchButtonVariant.light,
              isInteractive: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Ghost'), findsOneWidget);
    expect(find.text('Danger'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
  });

  testWidgets('resting outlined controls share one semantic border', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchButton(
              key: const ValueKey('outlined-text-control'),
              label: 'Filters',
              variant: CatchButtonVariant.secondary,
              onPressed: () {},
            ),
            CatchIconButton.icon(
              key: const ValueKey('outlined-icon-control'),
              icon: CatchIcons.search,
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    final buttonDecoration = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byKey(const ValueKey('outlined-text-control')),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .singleWhere((decoration) => decoration.border != null);
    final iconSurface = tester.widget<CatchSurface>(
      find.descendant(
        of: find.byKey(const ValueKey('outlined-icon-control')),
        matching: find.byType(CatchSurface),
      ),
    );
    final buttonBorder = (buttonDecoration.border! as Border).top;

    expect(buttonBorder.color, iconSurface.borderSpec?.color);
    expect(buttonBorder.width, iconSurface.borderSpec?.width);
    expect(iconSurface.borderSpec?.role, CatchBorderRole.control);
  });

  testWidgets('CatchStepProgress renders count and full-width segments', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchStepProgress(
            label: 'Profile setup',
            currentStep: 1,
            totalSteps: 5,
          ),
        ),
      ),
    );

    expect(find.text('Profile setup'), findsOneWidget);
    expect(find.text('2/5'), findsOneWidget);
  });

  testWidgets('CatchStepHeader renders AppBar anatomy and progress hairline', (
    tester,
  ) async {
    var backTaps = 0;

    await tester.pumpWidget(
      _wrap(
        CatchStepHeader(
          title: 'Basics',
          subtitle: 'South Bombay Runners',
          kicker: 'Create event',
          step: 2,
          total: 5,
          onBack: () => backTaps++,
        ),
      ),
    );

    final progress = tester.widget<FractionallySizedBox>(
      find.descendant(
        of: find.byType(CatchStepHeader),
        matching: find.byType(FractionallySizedBox),
      ),
    );

    expect(find.text('CREATE EVENT'), findsOneWidget);
    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('South Bombay Runners'), findsOneWidget);
    expect(find.text('STEP 2 OF 5'), findsOneWidget);
    expect(find.byIcon(CatchIcons.arrowBackIosNewRounded), findsOneWidget);
    expect(
      tester
          .getSize(
            find.descendant(
              of: find.byType(CatchStepHeader),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is SizedBox &&
                    widget.height == CatchLayout.stepHeaderProgressHeight,
              ),
            ),
          )
          .height,
      CatchLayout.stepHeaderProgressHeight,
    );
    expect(progress.widthFactor, 0.4);

    final topBarSize = tester.getSize(
      find.descendant(
        of: find.byType(CatchStepHeader),
        matching: find.byType(CatchTopBar),
      ),
    );
    expect(topBarSize.height, CatchLayout.stepHeaderTopBarHeight);

    final subtitleRect = tester.getRect(find.text('South Bombay Runners'));
    final progressRect = tester.getRect(
      find.descendant(
        of: find.byType(CatchStepHeader),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.height == CatchLayout.stepHeaderProgressHeight,
        ),
      ),
    );
    expect(
      progressRect.top - subtitleRect.bottom,
      lessThanOrEqualTo(CatchSpacing.s4),
    );

    final kickerRect = tester.getRect(find.text('CREATE EVENT'));
    final counterRect = tester.getRect(find.text('STEP 2 OF 5'));
    expect(counterRect.top - kickerRect.top, closeTo(0, 0.001));

    await tester.tap(find.byIcon(CatchIcons.arrowBackIosNewRounded));
    await tester.pump();

    expect(backTaps, 1);
  });

  testWidgets('CatchStepHeader displays one-based progress copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchStepHeader(title: 'Schedule', step: 1, total: 3)),
    );

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    final titleRect = tester.getRect(find.text('Schedule'));
    final counterRect = tester.getRect(find.text('STEP 1 OF 3'));
    final topBarSize = tester.getSize(
      find.descendant(
        of: find.byType(CatchStepHeader),
        matching: find.byType(CatchTopBar),
      ),
    );
    expect(topBarSize.height, CatchLayout.stepHeaderTopBarHeight);
    expect(
      counterRect.top - titleRect.top,
      closeTo(CatchLayout.stepHeaderCounterTopPadding, 0.001),
    );
  });

  testWidgets('CatchStepHeader expands for long supplemental copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 350,
          child: CatchStepHeader(
            title: "What's your number?",
            subtitle: "We'll send you a one-time code to verify.",
            showBack: false,
            gutter: false,
          ),
        ),
      ),
    );

    final topBarSize = tester.getSize(
      find.descendant(
        of: find.byType(CatchStepHeader),
        matching: find.byType(CatchTopBar),
      ),
    );
    expect(topBarSize.height, greaterThan(CatchLayout.stepHeaderTopBarHeight));
    expect(tester.takeException(), isNull);
  });

  testWidgets('CatchStepHeader exposes its step overview as a 44px action', (
    tester,
  ) async {
    var overviewTaps = 0;
    await tester.pumpWidget(
      _wrap(
        CatchStepHeader(
          title: 'Schedule',
          step: 1,
          total: 3,
          onStepOverview: () => overviewTaps += 1,
          stepOverviewSemanticsLabel: 'Open event section overview',
        ),
      ),
    );

    final action = find.bySemanticsLabel('Open event section overview');
    expect(action, findsOneWidget);
    expect(tester.getSize(action).height, greaterThanOrEqualTo(44));
    await tester.tap(action);
    expect(overviewTaps, 1);
  });

  testWidgets(
    'CatchStepHeader compacts only the visual counter at large text',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          CatchStepHeader(
            title: 'Meeting location',
            step: 2,
            total: 5,
            onStepOverview: () {},
            stepOverviewSemanticsLabel: 'Step 2 of 5. Open section overview.',
          ),
          textScale: 2,
        ),
      );

      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('STEP 2 OF 5'), findsNothing);
      expect(
        find.bySemanticsLabel('Step 2 of 5. Open section overview.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('CatchFormStepOverview renders status and opens a section', (
    tester,
  ) async {
    int? selectedStep;
    await tester.pumpWidget(
      _wrap(
        CatchFormStepOverview(
          items: const [
            CatchFormStepReviewItem(
              index: 0,
              title: 'Event basics',
              status: CatchFormStepStatus.complete,
            ),
            CatchFormStepReviewItem(
              index: 1,
              title: 'Meeting location',
              status: CatchFormStepStatus.needsInformation,
            ),
            CatchFormStepReviewItem(
              index: 2,
              title: 'Live event guide',
              status: CatchFormStepStatus.optional,
            ),
          ],
          onStepSelected: (index) => selectedStep = index,
        ),
      ),
    );

    expect(find.text('COMPLETE'), findsOneWidget);
    expect(find.text('NEEDS INFORMATION'), findsOneWidget);
    expect(find.text('OPTIONAL'), findsOneWidget);
    await tester.tap(find.text('Meeting location'));
    expect(selectedStep, 1);
  });

  testWidgets('CatchButton light variant stays legible in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchButton(
          label: 'Light action',
          onPressed: null,
          variant: CatchButtonVariant.light,
          isInteractive: false,
        ),
        theme: AppTheme.dark,
      ),
    );

    final label = tester.widget<Text>(find.text('Light action'));

    expect(label.style?.color, CatchTokens.editorialLight.ink);
  });

  testWidgets('CatchButton primary variant uses white text in dark mode', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        CatchButton(label: 'Primary action', onPressed: () => taps++),
        theme: AppTheme.dark,
      ),
    );

    await tester.tap(find.text('Primary action'));
    await tester.pump();

    final label = tester.widget<Text>(find.text('Primary action'));

    expect(taps, 1);
    expect(label.style?.color, CatchTokens.editorialDark.primaryInk);
  });

  testWidgets('CatchTextButton applies token color and tap semantics', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(CatchTextButton(label: 'Retry', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    final label = tester.widget<Text>(find.text('Retry'));
    expect(taps, 1);
    expect(label.style?.color, CatchTokens.editorialLight.primary);
  });

  testWidgets('CatchTextButton keeps long localized labels constrained', (
    tester,
  ) async {
    const plainLabel = 'Cancel this unexpectedly long localized action';
    const leadingLabel = 'Saving this unexpectedly long localized action';

    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            SizedBox(
              width: 132,
              child: CatchTextButton(label: plainLabel, onPressed: null),
            ),
            SizedBox(
              width: 132,
              child: CatchTextButton(
                label: leadingLabel,
                onPressed: null,
                leading: SizedBox.square(dimension: 12),
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text(plainLabel)).width, lessThanOrEqualTo(116));
    expect(
      tester.getSize(find.text(leadingLabel)).width,
      lessThanOrEqualTo(98),
    );
    expect(
      tester.widget<Text>(find.text(plainLabel)).overflow,
      TextOverflow.ellipsis,
    );
    expect(
      tester.widget<Text>(find.text(leadingLabel)).overflow,
      TextOverflow.ellipsis,
    );
  });

  testWidgets('CatchToggle emits the next value on tap', (tester) async {
    bool? nextValue;

    await tester.pumpWidget(
      _wrap(
        CatchToggle(
          value: false,
          semanticLabel: 'Push notifications',
          onChanged: (value) => nextValue = value,
        ),
      ),
    );

    await tester.tap(find.byType(CatchToggle));
    await tester.pump();

    expect(nextValue, isTrue);
  });

  testWidgets(
    'CatchOtpCodeField renders visible digits over one hidden input',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => CatchOtpCodeField(
              inputKey: const ValueKey('otp-input'),
              controller: controller,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {},
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('otp-input')),
        '1234567',
      );
      await tester.pump();

      expect(controller.text, '123456');
      expect(find.byType(CatchCodeInputRow), findsOneWidget);
      expect(find.byType(CatchCodeInputCell), findsNWidgets(6));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsNothing);
    },
  );
}
