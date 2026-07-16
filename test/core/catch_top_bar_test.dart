import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  test('root screen title geometry has no post-safe-area top inset', () {
    expect(CatchInsets.screenTitleBlock.top, 0);
    expect(CatchInsets.screenTitleBlockCompact, CatchInsets.screenTitleBlock);
  });

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
    expect(
      tester.widget<Text>(find.text('Settings')).style,
      CatchTextStyles.titleL(
        tester.element(find.text('Settings')),
        color: CatchTokens.of(tester.element(find.text('Settings'))).ink,
      ),
    );
    expect(find.byType(CatchIconButton), findsNothing);
    expect(
      _topBarMaterial(tester).color,
      AppTheme.light.scaffoldBackgroundColor,
    );
  });

  testWidgets('CatchScreenTopBar uses the root screen headline voice', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapScreenTopBar(
        (context) => CatchScreenTopBar(
          context: context,
          title: 'Activity',
          subtitle: 'Notifications',
        ),
      ),
    );

    final titleContext = tester.element(find.text('Activity'));
    expect(find.byType(CatchScreenTopBar), findsOneWidget);
    expect(tester.getSize(find.byType(CatchTopBar)).height, 88);
    expect(
      tester.widget<Text>(find.text('Activity')).style,
      CatchTextStyles.headline(
        titleContext,
        color: CatchTokens.of(titleContext).ink,
      ),
    );
    expect(find.text('Notifications'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Activity')).dy, 0);
  });

  testWidgets('CatchScreenTopBar inherits the accessible text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapScreenTopBar(
        (context) => CatchScreenTopBar(context: context, title: 'Chats'),
        textScale: 2,
      ),
    );

    final titleContext = tester.element(find.text('Chats'));
    expect(MediaQuery.textScalerOf(titleContext).scale(1), 2);
    expect(
      tester.getSize(find.byType(CatchTopBar)).height,
      greaterThan(CatchLayout.topBarHeight),
    );
  });

  testWidgets('CatchScreenHeaderTitle supports reviewed two-line titles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CatchScreenHeaderTitle.block(
            title: 'Good evening, Mira',
            titleMaxLines: 2,
          ),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('Good evening, Mira')).maxLines, 2);
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
            CatchIconAction(
              icon: CatchIcons.settingsOutlined,
              tooltip: 'Settings',
              onPressed: () => actionTaps++,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CatchIconButton), findsNWidgets(2));

    await tester.tap(find.byIcon(CatchIcons.arrowBackIosNewRounded));
    await tester.pump();
    expect(backTaps, 1);

    await tester.tap(find.byIcon(CatchIcons.settingsOutlined));
    await tester.pump();
    expect(actionTaps, 1);
  });

  testWidgets('CatchTopBarActionGroup owns peer gaps and trailing gutter', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _wrap(
        CatchTopBar(
          title: 'Home',
          showBackButton: false,
          actions: [
            CatchIconAction(
              key: const ValueKey('top-action-share'),
              icon: CatchIcons.share,
              tooltip: 'Share',
              onPressed: () {},
            ),
            CatchIconAction(
              key: const ValueKey('top-action-save'),
              icon: CatchIcons.savedOutlined,
              tooltip: 'Save',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    final first = tester.getRect(
      find.byKey(const ValueKey('top-action-share')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey('top-action-save')),
    );
    expect(second.left - first.right, CatchSpacing.s2);
    expect(390 - second.right, CatchSpacing.screenPx);
    expect(find.byType(CatchTopBarActionGroup), findsOneWidget);
  });

  testWidgets('CatchScreenHeaderTitle uses the same action group', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 390,
            child: CatchScreenHeaderTitle(
              title: 'Your profile',
              actions: [
                SizedBox.square(
                  key: ValueKey('header-action-one'),
                  dimension: 40,
                ),
                SizedBox.square(
                  key: ValueKey('header-action-two'),
                  dimension: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final first = tester.getRect(
      find.byKey(const ValueKey('header-action-one')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey('header-action-two')),
    );
    expect(second.left - first.right, CatchSpacing.s2);
  });

  testWidgets('CatchIconAction uses the shared app-bar nav extent by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: CatchIconAction(
              icon: CatchIcons.settingsOutlined,
              tooltip: 'Settings',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CatchIconButton)),
      const Size.square(CatchIconButton.navSize),
    );
    expect(
      tester.widget<Icon>(find.byIcon(CatchIcons.settingsOutlined)).size,
      CatchIcon.md,
    );
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

  testWidgets('CatchTopBar constrains text actions at large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithTextScale(
        CatchTopBar(
          title: 'Activity',
          showBackButton: false,
          actions: [
            CatchTopBarTextAction(label: 'Mark all read', onPressed: () {}),
          ],
        ),
        textScale: 2,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
  });

  testWidgets('CatchTopBar constrains compact subtitle at large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithTextScale(
        const CatchTopBar(
          title: 'Professional profile',
          subtitle: 'Active professional profile',
          showBackButton: false,
        ),
        textScale: 2,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Professional profile'), findsOneWidget);
    expect(find.text('Active professional profile'), findsNothing);
  });

  testWidgets('CatchTopBar constrains large subtitle at large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithTextScale(
        const CatchTopBar(
          title: 'Create event',
          subtitle: 'Add the details guests need before they book',
          kicker: 'Host event',
          showBackButton: false,
        ),
        textScale: 2,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('HOST EVENT'), findsNothing);
    expect(find.text('Create event'), findsOneWidget);
    expect(
      find.text('Add the details guests need before they book'),
      findsNothing,
    );
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
    expect(_topBarMaterial(tester).color, CatchTokens.editorialLight.surface);
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

    expect(find.text('Clubs'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CatchSearchField &&
            widget.mode == CatchSearchFieldMode.expanding,
      ),
      findsOneWidget,
    );
    await tester.pump(CatchMotion.base);
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
    expect(find.byType(CatchIconButton), findsOneWidget);
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

Widget _wrapWithTextScale(
  PreferredSizeWidget appBar, {
  required double textScale,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Center(
        child: SizedBox(
          width: 390,
          height: 812,
          child: Scaffold(appBar: appBar, body: const SizedBox.shrink()),
        ),
      ),
    ),
  );
}

Widget _wrapScreenTopBar(
  PreferredSizeWidget Function(BuildContext context) appBarBuilder, {
  double? textScale,
}) {
  Widget home = Builder(
    builder: (context) =>
        Scaffold(appBar: appBarBuilder(context), body: const SizedBox.shrink()),
  );
  if (textScale != null) {
    home = MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Center(child: SizedBox(width: 390, height: 812, child: home)),
    );
  }
  return MaterialApp(theme: AppTheme.light, home: home);
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
