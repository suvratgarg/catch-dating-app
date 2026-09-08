import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('derives navigation and message affordances from callbacks', (
    tester,
  ) async {
    var rowTaps = 0;
    var messageTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => CatchHostRow(
              colors: ActivityPalette.resolve(
                context,
                ActivityKind.socialRun,
              ).avatarColors,
              name: 'Jordan Ellis',
              meta: 'HOSTING SINCE MAY 2026 · VIJAY NAGAR',
              verified: true,
              onTap: () => rowTaps += 1,
              onMessage: () => messageTaps += 1,
              messageTooltip: 'Message Jordan Ellis',
            ),
          ),
        ),
      ),
    );

    final avatar = tester.widget<CatchAvatar>(find.byType(CatchAvatar));
    expect(avatar.size, CatchSpacing.s10);
    final colors = ActivityPalette.light.getActivity(ActivityKind.socialRun);
    expect(avatar.colors?.accent, colors.accent);
    expect(avatar.colors?.deep, colors.deep);
    expect(avatar.colors?.soft, colors.soft);
    expect(find.byIcon(CatchIcons.sealCheck), findsOneWidget);
    expect(find.byIcon(CatchIcons.chatBubbleOutlineRounded), findsOneWidget);
    expect(find.byIcon(CatchIcons.chevronRightRounded), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.chatBubbleOutlineRounded));
    await tester.pump();

    expect(messageTaps, 1);
    expect(rowTaps, 0);

    await tester.tap(find.text('Jordan Ellis'));
    await tester.pump();

    expect(rowTaps, 1);
    expect(messageTaps, 1);
  });

  testWidgets(
    'caller colors update avatar and verified mark without app theme',
    (tester) async {
      const firstColors = CatchAvatarColors(
        accent: Color(0xff9b2c77),
        deep: Color(0xff481f39),
        soft: Color(0xfff2d4e7),
      );
      const nextColors = CatchAvatarColors(
        accent: Color(0xff40b4d5),
        deep: Color(0xff163c49),
        soft: Color(0xffc4eef7),
      );
      for (final colors in [firstColors, nextColors]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: CatchTheme.light,
            home: Scaffold(
              body: CatchHostRow(
                colors: colors,
                name: 'Mira Shah',
                verified: true,
                onMessage: () {},
                messageTooltip: 'Écrire à Mira',
              ),
            ),
          ),
        );
        final avatar = tester.widget<CatchAvatar>(find.byType(CatchAvatar));
        expect(avatar.colors, same(colors));
        final mark = tester.widget<Icon>(find.byIcon(CatchIcons.sealCheck));
        expect(mark.color, colors.accent);
        expect(find.byTooltip('Écrire à Mira'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('omits interaction affordances when callbacks are absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => CatchHostRow(
              colors: ActivityPalette.resolve(
                context,
                ActivityKind.dinner,
              ).avatarColors,
              name: 'Mira Shah',
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.chatBubbleOutlineRounded), findsNothing);
    expect(find.byIcon(CatchIcons.chevronRightRounded), findsNothing);
    expect(find.byIcon(CatchIcons.sealCheck), findsNothing);
  });
}
