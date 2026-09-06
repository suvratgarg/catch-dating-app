import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets(
    'CatchRootScreenPageScrollView centers opted-in slivers at content width',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(SliverCrossAxisGroup), findsOneWidget);
      expect(find.byType(SliverConstrainedCrossAxis), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('root-page-frame'))).width,
        CatchLayout.maxContentWidth,
      );
      final contentRect = tester.getRect(
        find.byKey(const ValueKey('root-page-content')),
      );
      expect(contentRect.width, CatchLayout.maxContentWidth);
      expect(contentRect.left, (1000 - CatchLayout.maxContentWidth) / 2);
    },
  );

  testWidgets(
    'CatchRootScreenPageScrollView keeps full bleed free of a width clamp',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrap(bodyLayout: CatchScreenBodyLayout.fullBleed),
      );
      await tester.pump();

      expect(find.byType(SliverCrossAxisGroup), findsNothing);
      expect(find.byType(SliverConstrainedCrossAxis), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('root-page-frame'))).width,
        1000,
      );
    },
  );

  testWidgets('CatchRootScreenPageScrollView resolves semantic top rhythm', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final (layout, expectedTop) in [
      (CatchScreenBodyLayout.standard, CatchInsets.pageBody.top),
      (CatchScreenBodyLayout.fullBleed, 0.0),
    ]) {
      await tester.pumpWidget(_wrap(bodyLayout: layout));
      await tester.pump();

      final rail = tester.getRect(find.byKey(const ValueKey('root-page-rail')));
      final body = tester.getRect(
        find.byKey(const ValueKey('root-page-frame')),
      );
      expect(
        body.top - rail.bottom,
        closeTo(expectedTop, 0.001),
        reason: '$layout must own its exact tab-to-body relationship.',
      );
    }
  });

  testWidgets('root page publishes the shell obstruction to expanding fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppShellActiveTab(
        index: 0,
        bottomBarPlacement: AppShellBottomBarPlacement.floating,
        bottomOverlayInset: 96,
        child: _wrap(),
      ),
    );

    final scope = tester.widget<CatchFieldVisibilityScope>(
      find.byType(CatchFieldVisibilityScope),
    );
    expect(scope.bottomObstruction, 96);
  });

  testWidgets('root page roles close terminal-clearance ownership', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    expect(find.byType(CatchSliverTerminalPadding), findsOneWidget);

    await tester.pumpWidget(_wrap(bodyLayout: CatchScreenBodyLayout.fullBleed));
    expect(find.byType(CatchSliverTerminalPadding), findsOneWidget);

    await tester.pumpWidget(_wrapEmbeddedViewport());
    expect(find.byType(CatchSliverTerminalPadding), findsNothing);
  });

  test('root primary-rail geometry uses the approved compact rhythm', () {
    expect(CatchInsets.primaryRailTitleBlock.bottom, CatchSpacing.s2);
    expect(CatchLayout.tabRailHeight, 44);
    expect(CatchInsets.pageBody.top, 16);
  });

  testWidgets('scaled root rail reserves its full height above page content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(textScaler: const TextScaler.linear(2), useCanonicalRail: true),
    );
    final rail = find.byKey(const ValueKey('root-page-rail'));
    final railRect = tester.getRect(rail);
    final bodyRect = tester.getRect(
      find.byKey(const ValueKey('root-page-frame')),
    );
    expect(railRect.height, CatchTabRail.heightFor(tester.element(rail)));
    expect(railRect.height, greaterThan(CatchLayout.tabRailHeight));
    expect(
      bodyRect.top - railRect.bottom,
      closeTo(CatchInsets.pageBody.top, .001),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('root title scrolls away while its primary rail stays pinned', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap(contentHeight: 1800));
    final titleBefore = tester.getRect(find.text('Workspace'));
    final railBefore = tester.getRect(
      find.byKey(const ValueKey('root-page-rail')),
    );

    await tester.drag(
      find.byType(CatchRootScreenPageScrollView),
      const Offset(0, -600),
    );
    await pumpFeatureUi(tester);

    final railAfterCollapse = tester.getRect(
      find.byKey(const ValueKey('root-page-rail')),
    );
    expect(titleBefore.top, greaterThanOrEqualTo(0));
    expect(find.text('Workspace'), findsNothing);
    expect(railAfterCollapse.top, lessThan(railBefore.top));

    await tester.drag(
      find.byType(CatchRootScreenPageScrollView),
      const Offset(0, -240),
    );
    await pumpFeatureUi(tester);

    final railAfterBodyScroll = tester.getRect(
      find.byKey(const ValueKey('root-page-rail')),
    );
    expect(
      railAfterBodyScroll.top,
      closeTo(railAfterCollapse.top, 0.001),
      reason: 'Only the title collapses; the primary rail remains pinned.',
    );
  });

  testWidgets(
    'CatchRootScreenScaffold gives search the compact primary-rail title band',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const CatchRootScreenScaffold.withPrimaryRail(
            header: CatchRootScreenHeader.title(
              title: 'Forms',
              search: CatchTopBarSearch(
                placeholder: 'Search forms',
                tooltip: 'Search forms',
              ),
            ),
            primaryRail: _TestPrimaryRail(),
            body: CatchRootScreenBody.single(
              page: CatchRootScreenPageSpec.scroll(
                page: CatchRootScreenPageScrollView.standard(
                  scrollKey: PageStorageKey('search-root-page'),
                  slivers: <Widget>[
                    SliverToBoxAdapter(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Forms'), findsOneWidget);
      final titleBar = tester.widget<CatchScreenTopBar>(
        find.byType(CatchScreenTopBar),
      );
      final expectedContentHeight =
          CatchIconButton.targetExtentFor(CatchIconButton.navSize) +
          CatchInsets.primaryRailTitleBlock.vertical;
      expect(titleBar.contentPadding, CatchInsets.primaryRailTitleBlock);
      expect(titleBar.applySafeArea, isFalse);
      expect(titleBar.leadingType, CatchTopBarLeading.none);
      expect(titleBar.height, expectedContentHeight);
      expect(titleBar.height, lessThanOrEqualTo(CatchLayout.topBarHeight));

      await tester.tap(find.byIcon(CatchIcons.search));
      await tester.pump(CatchMotion.base);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CatchSearchField &&
              widget.mode == CatchSearchFieldMode.expanding,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CatchRootScreenScaffold rejects noncanonical primary rail heights',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const CatchRootScreenScaffold.withPrimaryRail(
            header: CatchRootScreenHeader.title(title: 'Workspace'),
            primaryRail: _TestPrimaryRail(height: 52),
            body: CatchRootScreenBody.single(
              page: CatchRootScreenPageSpec.scroll(
                page: CatchRootScreenPageScrollView.standard(
                  scrollKey: PageStorageKey('invalid-rail-root-page'),
                  slivers: <Widget>[],
                ),
              ),
            ),
          ),
        ),
      );

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect(
        error.toString(),
        contains(
          'CatchRootScreenScaffold requires a '
          '${CatchTabRail.minimumHeight}-point primary rail.',
        ),
      );
      expect(error.toString(), contains('declared a preferred height of 52.0'));
      expect(
        error.toString(),
        contains('screens must not define local rail geometry'),
      );
    },
  );

  testWidgets('CatchRootScreenPageSpec accepts a typed semantic page owner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CatchRootScreenScaffold.withPrimaryRail(
          header: CatchRootScreenHeader.title(title: 'Workspace'),
          primaryRail: _TestPrimaryRail(),
          body: CatchRootScreenBody.single(
            page: CatchRootScreenPageSpec.scroll(page: _TestPageOwner()),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(_TestPageOwner), findsOneWidget);
  });
}

Widget _wrap({
  CatchScreenBodyLayout bodyLayout = CatchScreenBodyLayout.standard,
  double contentHeight = 80,
  TextScaler textScaler = TextScaler.noScaling,
  bool useCanonicalRail = false,
}) {
  final slivers = <Widget>[
    SliverToBoxAdapter(
      child: SizedBox(
        key: const ValueKey('root-page-frame'),
        width: double.infinity,
        height: contentHeight,
        child: const SizedBox(
          key: ValueKey('root-page-content'),
          width: double.infinity,
        ),
      ),
    ),
  ];
  final page = switch (bodyLayout) {
    CatchScreenBodyLayout.standard => CatchRootScreenPageScrollView.standard(
      scrollKey: const PageStorageKey<String>('root-page-test'),
      slivers: slivers,
    ),
    CatchScreenBodyLayout.fullBleed => CatchRootScreenPageScrollView.fullBleed(
      scrollKey: const PageStorageKey<String>('root-page-test'),
      slivers: slivers,
    ),
  };
  return MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: CatchRootScreenScaffold.withPrimaryRail(
      header: const CatchRootScreenHeader.title(title: 'Workspace'),
      primaryRail: useCanonicalRail
          ? const CatchTabRail<int>(
              key: ValueKey('root-page-rail'),
              selected: 0,
              options: [CatchOption(value: 0, label: 'People')],
            )
          : const _TestPrimaryRail(key: ValueKey('root-page-rail')),
      body: CatchRootScreenBody.single(
        page: CatchRootScreenPageSpec.scroll(page: page),
      ),
    ),
  );
}

Widget _wrapEmbeddedViewport() {
  return MaterialApp(
    theme: AppTheme.light,
    home: const CatchRootScreenScaffold.withPrimaryRail(
      header: CatchRootScreenHeader.title(title: 'Workspace'),
      primaryRail: _TestPrimaryRail(),
      body: CatchRootScreenBody.single(
        page: CatchRootScreenPageSpec.scroll(
          page: CatchRootScreenPageScrollView.embeddedViewport(
            scrollKey: PageStorageKey<String>('root-page-embedded-test'),
            slivers: [SliverFillRemaining(child: SizedBox.shrink())],
          ),
        ),
      ),
    ),
  );
}

class _TestPrimaryRail extends StatelessWidget implements CatchPrimaryRail {
  const _TestPrimaryRail({super.key, this.height});

  final double? height;

  @override
  Size get preferredSize =>
      Size.fromHeight(height ?? CatchTabRail.minimumHeight);

  @override
  Widget build(BuildContext context) => SizedBox(height: preferredSize.height);
}

class _TestPageOwner extends StatelessWidget
    implements CatchRootScreenPageOwner {
  const _TestPageOwner();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
