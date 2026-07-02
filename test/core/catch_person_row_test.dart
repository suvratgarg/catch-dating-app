import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a tappable chat preview row', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Taylor',
              lastMessage: 'You matched!',
              timestamp: '2m',
              isFresh: true,
              showFreshDot: true,
            ),
            showFreshBackground: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('You matched!'), findsOneWidget);
    expect(find.byType(CatchPersonAvatar), findsOneWidget);
    expect(find.byType(CatchPersonChatLayout), findsOneWidget);
    expect(find.byType(CatchPersonChatTrailing), findsOneWidget);
    expect(find.byType(CatchPersonNewMatchDot), findsOneWidget);
    expect(
      tester
          .widget<CatchPersonAvatar>(find.byType(CatchPersonAvatar))
          .borderWidth,
      CatchStroke.underline,
    );

    await tester.tap(find.byType(CatchPersonRow));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('uses row-level unread treatment instead of avatar badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Taylor',
              lastMessage: 'See you at the event',
              timestamp: '2m',
              unreadCount: 1,
              isFresh: true,
            ),
            showFreshBackground: false,
            onTap: () {},
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    final context = tester.element(find.byType(CatchPersonRow));
    final tokens = CatchTokens.of(context);
    final avatar = tester.widget<CatchPersonAvatar>(
      find.byType(CatchPersonAvatar),
    );

    expect(avatar.borderWidth, CatchStroke.underline);
    expect(avatar.borderColor, tokens.primary);
    expect(find.byType(CatchPersonChatLayout), findsOneWidget);
    expect(find.byType(CatchPersonChatTrailing), findsOneWidget);
    expect(find.byType(CatchPersonUnreadCountPill), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Unread chat',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders roster layout when no chat preview is supplied', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CatchPersonRow(
            data: CatchPersonRowData(
              name: 'Taylor',
              metaLine: '5:20 /km',
              contextLine: 'Sundowner 5K',
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.byType(CatchPersonRosterLayout), findsOneWidget);
    expect(find.byType(CatchPersonChatLayout), findsNothing);
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('5:20 /km'), findsOneWidget);
    expect(find.text('Sundowner 5K'), findsOneWidget);
  });
}
