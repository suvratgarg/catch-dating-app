import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('CatchTopBar renders the handoff-sized title row', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchTopBar(
          title: 'Settings',
          showBackButton: false,
          border: true,
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(tester.getSize(find.byType(CatchTopBar)).height, 56);
    expect(find.byType(IconBtn), findsNothing);
    expect(
      _topBarMaterial(tester).color,
      AppTheme.light.scaffoldBackgroundColor,
    );
  });

  testWidgets('CatchTopBar wires leading and action controls', (tester) async {
    var backTaps = 0;
    var actionTaps = 0;

    await tester.pumpWidget(
      _wrap(
        CatchTopBar(
          title: 'Profile',
          showBackButton: true,
          onBack: () => backTaps++,
          actions: [
            CatchTopBarIconAction(
              icon: CatchIcons.settingsOutlined,
              tooltip: 'Settings',
              onPressed: () => actionTaps++,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(IconBtn), findsNWidgets(2));

    await tester.tap(find.byIcon(CatchIcons.arrowBackIosNewRounded));
    await tester.pump();
    expect(backTaps, 1);

    await tester.tap(find.byIcon(CatchIcons.settingsOutlined));
    await tester.pump();
    expect(actionTaps, 1);
  });

  testWidgets('CatchTopBar supports custom title widgets and text actions', (
    tester,
  ) async {
    var saved = false;

    await tester.pumpWidget(
      _wrap(
        CatchTopBar(
          titleWidget: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 12, child: Text('A')),
              SizedBox(width: 8),
              Text('Aarav'),
            ],
          ),
          showBackButton: false,
          actions: [
            CatchTopBarTextAction(label: 'Save', onPressed: () => saved = true),
          ],
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Aarav'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saved, isTrue);
  });

  testWidgets('CatchTopBar renders the large handoff AppBar header', (
    tester,
  ) async {
    var closed = false;
    var done = false;

    await tester.pumpWidget(
      _wrap(
        CatchTopBar(
          title: 'Discover',
          subtitle: 'Tonight near you',
          kicker: 'Explore',
          leadingType: CatchTopBarLeading.close,
          onBack: () => closed = true,
          actionText: 'Done',
          onAction: () => done = true,
          surface: true,
        ),
      ),
    );

    expect(tester.getSize(find.byType(CatchTopBar)).height, 104);
    expect(find.text('EXPLORE'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Tonight near you'), findsOneWidget);
    expect(_topBarMaterial(tester).color, CatchTokens.sunsetLight.surface);
    expect(find.byIcon(CatchIcons.close), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.close));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pump();

    expect(closed, isTrue);
    expect(done, isTrue);
  });

  testWidgets('CatchTopBar composes expanding search from the AppBar API', (
    tester,
  ) async {
    var query = 'tempo';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            appBar: CatchTopBar(
              title: 'Clubs',
              searchValue: query,
              onSearch: (value) => setState(() => query = value),
              searchPlaceholder: 'Search clubs',
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.text('Clubs'), findsOneWidget);
    expect(find.byIcon(CatchIcons.search), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.search));
    await tester.pump();

    expect(find.text('Clubs'), findsNothing);
    expect(find.byType(CatchSearchField), findsOneWidget);
    expect(find.byIcon(CatchIcons.clearCircle), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.clearCircle));
    await tester.pump();
    expect(query, isEmpty);
    expect(find.byIcon(CatchIcons.close), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.close));
    await tester.pump();
    expect(find.text('Clubs'), findsOneWidget);
  });

  testWidgets('CatchTopBar can render an icon-only onboarding bar', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CatchTopBar(showBackButton: true)));

    expect(find.byIcon(CatchIcons.arrowBackIosNewRounded), findsOneWidget);
    expect(find.byType(IconBtn), findsOneWidget);
  });

  testWidgets('CatchTopBar supports tab bottoms and overflow menus', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: CatchTopBar(
              title: 'Profile',
              showBackButton: false,
              bottom: const CatchTopBarTabBar(
                tabs: [
                  Tab(text: 'Profile'),
                  Tab(text: 'Preview'),
                ],
              ),
              actions: [
                CatchTopBarMenuAction<String>(
                  tooltip: 'More profile actions',
                  onSelected: (value) => selected = value,
                  items: const [
                    CatchActionMenuItem(value: 'edit', label: 'Edit profile'),
                    CatchActionMenuItem(
                      value: 'signOut',
                      label: 'Sign out',
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(CatchTopBar)).height, 104);
    expect(find.text('Profile'), findsNWidgets(2));
    expect(find.text('Preview'), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.moreHorizRounded));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Edit profile'));
    await pumpFeatureUi(tester);

    expect(selected, 'edit');
  });

  testWidgets('CatchSliverHeader naturally sizes title above pinned bottom', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                ...const CatchSliverHeader(
                  bottomHeight: 48,
                  title: Padding(
                    key: ValueKey('natural-sliver-title'),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sticky title'),
                        SizedBox(height: 12),
                        Text('Subtitle'),
                      ],
                    ),
                  ),
                  bottom: ColoredBox(
                    key: ValueKey('pinned-sliver-bottom'),
                    color: Colors.white,
                    child: Center(child: Text('Pinned bottom')),
                  ),
                ).buildSlivers(context),
                const SliverToBoxAdapter(child: SizedBox(height: 400)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    final initialTitleTop = tester.getTopLeft(find.text('Sticky title')).dy;
    final initialBottomTop = tester
        .getTopLeft(find.byKey(const ValueKey('pinned-sliver-bottom')))
        .dy;
    final initialTitleBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('natural-sliver-title')))
        .dy;

    expect(initialBottomTop, greaterThanOrEqualTo(initialTitleBottom));
    expect(initialBottomTop - initialTitleBottom, lessThanOrEqualTo(1));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -48));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Sticky title')).dy,
      lessThan(initialTitleTop),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('pinned-sliver-bottom'))).dy,
      lessThan(initialBottomTop),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
    await tester.pump();

    expect(
      tester.getBottomLeft(find.text('Sticky title')).dy,
      lessThan(tester.getTopLeft(find.text('Pinned bottom')).dy),
    );
    expect(find.text('Pinned bottom').hitTestable(), findsOneWidget);
  });
}

Widget _wrap(PreferredSizeWidget appBar) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(appBar: appBar, body: const SizedBox.shrink()),
  );
}

Material _topBarMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find
        .descendant(
          of: find.byType(CatchTopBar),
          matching: find.byType(Material),
        )
        .first,
  );
}
