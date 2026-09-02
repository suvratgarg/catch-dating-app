import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CatchTabbedPageScrollView centers opted-in slivers at content width',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(constrainToContentWidth: true));
      await tester.pump();

      expect(find.byType(SliverCrossAxisGroup), findsOneWidget);
      expect(find.byType(SliverConstrainedCrossAxis), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('tabbed-page-frame'))).width,
        CatchLayout.maxContentWidth,
      );
      final contentRect = tester.getRect(
        find.byKey(const ValueKey('tabbed-page-content')),
      );
      expect(contentRect.width, CatchLayout.maxContentWidth);
      expect(contentRect.left, (1000 - CatchLayout.maxContentWidth) / 2);
    },
  );

  testWidgets(
    'CatchTabbedPageScrollView keeps standard gutters without a width clamp',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(constrainToContentWidth: false));
      await tester.pump();

      expect(find.byType(SliverCrossAxisGroup), findsNothing);
      expect(find.byType(SliverConstrainedCrossAxis), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('tabbed-page-frame'))).width,
        1000 - CatchInsets.pageBody.horizontal,
      );
    },
  );

  testWidgets('CatchTabbedPageScrollView resolves semantic top rhythm', (
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
      await tester.pumpWidget(
        _wrap(constrainToContentWidth: false, bodyLayout: layout),
      );
      await tester.pump();

      final rail = tester.getRect(
        find.byKey(const ValueKey('tabbed-page-rail')),
      );
      final body = tester.getRect(
        find.byKey(const ValueKey('tabbed-page-frame')),
      );
      expect(
        body.top - rail.bottom,
        closeTo(expectedTop, 0.001),
        reason: '$layout must own its exact tab-to-body relationship.',
      );
    }
  });

  testWidgets('tab page publishes the shell obstruction to expanding fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppShellActiveTab(
        index: 0,
        bottomBarPlacement: AppShellBottomBarPlacement.floating,
        bottomOverlayInset: 96,
        child: _wrap(constrainToContentWidth: false),
      ),
    );

    final scope = tester.widget<CatchFieldVisibilityScope>(
      find.byType(CatchFieldVisibilityScope),
    );
    expect(scope.bottomObstruction, 96);
  });

  test('tabbed screen geometry uses the approved compact rail rhythm', () {
    expect(CatchInsets.tabbedScreenTitleBlock.bottom, CatchSpacing.s1);
    expect(CatchLayout.tabRailHeight, 44);
    expect(CatchInsets.pageBody.top, 24);
  });

  testWidgets(
    'CatchTabbedScreenScaffold gives search the compact tabbed title band',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const CatchTabbedScreenScaffold(
            title: 'Forms',
            search: CatchTopBarSearch(
              placeholder: 'Search forms',
              tooltip: 'Search forms',
            ),
            tabRail: PreferredSize(
              preferredSize: Size.fromHeight(CatchLayout.tabRailHeight),
              child: SizedBox(height: CatchLayout.tabRailHeight),
            ),
            body: CatchTabbedScreenBody.single(
              page: CatchTabbedPageSpec.scroll(
                bodyLayout: CatchScreenBodyLayout.standard,
                page: CatchTabbedPageScrollView(
                  scrollKey: PageStorageKey('search-tabbed-page'),
                  bodyLayout: CatchScreenBodyLayout.standard,
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
          CatchIconButton.navSize + CatchInsets.tabbedScreenTitleBlock.vertical;
      expect(titleBar.contentPadding, CatchInsets.tabbedScreenTitleBlock);
      expect(titleBar.applySafeArea, isFalse);
      expect(titleBar.leadingType, CatchTopBarLeading.none);
      expect(titleBar.height, expectedContentHeight);
      expect(titleBar.height, lessThan(CatchLayout.topBarHeight));

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
    'CatchTabbedScreenScaffold rejects noncanonical tab rail heights',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const CatchTabbedScreenScaffold(
            title: 'Workspace',
            tabRail: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: SizedBox(height: 48),
            ),
            body: CatchTabbedScreenBody.single(
              page: CatchTabbedPageSpec.scroll(
                bodyLayout: CatchScreenBodyLayout.standard,
                page: CatchTabbedPageScrollView(
                  scrollKey: PageStorageKey('invalid-rail-tabbed-page'),
                  bodyLayout: CatchScreenBodyLayout.standard,
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
          'CatchTabbedScreenScaffold requires a '
          '${CatchLayout.tabRailHeight}-point tab rail.',
        ),
      );
      expect(error.toString(), contains('declared a preferred height of 48.0'));
      expect(
        error.toString(),
        contains('screens must not define local tab-rail geometry'),
      );
    },
  );

  testWidgets('CatchTabbedPageSpec rejects a page-owner role mismatch', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CatchTabbedScreenScaffold(
          title: 'Workspace',
          tabRail: PreferredSize(
            preferredSize: Size.fromHeight(CatchLayout.tabRailHeight),
            child: SizedBox(height: CatchLayout.tabRailHeight),
          ),
          body: CatchTabbedScreenBody.single(
            page: CatchTabbedPageSpec.scroll(
              bodyLayout: CatchScreenBodyLayout.standard,
              page: _FullBleedPageOwner(),
            ),
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('disagree on body geometry'));
    expect(error.toString(), contains('CatchScreenBodyLayout.fullBleed'));
    expect(error.toString(), contains('CatchScreenBodyLayout.standard'));
  });
}

Widget _wrap({
  required bool constrainToContentWidth,
  CatchScreenBodyLayout bodyLayout = CatchScreenBodyLayout.standard,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: CatchTabbedScreenScaffold(
      title: 'Workspace',
      tabRail: const PreferredSize(
        preferredSize: Size.fromHeight(CatchLayout.tabRailHeight),
        child: SizedBox(
          key: ValueKey('tabbed-page-rail'),
          height: CatchLayout.tabRailHeight,
        ),
      ),
      body: CatchTabbedScreenBody.single(
        page: CatchTabbedPageSpec.scroll(
          bodyLayout: bodyLayout,
          page: CatchTabbedPageScrollView(
            scrollKey: const PageStorageKey<String>('tabbed-page-test'),
            bodyLayout: bodyLayout,
            constrainToContentWidth: constrainToContentWidth,
            slivers: const [
              SliverToBoxAdapter(
                child: SizedBox(
                  key: ValueKey('tabbed-page-frame'),
                  width: double.infinity,
                  height: 80,
                  child: SizedBox(
                    key: ValueKey('tabbed-page-content'),
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FullBleedPageOwner extends StatelessWidget
    implements CatchTabbedPageOwner {
  const _FullBleedPageOwner();

  @override
  CatchScreenBodyLayout get bodyLayout => CatchScreenBodyLayout.fullBleed;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
