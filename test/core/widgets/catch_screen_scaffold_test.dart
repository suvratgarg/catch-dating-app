import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('root screen owns standard title-to-body geometry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _rootScreen(bodyLayout: CatchScreenBodyLayout.standard),
    );

    final header = tester.getRect(find.byKey(const ValueKey('root-header')));
    final body = tester.getRect(find.byKey(const ValueKey('root-body')));
    expect(body.top - header.bottom, CatchInsets.pageBody.top);
    expect(body.left, CatchInsets.pageBody.left);
    expect(body.width, 400 - CatchInsets.pageBody.horizontal);
    expect(find.byType(CatchSliverTerminalPadding), findsOneWidget);
  });

  testWidgets('root full-bleed body delegates no local page inset', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _rootScreen(bodyLayout: CatchScreenBodyLayout.fullBleed),
    );

    final header = tester.getRect(find.byKey(const ValueKey('root-header')));
    final body = tester.getRect(find.byKey(const ValueKey('root-body')));
    expect(body.top, header.bottom);
    expect(body.left, 0);
    expect(body.width, 400);
  });

  testWidgets('root standard body clamps and centers its responsive lane', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _rootScreen(bodyLayout: CatchScreenBodyLayout.standard),
    );

    final body = tester.getRect(find.byKey(const ValueKey('root-body')));
    expect(body.width, CatchLayout.maxContentWidth);
    expect(body.left, (1000 - CatchLayout.maxContentWidth) / 2);
  });

  testWidgets('root top edge has one explicit safe-area owner', (tester) async {
    await tester.pumpWidget(
      _rootScreen(
        bodyLayout: CatchScreenBodyLayout.standard,
        topEdge: CatchRootScreenTopEdge.headerOwned,
      ),
    );

    final safeArea = tester.widget<SafeArea>(
      find.descendant(
        of: find.byType(CatchRootScreenScrollView),
        matching: find.byType(SafeArea),
      ),
    );
    expect(safeArea.top, isFalse);
    expect(safeArea.bottom, isFalse);
  });

  testWidgets('screen surface constructors make safe-area policy explicit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CatchScreenScaffold.stepFlow(
          safeArea: CatchScreenSafeArea.top,
          body: SizedBox(key: ValueKey('step-body')),
        ),
      ),
    );

    final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
    expect(safeArea.top, isTrue);
    expect(safeArea.bottom, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CatchScreenScaffold.workspace(
          body: SizedBox(key: ValueKey('workspace-body')),
        ),
      ),
    );
    expect(find.byType(SafeArea), findsNothing);
  });

  testWidgets('pushed route standard body owns exact 20 by 24 geometry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CatchRouteScaffold(
          topBarBuilder: (_, _) => const PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: SizedBox(key: ValueKey('route-top-bar'), height: 56),
          ),
          body: const CatchRouteBody.standard(
            child: SizedBox(
              key: ValueKey('route-standard-content'),
              width: double.infinity,
              height: 40,
            ),
          ),
        ),
      ),
    );

    final topBar = tester.getRect(find.byKey(const ValueKey('route-top-bar')));
    final body = tester.getRect(
      find.byKey(const ValueKey('route-standard-content')),
    );
    expect(body.top - topBar.bottom, CatchInsets.pageBody.top);
    expect(body.left, CatchInsets.pageBody.left);
    expect(body.width, 400 - CatchInsets.pageBody.horizontal);
  });

  testWidgets('pushed route viewport body cannot acquire a scroll owner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CatchRouteScaffold(
          topBarBuilder: (_, _) => const PreferredSize(
            preferredSize: Size.zero,
            child: SizedBox.shrink(),
          ),
          body: const CatchRouteBody.standardViewport(
            child: SizedBox(key: ValueKey('route-viewport-content')),
          ),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      tester.widget<CatchScreenBody>(find.byType(CatchScreenBody)).scrollable,
      isFalse,
    );
  });

  testWidgets('pushed constrained body owns one centered responsive lane', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CatchRouteScaffold(
          topBarBuilder: (_, _) => const PreferredSize(
            preferredSize: Size.zero,
            child: SizedBox.shrink(),
          ),
          body: const CatchRouteBody.standardConstrained(
            child: SizedBox(
              key: ValueKey('route-constrained-content'),
              width: double.infinity,
              height: 40,
            ),
          ),
        ),
      ),
    );

    final content = tester.getRect(
      find.byKey(const ValueKey('route-constrained-content')),
    );
    expect(content.width, CatchLayout.maxContentWidth);
    expect(content.center.dx, 500);
  });

  testWidgets('sliver route publishes floating shell obstruction to fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShellActiveTab(
          index: 0,
          bottomBarPlacement: AppShellBottomBarPlacement.floating,
          bottomOverlayInset: 96,
          child: CatchRouteScaffold(
            topBarBuilder: (_, _) => const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox.shrink(),
            ),
            body: const CatchRouteBody.standardSlivers(
              slivers: [SliverToBoxAdapter(child: SizedBox.shrink())],
            ),
          ),
        ),
      ),
    );

    final scope = tester.widget<CatchFieldVisibilityScope>(
      find.byType(CatchFieldVisibilityScope),
    );
    expect(scope.bottomObstruction, 96);
  });

  testWidgets(
    'standalone route standard body reserves device safe bottom plus 20',
    (tester) async {
      await tester.pumpWidget(_standardRouteWithBottomGeometry(safeBottom: 34));

      expect(
        tester.widget<CatchScreenBody>(find.byType(CatchScreenBody)).pb,
        34 + CatchSpacing.screenPb,
      );
    },
  );

  testWidgets(
    'floating shell route uses published overlay once for bottom clearance',
    (tester) async {
      await tester.pumpWidget(
        _standardRouteWithBottomGeometry(
          safeBottom: 34,
          bottomBarPlacement: AppShellBottomBarPlacement.floating,
          bottomOverlayInset: 100,
        ),
      );

      expect(
        tester.widget<CatchScreenBody>(find.byType(CatchScreenBody)).pb,
        100 + CatchSpacing.screenPb,
      );
    },
  );

  testWidgets(
    'anchored shell route does not double-count bottom space outside viewport',
    (tester) async {
      await tester.pumpWidget(
        _standardRouteWithBottomGeometry(
          safeBottom: 34,
          bottomBarPlacement: AppShellBottomBarPlacement.anchored,
          bottomOverlayInset: 100,
        ),
      );

      expect(
        tester.widget<CatchScreenBody>(find.byType(CatchScreenBody)).pb,
        CatchSpacing.screenPb,
      );
    },
  );

  testWidgets('pushed route full bleed delegates no page inset', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CatchRouteScaffold(
          topBarBuilder: (_, _) => const PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: SizedBox(key: ValueKey('route-top-bar'), height: 56),
          ),
          body: const CatchRouteBody.fullBleed(
            child: SizedBox(
              key: ValueKey('route-full-bleed-content'),
              width: double.infinity,
              height: 40,
            ),
          ),
        ),
      ),
    );

    final topBar = tester.getRect(find.byKey(const ValueKey('route-top-bar')));
    final body = tester.getRect(
      find.byKey(const ValueKey('route-full-bleed-content')),
    );
    expect(body.top, topBar.bottom);
    expect(body.left, 0);
    expect(body.width, 400);
  });
}

Widget _standardRouteWithBottomGeometry({
  required double safeBottom,
  AppShellBottomBarPlacement? bottomBarPlacement,
  double bottomOverlayInset = 0,
}) {
  Widget route = CatchRouteScaffold(
    topBarBuilder: (_, _) =>
        const PreferredSize(preferredSize: Size.zero, child: SizedBox.shrink()),
    body: const CatchRouteBody.standard(child: SizedBox(height: 40)),
  );
  if (bottomBarPlacement != null) {
    route = AppShellActiveTab(
      index: 0,
      bottomBarPlacement: bottomBarPlacement,
      bottomOverlayInset: bottomOverlayInset,
      child: route,
    );
  }

  return MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        padding: EdgeInsets.only(bottom: safeBottom),
        viewPadding: EdgeInsets.only(bottom: safeBottom),
      ),
      child: route,
    ),
  );
}

Widget _rootScreen({
  required CatchScreenBodyLayout bodyLayout,
  CatchRootScreenTopEdge topEdge = CatchRootScreenTopEdge.safeArea,
}) {
  const header = SizedBox(
    key: ValueKey('root-header'),
    width: double.infinity,
    height: 80,
  );
  const slivers = <Widget>[
    SliverToBoxAdapter(
      child: SizedBox(
        key: ValueKey('root-body'),
        width: double.infinity,
        height: 40,
      ),
    ),
  ];
  final root = switch (bodyLayout) {
    CatchScreenBodyLayout.standard => CatchRootScreenScaffold.standard(
      header: header,
      topEdge: topEdge,
      slivers: slivers,
    ),
    CatchScreenBodyLayout.fullBleed => CatchRootScreenScaffold.fullBleed(
      header: header,
      topEdge: topEdge,
      slivers: slivers,
    ),
  };
  return MaterialApp(
    theme: AppTheme.light,
    home: AppShellActiveTab(
      index: 0,
      bottomBarPlacement: AppShellBottomBarPlacement.floating,
      bottomOverlayInset: 100,
      child: root,
    ),
  );
}
