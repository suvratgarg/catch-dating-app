part of 'catch_primitives_test.dart';

void _registerCatchPrimitivesSearchMenuTests() {
  testWidgets('CatchErrorState renders retry UI without debug details', (
    tester,
  ) async {
    var retryCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchErrorState.fromError(
          StateError('Could not load profile'),
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(CatchErrorBody), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('StackTrace'), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(retryCount, 1);
  });

  testWidgets('CatchErrorState honors an explicit recovery callback', (
    tester,
  ) async {
    var retryCount = 0;
    await tester.pumpWidget(
      _wrap(
        CatchErrorState.fromError(
          const ValidationException('Please enter a valid phone number.'),
          onRetry: () => retryCount += 1,
        ),
      ),
    );

    expect(find.text('Check your details'), findsOneWidget);
    expect(
      find.text('Check the highlighted details and try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryCount, 1);
  });

  testWidgets('Catch error variants keep a caller-provided alternate action', (
    tester,
  ) async {
    var alternateCount = 0;
    Widget alternateAction() => CatchErrorBackAction(
      label: 'Go back',
      onPressed: () => alternateCount += 1,
    );

    await tester.pumpWidget(
      _wrap(
        CatchInlineErrorState.fromError(
          const PermissionException('Unavailable.'),
          secondaryAction: alternateAction(),
        ),
      ),
    );
    await tester.tap(find.text('Go back'));
    expect(alternateCount, 1);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CatchErrorScaffold.fromError(
          const PermissionException('Unavailable.'),
          secondaryAction: alternateAction(),
        ),
      ),
    );
    await tester.tap(find.text('Go back'));
    expect(alternateCount, 2);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              CatchSliverErrorState.fromError(
                const PermissionException('Unavailable.'),
                secondaryAction: alternateAction(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Go back'));
    expect(alternateCount, 3);
  });

  testWidgets('CatchSliverErrorState fills a sliver viewport', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CustomScrollView(
            slivers: [
              CatchSliverErrorState(
                title: 'Messages unavailable',
                message: 'Unable to load messages.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Messages unavailable'), findsOneWidget);
    expect(find.text('Unable to load messages.'), findsOneWidget);
    expect(find.byType(CatchErrorBody), findsOneWidget);
  });

  testWidgets(
    'box state viewport centers in the visible floating-shell region',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AppShellActiveTab(
            index: 1,
            bottomBarPlacement: AppShellBottomBarPlacement.floating,
            bottomOverlayInset: 100,
            child: Scaffold(
              key: ValueKey('box-state-scaffold'),
              body: CatchStateViewport(
                child: CatchEmptyState(title: 'Nothing here'),
              ),
            ),
          ),
        ),
      );

      final scaffold = find.byKey(const ValueKey('box-state-scaffold'));
      final offset =
          tester.getCenter(find.byType(CatchEmptyStateContent)).dy -
          tester.getCenter(scaffold).dy;
      expect(offset, closeTo(-50, 1));
    },
  );

  testWidgets(
    'sliver empty and error states center in the visible floating-shell region',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      Future<double> pumpState(Widget sliver, Finder content) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: AppShellActiveTab(
              index: 1,
              bottomBarPlacement: AppShellBottomBarPlacement.floating,
              bottomOverlayInset: 100,
              child: Scaffold(
                key: const ValueKey('state-scaffold'),
                body: CustomScrollView(slivers: [sliver]),
              ),
            ),
          ),
        );
        final viewport = find.descendant(
          of: find.byKey(const ValueKey('state-scaffold')),
          matching: find.byType(CustomScrollView),
        );
        return tester.getCenter(content).dy - tester.getCenter(viewport).dy;
      }

      final emptyOffset = await pumpState(
        const CatchSliverEmptyState(title: 'Nothing here'),
        find.byType(CatchEmptyStateContent),
      );
      expect(emptyOffset, closeTo(-50, 1));

      final errorOffset = await pumpState(
        const CatchSliverErrorState(
          title: 'Unavailable',
          message: 'Try again later.',
        ),
        find.byType(CatchErrorBody),
      );
      expect(errorOffset, closeTo(-50, 1));
    },
  );

  testWidgets('CatchAsyncValueView uses branded default error state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: AsyncError<int>(StateError('load failed'), StackTrace.empty),
          builder: (context, value) => Text('$value'),
        ),
      ),
    );

    expect(find.bySubtype<CatchErrorState>(), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('CatchAsyncValueView supports context-aware state builders', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: AsyncError<int>(StateError('load failed'), StackTrace.empty),
          builder: (context, value) => Text('$value'),
          loadingBuilder: (context) => const Text('Loading custom state'),
          errorBuilder: (context, error, stackTrace) =>
              Text('Custom error: $error'),
        ),
      ),
    );

    expect(find.textContaining('Custom error:'), findsOneWidget);
    expect(find.byType(CatchErrorState), findsNothing);

    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: const AsyncLoading<int>(),
          builder: (context, value) => Text('$value'),
          loadingBuilder: (context) => const Text('Loading custom state'),
        ),
      ),
    );

    expect(find.text('Loading custom state'), findsOneWidget);
  });

  testWidgets('CatchAsyncValueView replaces an expired skeleton with retry', (
    tester,
  ) async {
    const initialLoadTimeout = Duration(milliseconds: 10);
    var retryCount = 0;
    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: const AsyncLoading<int>(),
          initialLoadTimeout: initialLoadTimeout,
          onRetry: () => retryCount += 1,
          builder: (context, value) => Text('$value'),
          loadingBuilder: (_) => const Text('Loading custom state'),
        ),
      ),
    );

    expect(find.text('Loading custom state'), findsOneWidget);
    await pumpFeatureUiFor(
      tester,
      initialLoadTimeout + const Duration(milliseconds: 1),
    );
    expect(
      find.text('The request timed out. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryCount, 1);
    expect(find.text('Loading custom state'), findsOneWidget);
  });

  testWidgets('CatchAsyncScreenLoading uses shared screen body and skeletons', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CatchAsyncScreenLoading(count: 2)));

    expect(find.byType(CatchScreenBody), findsOneWidget);
    expect(find.byType(CatchSkeletonList), findsOneWidget);
  });

  testWidgets('CatchSkeleton.box renders a fixed-size skeleton piece', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(CatchSkeleton.box(width: 42, height: 24)));

    expect(find.byType(CatchSkeleton), findsOneWidget);
    expect(tester.getSize(find.byType(CatchSkeleton)), const Size(42, 24));
  });

  testWidgets('CatchSkeleton uses the theme raised fill in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(CatchSkeleton.box(width: 42, height: 24), theme: AppTheme.dark),
    );

    final themedShape = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(CatchSkeleton),
            matching: find.byType(Container),
          ),
        )
        .firstWhere((container) => container.decoration is BoxDecoration);
    final decoration = themedShape.decoration! as BoxDecoration;
    expect(decoration.color, CatchTokens.dark.raised);
    expect(decoration.color, isNot(CatchTokens.editorialWhite));
  });

  testWidgets('showCatchErrorSnackBar maps errors to user copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showCatchErrorSnackBar(context, StateError('snack failed')),
              child: const Text('Show error'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show error'));
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('showCatchSnackBar pins token contrast in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCatchSnackBar(context, 'Saved.'),
              child: const Text('Show snackbar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    final message = tester.widget<Text>(find.text('Saved.'));
    expect(snackBar.backgroundColor, CatchTokens.dark.ink);
    expect(message.style?.color, CatchTokens.dark.bg);
  });

  testWidgets(
    'showCatchErrorSnackBar exposes retry action for retryable errors',
    (tester) async {
      var retryCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showCatchErrorSnackBar(
                  context,
                  const NetworkException(
                    'timeout',
                    'The request timed out. Please try again.',
                  ),
                  onRetry: () => retryCount++,
                ),
                child: const Text('Show error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show error'));
      await pumpFeatureUi(tester);

      await tester.tap(find.text('Try again'));
      await pumpFeatureUi(tester);

      expect(retryCount, 1);
    },
  );

  testWidgets('CatchMutationErrorBanner renders mutation errors inline', (
    tester,
  ) async {
    final mutation = Mutation<void>();
    var retryCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(mutation);
                return Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await mutation.run(ref, (_) async {
                            throw const NetworkException(
                              'timeout',
                              'The request timed out. Please try again.',
                            );
                          });
                        } catch (_) {}
                      },
                      child: const Text('Save'),
                    ),
                    CatchMutationErrorBanner(
                      mutation: state,
                      onRetry: () => retryCount++,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CatchErrorBanner), findsNothing);

    await tester.tap(find.text('Save'));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchErrorBanner), findsOneWidget);
    expect(
      find.text('The request timed out. Please try again.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Try again'));
    await pumpFeatureUi(tester);

    expect(retryCount, 1);
  });

  testWidgets('CatchMutationErrorListeners handles multiple mutations', (
    tester,
  ) async {
    final saveMutation = Mutation<void>();
    final deleteMutation = Mutation<void>();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => CatchMutationErrorListeners(
                mutations: [saveMutation, deleteMutation],
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await saveMutation.run(ref, (_) async {
                            throw StateError('save failed');
                          });
                        } catch (_) {}
                      },
                      child: const Text('Save'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await deleteMutation.run(ref, (_) async {
                            throw StateError('delete failed');
                          });
                        } catch (_) {}
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Delete'));
    await pumpFeatureUi(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('CatchSearchField renders pill search and clear behavior', (
    tester,
  ) async {
    var query = 'tempo';
    var submitted = '';
    var focused = false;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchSearchField(
            value: query,
            placeholder: 'Search clubs',
            semanticLabel: 'Search clubs',
            onChanged: (value) => setState(() => query = value),
            onSubmitted: (value) => submitted = value,
            onFocusChanged: (value) => focused = value,
          ),
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.search), findsOneWidget);
    expect(find.byIcon(CatchIcons.clearCircle), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'tempo',
    );
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.decoration?.filled, isFalse);
    expect(textField.decoration?.fillColor, Colors.transparent);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focused, isTrue);

    await tester.enterText(find.byType(TextField), 'asha');
    await tester.pump();
    expect(query, 'asha');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submitted, 'asha');

    await tester.tap(find.byIcon(CatchIcons.clearCircle));
    await tester.pump();
    expect(query, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('CatchSearchField expanded mode has no empty trailing control', (
    tester,
  ) async {
    var query = '';
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchSearchField.expanded(
            value: query,
            placeholder: 'Search forms',
            onChanged: (value) => setState(() => query = value),
          ),
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.close), findsNothing);
    expect(find.byIcon(CatchIcons.clearCircle), findsNothing);

    await tester.enterText(find.byType(TextField), 'waiver');
    await tester.pump();
    expect(find.byIcon(CatchIcons.clearCircle), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.clearCircle));
    await tester.pump();
    expect(query, isEmpty);
    expect(find.byIcon(CatchIcons.close), findsNothing);
    expect(find.byIcon(CatchIcons.clearCircle), findsNothing);
  });

  testWidgets(
    'CatchSearchField expanding mode opens, clears, and closes from the app bar slot',
    (tester) async {
      const searchFieldKey = ValueKey('expanding-search-field');
      var query = 'tempo';
      var opened = false;
      var closed = false;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 280,
              child: CatchSearchField.expanding(
                key: searchFieldKey,
                progress: 0,
                maxWidth: 280,
                value: query,
                placeholder: 'Search clubs',
                onChanged: (value) => setState(() => query = value),
                onOpenSearch: () => opened = true,
                onCloseSearch: () => closed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);
      expect(tester.getSize(find.byKey(searchFieldKey)).width, 280);
      expect(find.byIcon(CatchIcons.search), findsOneWidget);

      await tester.tap(find.byIcon(CatchIcons.search));
      await tester.pump();
      expect(opened, isTrue);

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 280,
              child: CatchSearchField.expanding(
                key: searchFieldKey,
                progress: 0.5,
                maxWidth: 280,
                value: query,
                placeholder: 'Search clubs',
                onChanged: (value) => setState(() => query = value),
                onOpenSearch: () => opened = true,
                onCloseSearch: () => closed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(CatchMotion.base);

      expect(find.byType(TextField), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 280,
              child: CatchSearchField.expanding(
                key: searchFieldKey,
                progress: 1,
                maxWidth: 280,
                value: query,
                placeholder: 'Search clubs',
                onChanged: (value) => setState(() => query = value),
                onOpenSearch: () => opened = true,
                onCloseSearch: () => closed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(CatchMotion.base);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(CatchIcons.clearCircle), findsOneWidget);

      await tester.tap(find.byIcon(CatchIcons.clearCircle));
      await tester.pump();
      expect(query, isEmpty);
      expect(closed, isFalse);
      expect(find.byIcon(CatchIcons.close), findsOneWidget);

      await tester.tap(find.byIcon(CatchIcons.close));
      await tester.pump();
      expect(closed, isTrue);
    },
  );

  testWidgets('CatchMenu renders handoff rows and selection state', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _wrap(
        CatchMenu<String>(
          width: 220,
          items: [
            CatchMenuItem(
              value: 'owner',
              label: 'Owner club',
              sublabel: 'OWNER',
              icon: CatchIcons.hostBadge,
              selected: true,
              role: CatchMenuItemRole.choice,
            ),
            CatchMenuItem(
              value: 'delete',
              label: 'Delete club',
              icon: CatchIcons.deleteOutline,
              danger: true,
            ),
          ],
          onSelected: (value, _) => selected = value,
        ),
      ),
    );

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.width, 220);
    expect(surface.radius, CatchRadius.md);
    expect(surface.elevation, CatchSurfaceElevation.overlay);
    expect(find.text('Owner club'), findsOneWidget);
    expect(find.text('OWNER'), findsOneWidget);
    expect(find.byIcon(CatchIcons.check), findsOneWidget);
    expect(find.byType(CatchDivider), findsNothing);
    expect(find.byType(CatchMenuRow<String>), findsNWidgets(2));

    await tester.tap(find.text('Delete club'));
    await tester.pump();

    expect(selected, 'delete');
  });

  testWidgets(
    'CatchMenuAnchor keeps long menus above floating shell navigation',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AppShellActiveTab(
            index: 0,
            bottomBarPlacement: AppShellBottomBarPlacement.floating,
            bottomOverlayInset: 100,
            child: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(
                    width: 320,
                    child: CatchMenuAnchor<int>(
                      items: [
                        for (var index = 0; index < 20; index++)
                          CatchMenuItem(value: index, label: 'Option $index'),
                      ],
                      builder: (context, controller, child) => ElevatedButton(
                        onPressed: controller.open,
                        child: const Text('Open menu'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open menu'));
      await pumpFeatureUi(tester);

      final menu = find.byType(CatchMenu<int>);
      expect(menu, findsOneWidget);
      expect(tester.getRect(menu).bottom, lessThanOrEqualTo(700));
      final scrollable = find.descendant(
        of: menu,
        matching: find.byType(Scrollable),
      );
      expect(scrollable, findsOneWidget);
      expect(
        tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
        greaterThan(0),
      );
    },
  );

  testWidgets('CatchMenuAnchor flips short menus flush above their trigger', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShellActiveTab(
          index: 0,
          bottomBarPlacement: AppShellBottomBarPlacement.floating,
          bottomOverlayInset: 100,
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: SizedBox(
                  width: 240,
                  child: CatchMenuAnchor<int>(
                    items: const [
                      CatchMenuItem(value: 1, label: 'First option'),
                      CatchMenuItem(value: 2, label: 'Second option'),
                    ],
                    builder: (context, controller, child) => ElevatedButton(
                      onPressed: controller.open,
                      child: const Text('Open short menu'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final trigger = find.text('Open short menu');
    final triggerTop = tester
        .getRect(
          find.ancestor(of: trigger, matching: find.byType(ElevatedButton)),
        )
        .top;
    await tester.tap(trigger);
    await pumpFeatureUi(tester);

    final menuRect = tester.getRect(find.byType(CatchMenu<int>));
    expect(menuRect.bottom, closeTo(triggerTop, 1));
    expect(menuRect.bottom, lessThanOrEqualTo(700));
  });

  testWidgets('CatchMenuRow disables selection when item is disabled', (
    tester,
  ) async {
    var selected = false;

    await tester.pumpWidget(
      _wrap(
        CatchMenuRow<String>(
          item: const CatchMenuItem(
            value: 'locked',
            label: 'Locked',
            enabled: false,
          ),
          onSelected: (_, _) => selected = true,
        ),
      ),
    );

    await tester.tap(find.text('Locked'));
    expect(selected, isFalse);
  });

  testWidgets('CatchActionMenu opens the shared handoff menu panel', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _wrap(
        CatchActionMenu<String>(
          tooltip: 'More actions',
          items: [
            CatchActionMenuItem(
              value: 'active',
              label: 'Open active club',
              icon: CatchIcons.hostBadge,
            ),
            CatchActionMenuItem(
              value: 'remove',
              label: 'Remove host',
              icon: CatchIcons.deleteOutline,
              isDestructive: true,
            ),
          ],
          onSelected: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.byTooltip('More actions'));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchMenu<String>), findsOneWidget);
    expect(find.text('Open active club'), findsOneWidget);
    expect(find.byIcon(CatchIcons.check), findsNothing);

    await tester.tap(find.text('Remove host'));
    await pumpFeatureUi(tester);

    expect(selected, 'remove');
    expect(find.byType(CatchMenu<String>), findsNothing);
  });

  testWidgets(
    'CatchActionMenu rejects compound menus with more than five commands',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          CatchActionMenu<int>(
            tooltip: 'Too many actions',
            items: [
              for (var index = 0; index < 6; index++)
                CatchActionMenuItem(value: index, label: 'Action $index'),
            ],
          ),
        ),
      );

      expect(
        tester.takeException(),
        isA<AssertionError>().having(
          (error) => error.message,
          'message',
          contains('at most five commands'),
        ),
      );
    },
  );

  testWidgets('disabled action rows require an actionable explanation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchActionMenu<String>(
          tooltip: 'More actions',
          items: [
            CatchActionMenuItem(
              value: 'status',
              label: 'WhatsApp ready',
              enabled: false,
            ),
          ],
        ),
      ),
    );

    expect(
      tester.takeException(),
      isA<AssertionError>().having(
        (error) => error.message,
        'message',
        contains('Informational status does not belong in an action menu'),
      ),
    );
  });

  testWidgets('CatchMenu reflows long labels at supported text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        const CatchMenu<String>(
          width: 280,
          items: [
            CatchMenuItem(
              value: 'review',
              label: 'Review possible duplicate customer records',
              sublabel: 'Compare identity evidence before merging anything.',
            ),
          ],
        ),
        textScale: 2,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Review possible duplicate customer records'), findsOne);
    expect(
      tester
          .widget<Text>(find.text('Review possible duplicate customer records'))
          .maxLines,
      2,
    );
  });

  testWidgets('adaptive selection uses a sheet on compact layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selected = 'last-seen';

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchAdaptiveSelectionControl<String>(
            title: 'Sort customers',
            subtitle: 'Choose how customers are ordered.',
            tooltip: 'Sort customers',
            value: selected,
            items: const [
              CatchSelectionMenuItem(value: 'last-seen', label: 'Last seen'),
              CatchSelectionMenuItem(value: 'name', label: 'Name'),
            ],
            triggerLabel: (item) => 'Sort: ${item.label}',
            onSelected: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sort: Last seen'));
    await pumpFeatureUi(tester);
    expect(find.byType(CatchSelectionSheet<String>), findsOneWidget);

    final nameSemantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.inMutuallyExclusiveGroup == true &&
            widget.properties.selected == false,
      ),
    );
    expect(nameSemantics.properties.inMutuallyExclusiveGroup, isTrue);

    await tester.tap(find.text('Name'));
    await pumpFeatureUi(tester);
    expect(find.text('Sort: Name'), findsOneWidget);
  });

  testWidgets('adaptive selection uses an anchored picker on wider layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        CatchAdaptiveSelectionControl<String>(
          title: 'Sort customers',
          tooltip: 'Sort customers',
          value: 'last-seen',
          items: const [
            CatchSelectionMenuItem(value: 'last-seen', label: 'Last seen'),
            CatchSelectionMenuItem(value: 'name', label: 'Name'),
          ],
          triggerLabel: (item) => 'Sort: ${item.label}',
          onSelected: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Sort: Last seen'));
    await pumpFeatureUi(tester);
    expect(find.byType(CatchSelectionMenu<String>), findsOneWidget);
    expect(find.byType(CatchSelectionSheet<String>), findsNothing);
    expect(find.byType(CatchMenu<String>), findsOneWidget);
  });
}
