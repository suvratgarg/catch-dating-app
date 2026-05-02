import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: () => actionTaps++,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(IconBtn), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();
    expect(backTaps, 1);

    await tester.tap(find.byIcon(Icons.settings_outlined));
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

  testWidgets('CatchTopBar can render an icon-only onboarding bar', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CatchTopBar(showBackButton: true)));

    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
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
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit profile')),
                    PopupMenuItem(value: 'signOut', child: Text('Sign out')),
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

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    expect(selected, 'edit');
  });
}

Widget _wrap(PreferredSizeWidget appBar) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(appBar: appBar, body: const SizedBox.shrink()),
  );
}
