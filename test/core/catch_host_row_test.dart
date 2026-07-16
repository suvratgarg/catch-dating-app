import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_host_row.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
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
          body: CatchHostRow(
            activityKind: ActivityKind.socialRun,
            name: 'Jordan Ellis',
            meta: 'HOSTING SINCE MAY 2026 · VIJAY NAGAR',
            verified: true,
            onTap: () => rowTaps += 1,
            onMessage: () => messageTaps += 1,
            messageTooltip: 'Message Jordan Ellis',
          ),
        ),
      ),
    );

    final avatar = tester.widget<CatchPersonAvatar>(
      find.byType(CatchPersonAvatar),
    );
    expect(avatar.size, CatchSpacing.s10);
    expect(avatar.activityKind, ActivityKind.socialRun);
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

  testWidgets('omits interaction affordances when callbacks are absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: const CatchHostRow(
            activityKind: ActivityKind.dinner,
            name: 'Mira Shah',
          ),
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.chatBubbleOutlineRounded), findsNothing);
    expect(find.byIcon(CatchIcons.chevronRightRounded), findsNothing);
    expect(find.byIcon(CatchIcons.sealCheck), findsNothing);
  });
}
