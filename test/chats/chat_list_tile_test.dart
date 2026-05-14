import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a tappable thread preview row', (tester) async {
    var tapped = false;
    final match = Match(
      id: 'match-1',
      user1Id: 'runner-1',
      user2Id: 'runner-2',
      runIds: const ['run-1'],
      createdAt: DateTime(2026, 4, 23, 9),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ChatListTile(
            preview: ChatThreadPreview(
              match: match,
              matchId: match.id,
              otherUid: 'runner-2',
              displayName: 'Taylor',
              photoUrl: null,
              previewText: 'You matched!',
              timestamp: match.createdAt,
              unreadCount: 0,
              hasConversation: false,
              runIds: match.runIds,
            ),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.byType(CatchSurface), findsOneWidget);
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('You matched!'), findsOneWidget);

    await tester.tap(find.byType(CatchSurface));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('uses row-level unread treatment instead of tiny avatar badge', (
    tester,
  ) async {
    final match = Match(
      id: 'match-1',
      user1Id: 'runner-1',
      user2Id: 'runner-2',
      runIds: const ['run-1'],
      createdAt: DateTime(2026, 4, 23, 9),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ChatListTile(
            preview: ChatThreadPreview(
              match: match,
              matchId: match.id,
              otherUid: 'runner-2',
              displayName: 'Taylor',
              photoUrl: null,
              previewText: 'See you at the run',
              timestamp: match.createdAt,
              unreadCount: 1,
              hasConversation: true,
              runIds: match.runIds,
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    final context = tester.element(find.byType(ChatListTile));
    final tokens = CatchTokens.of(context);
    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    final avatar = tester.widget<PersonAvatar>(find.byType(PersonAvatar));

    expect(surface.backgroundColor, tokens.primarySoft);
    expect(surface.borderColor, tokens.primary.withValues(alpha: 0.36));
    expect(avatar.borderWidth, 2);
    expect(avatar.borderColor, tokens.primary);
    expect(find.text('1'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Unread chat',
      ),
      findsOneWidget,
    );
  });
}
