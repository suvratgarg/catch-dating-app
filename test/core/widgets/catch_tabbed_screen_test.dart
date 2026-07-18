import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
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
        CatchLayout.maxContentWidth + CatchInsets.pageBody.horizontal,
      );
      final contentRect = tester.getRect(
        find.byKey(const ValueKey('tabbed-page-content')),
      );
      expect(contentRect.width, CatchLayout.maxContentWidth);
      expect(contentRect.left, (1000 - CatchLayout.maxContentWidth) / 2);
    },
  );

  testWidgets(
    'CatchTabbedPageScrollView leaves sliver-native pages full bleed by default',
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
        1000,
      );
    },
  );
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
        constrainToContentWidth: constrainToContentWidth,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              key: const ValueKey('tabbed-page-frame'),
              width: double.infinity,
              height: 80,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: CatchInsets.pageBody.left,
                ),
                child: const SizedBox(
                  key: ValueKey('tabbed-page-content'),
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
