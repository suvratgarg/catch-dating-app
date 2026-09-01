import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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

  testWidgets('CatchTabbedScreenScaffold composes expanding header search', (
    tester,
  ) async {
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
            preferredSize: Size.fromHeight(1),
            child: SizedBox(height: 1),
          ),
          body: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Forms'), findsOneWidget);
    expect(find.byType(CatchScreenTopBar), findsOneWidget);
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
  });
}

Widget _wrap({required bool constrainToContentWidth}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: CatchTabbedScreenScaffold(
      title: 'Workspace',
      tabRail: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: SizedBox(height: 1),
      ),
      body: CatchTabbedPageScrollView(
        scrollKey: const PageStorageKey<String>('tabbed-page-test'),
        bodyLayout: CatchScreenBodyLayout.standard,
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
  );
}
