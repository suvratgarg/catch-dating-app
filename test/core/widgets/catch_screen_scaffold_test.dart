import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
      _rootScreen(
        bodyLayout: CatchScreenBodyLayout.standard,
        constrainToContentWidth: true,
      ),
    );

    final body = tester.getRect(find.byKey(const ValueKey('root-body')));
    expect(body.width, CatchLayout.maxContentWidth);
    expect(body.left, (1000 - CatchLayout.maxContentWidth) / 2);
  });
}

Widget _rootScreen({
  required CatchScreenBodyLayout bodyLayout,
  bool constrainToContentWidth = false,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: AppShellActiveTab(
      index: 0,
      bottomBarPlacement: AppShellBottomBarPlacement.floating,
      bottomOverlayInset: 100,
      child: CatchRootScreenScaffold(
        header: const SizedBox(
          key: ValueKey('root-header'),
          width: double.infinity,
          height: 80,
        ),
        bodyLayout: bodyLayout,
        constrainToContentWidth: constrainToContentWidth,
        slivers: const [
          SliverToBoxAdapter(
            child: SizedBox(
              key: ValueKey('root-body'),
              width: double.infinity,
              height: 40,
            ),
          ),
        ],
      ),
    ),
  );
}
