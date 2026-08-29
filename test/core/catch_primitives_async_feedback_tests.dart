part of 'catch_primitives_test.dart';

void _registerCatchPrimitivesAsyncFeedbackTests() {
  testWidgets('CatchDetailHeroBackdrop composes fallback and scrim renderers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchDetailHeroBackdrop(),
        ),
      ),
    );

    expect(find.byType(CatchDetailHeroFallback), findsOneWidget);
    expect(find.byType(CatchScrim), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchDetailHeroBackdrop(showScrim: false),
        ),
      ),
    );

    expect(find.byType(CatchDetailHeroFallback), findsOneWidget);
    expect(find.byType(CatchScrim), findsNothing);
  });

  testWidgets('CatchEventThumbnail composes fallback and scrim renderers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchEventThumbnail(
            photoUrl: null,
            pace: PaceLevel.easy,
            activityKind: ActivityKind.socialRun,
          ),
        ),
      ),
    );

    expect(find.byType(CatchEventThumbnailActivityFallback), findsOneWidget);
    expect(find.byType(CatchEventThumbnailScrimOverlay), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchEventThumbnail(
            photoUrl: null,
            pace: PaceLevel.easy,
            activityKind: ActivityKind.dinner,
            scrim: CatchEventThumbnailScrim.none,
          ),
        ),
      ),
    );

    expect(find.byType(CatchEventThumbnailActivityFallback), findsOneWidget);
    expect(find.byType(CatchEventThumbnailScrimOverlay), findsNothing);
  });

  testWidgets('CatchMetricStrip renders compact labeled data pairs', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchMetricStrip(
            items: [
              CatchMetricStripItem(value: '124', label: 'members'),
              CatchMetricStripItem(value: '3', label: 'upcoming'),
              CatchMetricStripItem(value: '4.7', label: 'rating'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('124'), findsOneWidget);
    expect(find.text('members'), findsOneWidget);
    expect(find.text('upcoming'), findsOneWidget);
    expect(find.text('rating'), findsOneWidget);
    expect(find.byType(CatchMetricStripCell), findsNWidgets(3));
    expect(find.byType(CatchMetricStripDivider), findsNWidgets(2));
  });

  testWidgets('CatchMetricStrip stacks data pairs at large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchMetricStrip(
            items: [
              CatchMetricStripItem(value: '12', label: 'responses'),
              CatchMetricStripItem(value: '6', label: 'questions'),
              CatchMetricStripItem(value: '1', label: 'published version'),
            ],
          ),
        ),
        textScale: 2,
      ),
    );

    expect(
      find.byKey(const ValueKey('catch_metric_strip.reflow')),
      findsOneWidget,
    );
    expect(
      tester.getCenter(find.text('12')).dy,
      lessThan(tester.getCenter(find.text('6')).dy),
    );
    expect(
      tester.getCenter(find.text('6')).dy,
      lessThan(tester.getCenter(find.text('1')).dy),
    );
    expect(find.byType(CatchMetricStripDivider), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CatchDaySectionHeader composes count renderer', (tester) async {
    await tester.pumpWidget(
      _wrap(const CatchDaySectionHeader(label: 'Today', count: 3)),
    );

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.byType(CatchDaySectionHeaderCount), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(const CatchDaySectionHeader(label: 'Tomorrow')),
    );

    expect(find.byType(CatchDaySectionHeaderCount), findsNothing);
  });

  testWidgets('CatchJourneySteps composes public step nodes', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatchJourneySteps(
          steps: [
            CatchJourneyStep(title: 'Arrive', body: 'Check in with the host.'),
            CatchJourneyStep(title: 'Meet', body: 'Start the first round.'),
          ],
        ),
      ),
    );

    expect(find.text('01'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.byType(CatchJourneyStepNode), findsNWidgets(2));
  });

  testWidgets('CatchTabBar reveals only the selected label and badges icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchTabBar<String>(
          active: 'chats',
          items: const [
            CatchTabBarItem(
              id: 'home',
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            CatchTabBarItem(
              id: 'chats',
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Chats',
              badgeCount: 104,
            ),
          ],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(CatchTabBarButton<String>), findsNWidgets(2));
    expect(find.byType(CatchTabBarIcon), findsNWidgets(2));
    expect(find.text('Home'), findsNothing);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('CatchTabBar keeps four animated destinations within 390px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var active = 'home';
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchTabBar<String>(
            active: active,
            items: const [
              CatchTabBarItem(id: 'home', icon: Icons.home, label: 'Home'),
              CatchTabBarItem(
                id: 'explore',
                icon: Icons.explore,
                label: 'Explore',
              ),
              CatchTabBarItem(id: 'chats', icon: Icons.chat, label: 'Chats'),
              CatchTabBarItem(id: 'profile', icon: Icons.person, label: 'You'),
            ],
            onChanged: (next) => setState(() => active = next),
          ),
        ),
      ),
    );

    final originalElements = <String, Element>{
      for (final id in const ['home', 'explore', 'chats', 'profile'])
        id: tester.element(
          find.byKey(ValueKey<Object>('catch_tab_bar.slot.$id')),
        ),
    };
    await tester.tap(find.bySemanticsLabel('Explore'));
    await pumpFeatureUi(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Explore'), findsOneWidget);
    for (final entry in originalElements.entries) {
      expect(
        identical(
          entry.value,
          tester.element(
            find.byKey(ValueKey<Object>('catch_tab_bar.slot.${entry.key}')),
          ),
        ),
        isTrue,
        reason: '${entry.key} should keep its element while selection moves',
      );
    }

    final iconRect = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey<Object>('catch_tab_bar.pill.explore')),
        matching: find.byIcon(Icons.explore),
      ),
    );
    final labelRect = tester.getRect(find.text('Explore'));
    expect(iconRect.center.dy, closeTo(labelRect.center.dy, 0.5));

    await tester.tap(find.bySemanticsLabel('You'));
    await pumpFeatureUi(tester);
    final compactWidths = const ['home', 'explore', 'chats']
        .map(
          (id) => tester
              .getRect(find.byKey(ValueKey<Object>('catch_tab_bar.slot.$id')))
              .width,
        )
        .toList();
    expect(compactWidths[0], closeTo(compactWidths[1], 0.5));
    expect(compactWidths[1], closeTo(compactWidths[2], 0.5));
  });

  testWidgets('CatchHorizontalRail is embedded and chromeless by default', (
    tester,
  ) async {
    const railKey = ValueKey('embedded-rail');

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          key: railKey,
          width: 360,
          child: CatchHorizontalRail(
            title: 'Recommended',
            itemCount: 1,
            itemBuilder: (context, index) =>
                const SizedBox(width: 48, height: 48, child: Text('Item 1')),
          ),
        ),
      ),
    );

    final railLeft = tester.getTopLeft(find.byKey(railKey)).dx;

    expect(tester.getTopLeft(find.text('Recommended')).dx, railLeft);
    expect(tester.getTopLeft(find.text('Item 1')).dx, railLeft);
    expect(find.byType(CatchDivider), findsNothing);
  });

  testWidgets('CatchHorizontalRail fullBleed owns rail gutters and divider', (
    tester,
  ) async {
    const railKey = ValueKey('full-bleed-rail');

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          key: railKey,
          width: 360,
          child: CatchHorizontalRail(
            title: 'Recommended',
            itemCount: 1,
            fullBleed: true,
            itemBuilder: (context, index) =>
                const SizedBox(width: 48, height: 48, child: Text('Item 1')),
          ),
        ),
      ),
    );

    final railLeft = tester.getTopLeft(find.byKey(railKey)).dx;

    expect(
      tester.getTopLeft(find.text('Recommended')).dx - railLeft,
      CatchSpacing.screenPx,
    );
    expect(
      tester.getTopLeft(find.text('Item 1')).dx - railLeft,
      CatchSpacing.screenPx,
    );
    expect(find.byType(CatchDivider), findsOneWidget);
  });

  testWidgets('CatchScreenBody owns the scrolling page gutter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            height: 480,
            child: CatchScreenBody(
              pt: CatchSpacing.s2,
              pb: CatchSpacing.s8,
              child: SizedBox(height: 900, child: Text('Body')),
            ),
          ),
        ),
      ),
    );

    final bodyFinder = find.byType(CatchScreenBody);
    final padding = tester.widget<Padding>(
      find.descendant(of: bodyFinder, matching: find.byType(Padding)).first,
    );
    final minHeight = tester.widget<ConstrainedBox>(
      find
          .descendant(of: bodyFinder, matching: find.byType(ConstrainedBox))
          .first,
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      padding.padding,
      const EdgeInsets.fromLTRB(
        CatchSpacing.screenPx,
        CatchSpacing.s2,
        CatchSpacing.screenPx,
        CatchSpacing.s8,
      ),
    );
    expect(minHeight.constraints.minHeight, 480);
  });

  testWidgets('CatchScreenBody can drop the gutter without owning scroll', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchScreenBody(
          gutter: false,
          scrollable: false,
          child: Text('Full bleed body'),
        ),
      ),
    );

    final padding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(CatchScreenBody),
            matching: find.byType(Padding),
          )
          .first,
    );

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      padding.padding,
      const EdgeInsets.fromLTRB(
        CatchSpacing.s0,
        CatchSpacing.screenPt,
        CatchSpacing.s0,
        CatchSpacing.screenPb,
      ),
    );
  });

  testWidgets('compact core atoms render with shared primitives', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchMetaDotRow(
                entries: [
                  CatchMetaEntry(
                    label: 'Tonight',
                    icon: CatchIcons.calendarTodayOutlined,
                  ),
                  const CatchMetaEntry(label: 'Bandra'),
                ],
                trailing: const CatchMetaEntry(label: '2.3 km'),
              ),
              gapH12,
              const CatchField.read(title: 'Payment ID', body: 'pay_123'),
              gapH12,
              const CatchStatColumn(
                value: '24',
                label: 'members',
                center: true,
              ),
              gapH12,
              const CatchGradedImage(
                enabled: false,
                child: SizedBox.square(
                  dimension: 12,
                  child: ColoredBox(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Bandra'), findsOneWidget);
    expect(find.text('2.3 km'), findsOneWidget);
    expect(find.byType(CatchMetaEntryFlow), findsOneWidget);
    expect(find.byType(CatchMetaEntryView), findsNWidgets(3));
    expect(find.text('Payment ID'), findsOneWidget);
    expect(find.text('pay_123'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('members'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('CatchStartupLoadingScreen delays slow-boot spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CatchStartupLoadingScreen(),
      ),
    );

    expect(find.bySemanticsLabel('Catch'), findsOneWidget);
    final logo = tester.widget<Image>(_startupLogoFinder);
    expect(
      (logo.image as AssetImage).assetName,
      CatchStartupLoadingScreen.lightIconAsset,
    );
    expect(find.byType(CatchLoadingIndicator), findsNothing);

    await tester.pump(CatchMotion.startupIndicatorDelay);
    await tester.pump(CatchMotion.fast);

    expect(find.byType(CatchLoadingIndicator), findsOneWidget);
  });

  testWidgets('CatchStartupLoadingScreen uses dark splash mark in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const CatchStartupLoadingScreen(),
      ),
    );

    final logo = tester.widget<Image>(_startupLogoFinder);
    expect(
      (logo.image as AssetImage).assetName,
      CatchStartupLoadingScreen.darkIconAsset,
    );
  });

  testWidgets('CatchStatusBar renders handoff light and surface states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchStatusBar(time: '10:24', surface: true)),
    );

    final time = tester.widget<Text>(find.text('10:24'));
    final surface = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(CatchStatusBar),
        matching: find.byType(ColoredBox),
      ),
    );
    final iconTheme = tester.widget<IconTheme>(
      find.descendant(
        of: find.byType(CatchStatusBar),
        matching: find.byType(IconTheme),
      ),
    );

    expect(surface.color, CatchTokens.editorialLight.surface);
    expect(time.style?.fontSize, CatchLayout.statusBarTimeFontSize);
    expect(time.style?.fontWeight, FontWeight.w700);
    expect(time.style?.color, CatchTokens.editorialLight.ink);
    expect(iconTheme.data.color, CatchTokens.editorialLight.ink);
    expect(find.byIcon(CatchIcons.statusCellSignal), findsOneWidget);
    expect(find.byIcon(CatchIcons.statusWifi), findsOneWidget);
    expect(find.byIcon(CatchIcons.statusBattery), findsOneWidget);
  });

  testWidgets('CatchStatusBar renders paper ink on dark wow surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchStatusBar(tone: CatchStatusBarTone.dark)),
    );

    final time = tester.widget<Text>(find.text('9:41'));
    final iconTheme = tester.widget<IconTheme>(
      find.descendant(
        of: find.byType(CatchStatusBar),
        matching: find.byType(IconTheme),
      ),
    );

    expect(time.style?.color, CatchTokens.editorialDark.ink);
    expect(iconTheme.data.color, CatchTokens.editorialDark.ink);
  });

  testWidgets('CatchSurface supports padding, fixed size, and tap handling', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        CatchSurface(
          width: 180,
          padding: const EdgeInsets.all(16),
          tone: CatchSurfaceTone.raised,
          borderColor: Colors.black,
          onTap: () => tapped = true,
          child: const Text('Surface content'),
        ),
      ),
    );

    expect(find.text('Surface content'), findsOneWidget);
    expect(tester.getSize(find.byType(CatchSurface)).width, 180);

    await tester.tap(find.text('Surface content'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('CatchSurface.card renders the handoff card surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchSurface.card(width: 240, child: Text('Panel content'))),
    );

    final panelSurface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(find.text('Panel content'), findsOneWidget);
    expect(panelSurface.role, CatchSurfaceRole.card);
    expect(panelSurface.width, 240);
    expect(panelSurface.padding, CatchInsets.contentRelaxed);
    expect(panelSurface.radius, CatchRadius.md);
    expect(panelSurface.elevation, CatchSurfaceElevation.card);
  });

  testWidgets('CatchSurface.message renders inline title and tone content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSurface.message(
          title: 'Host tip',
          message: 'Keep the first message short and specific.',
          messageTone: CatchSurfaceMessageTone.warning,
        ),
      ),
    );

    final messageSurfaceFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CatchSurface && widget.role == CatchSurfaceRole.message,
    );
    final renderedSurfaceFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CatchSurface && widget.role == CatchSurfaceRole.base,
    );
    final messageSurface = tester.widget<CatchSurface>(messageSurfaceFinder);
    final renderedSurface = tester.widget<CatchSurface>(renderedSurfaceFinder);
    expect(find.text('Host tip'), findsOneWidget);
    expect(
      find.text('Keep the first message short and specific.'),
      findsOneWidget,
    );
    expect(messageSurfaceFinder, findsOneWidget);
    expect(renderedSurfaceFinder, findsOneWidget);
    expect(messageSurface.role, CatchSurfaceRole.message);
    expect(renderedSurface.role, CatchSurfaceRole.base);
    expect(renderedSurface.radius, CatchRadius.md);
  });

  testWidgets('CatchEmptyState defaults to the handoff quiet placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchEmptyState(
          icon: CatchIcons.search,
          title: 'Nothing here yet',
          message: 'Try another filter or check back soon.',
          action: CatchButton(label: 'Browse events', onPressed: () {}),
        ),
      ),
    );

    expect(find.byType(CatchSurface), findsNothing);
    expect(find.byType(CatchEmptyStateContent), findsOneWidget);
    expect(find.byType(CatchEmptyStateIcon), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(CatchIcons.search));
    final title = tester.widget<Text>(find.text('Nothing here yet'));
    final message = tester.widget<Text>(
      find.text('Try another filter or check back soon.'),
    );
    final titleContext = tester.element(find.text('Nothing here yet'));
    final messageContext = tester.element(
      find.text('Try another filter or check back soon.'),
    );

    expect(icon.size, 34);
    expect(icon.color, CatchTokens.editorialLight.ink3);
    expect(
      title.style?.fontSize,
      CatchTextStyles.sectionTitle(titleContext).fontSize,
    );
    expect(
      message.style?.fontSize,
      CatchTextStyles.bodyS(messageContext).fontSize,
    );
    expect(message.style?.color, CatchTokens.editorialLight.ink2);
    expect(find.text('Browse events'), findsOneWidget);
  });

  testWidgets('CatchBottomSheetScaffold renders the handoff plain sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchBottomSheetScaffold(
          title: 'Filters',
          subtitle: 'Tune what shows up first.',
          badge: '2',
          badgeTone: CatchBadgeTone.gold,
          action: CatchButton(label: 'Apply', onPressed: () {}),
          child: const Text('Sheet body'),
        ),
      ),
    );

    expect(find.byType(CatchBottomSheetGrabber), findsOneWidget);
    expect(find.byType(CatchPlainSheetHeader), findsOneWidget);
    expect(find.byType(CatchBrandedSheetHeader), findsNothing);
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Tune what shows up first.'), findsOneWidget);
    expect(find.widgetWithText(CatchBadge, '2'), findsOneWidget);
    expect(find.text('Sheet body'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('CatchBottomSheetScaffold renders the branded sheet header', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchBottomSheetScaffold(
          title: 'Set up payouts',
          subtitle: 'Powered by Stripe',
          glyph: CatchIcons.hostBadge,
          trailing: const Text('Soon'),
          grabber: false,
          child: const Text('Stripe body'),
        ),
      ),
    );

    expect(find.byType(CatchBottomSheetGrabber), findsNothing);
    expect(find.byType(CatchPlainSheetHeader), findsNothing);
    expect(find.byType(CatchBrandedSheetHeader), findsOneWidget);
    final glyph = tester.widget<Icon>(find.byIcon(CatchIcons.hostBadge));
    expect(glyph.size, CatchLayout.sheetGlyphIconSize);
    expect(glyph.color, CatchTokens.editorialLight.primaryInk);
    expect(find.text('Set up payouts'), findsOneWidget);
    expect(find.text('Powered by Stripe'), findsOneWidget);
    expect(find.text('Soon'), findsOneWidget);
    expect(find.text('Stripe body'), findsOneWidget);
  });

  testWidgets(
    'CatchBottomSheetScaffold reserves device inset plus terminal gap',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
            child: CatchBottomSheetScaffold(
              grabber: false,
              child: Text('Sheet body'),
            ),
          ),
        ),
      );

      expect(
        _bottomSheetContentPadding(tester),
        const EdgeInsets.fromLTRB(
          CatchLayout.sheetHorizontalPadding,
          CatchLayout.sheetTopPadding,
          CatchLayout.sheetHorizontalPadding,
          34 + CatchLayout.sheetBottomSafeAreaGap,
        ),
      );
    },
  );

  testWidgets(
    'CatchBottomSheetScaffold keeps the visual minimum without an inset',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(),
            child: CatchBottomSheetScaffold(
              grabber: false,
              child: Text('Sheet body'),
            ),
          ),
        ),
      );

      expect(
        _bottomSheetContentPadding(tester).bottom,
        CatchLayout.sheetBottomPadding,
      );
    },
  );

  testWidgets(
    'CatchBottomSheetScaffold uses keyboard obstruction when requested',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(
              viewPadding: EdgeInsets.only(bottom: 34),
              viewInsets: EdgeInsets.only(bottom: 300),
            ),
            child: CatchBottomSheetScaffold(
              grabber: false,
              keyboardSafe: true,
              child: Text('Sheet body'),
            ),
          ),
        ),
      );

      expect(
        _bottomSheetContentPadding(tester).bottom,
        300 + CatchLayout.sheetBottomSafeAreaGap,
      );
    },
  );

  testWidgets(
    'CatchBottomSheetScaffold enforces terminal space with custom padding',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
            child: CatchBottomSheetScaffold(
              grabber: false,
              padding: EdgeInsetsDirectional.fromSTEB(12, 8, 20, 0),
              child: Text('Sheet body'),
            ),
          ),
        ),
      );

      expect(
        _bottomSheetContentPadding(tester),
        const EdgeInsets.fromLTRB(
          12,
          8,
          20,
          34 + CatchLayout.sheetBottomSafeAreaGap,
        ),
      );
    },
  );

  testWidgets(
    'CatchSurface disables chrome animation when reduced motion is on',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: CatchSurface.card(child: Text('Panel')),
          ),
        ),
      );

      final surface = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(CatchSurface),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(surface.duration, Duration.zero);
    },
  );

  testWidgets('CatchFrameworkErrorView renders branded recovery UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchFrameworkErrorView(
          details: FlutterErrorDetails(exception: StateError('boom')),
          showDebugDetails: false,
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.textContaining('This screen hit a temporary app error'),
      findsOneWidget,
    );
    expect(find.text('Developer details'), findsNothing);
    expect(find.textContaining('boom'), findsNothing);
  });

  testWidgets('CatchErrorIcon renders the shared branded medallion', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CatchErrorIcon()));

    expect(find.byType(CatchErrorIcon), findsOneWidget);
    expect(find.byIcon(CatchIcons.errorOutlineRounded), findsOneWidget);
  });

  testWidgets('CatchMonoLabel renders compact metadata with overflow guard', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchMonoLabel('TODAY AT 7 PM', color: Colors.black)),
    );

    final text = tester.widget<Text>(find.text('TODAY AT 7 PM'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('CatchFrameworkErrorView can expose debug details', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchFrameworkErrorView(
          details: FlutterErrorDetails(exception: StateError('boom')),
        ),
      ),
    );

    expect(find.text('Developer details'), findsOneWidget);
    expect(find.byType(CatchFrameworkErrorDebugDetails), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
    await tester.tap(find.text('Developer details'));
    await pumpFeatureUi(tester);
    expect(find.textContaining('Bad state: boom'), findsOneWidget);
  });

  testWidgets('CatchFrameworkErrorDebugDetails renders expanded details', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchFrameworkErrorDebugDetails(
          details: 'debug exception details',
          initiallyExpanded: true,
        ),
      ),
    );

    expect(find.text('Developer details'), findsOneWidget);
    expect(find.text('debug exception details'), findsOneWidget);
  });
}

EdgeInsets _bottomSheetContentPadding(WidgetTester tester) {
  return tester
          .widget<Padding>(
            find.byKey(
              const ValueKey<String>('catch-bottom-sheet-content-padding'),
            ),
          )
          .padding
      as EdgeInsets;
}
