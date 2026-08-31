import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected conversation owns a visible semantic row state', (
    tester,
  ) async {
    final selected = _preview('selected', 'Selected guest');
    final other = _preview('other', 'Other guest');
    ChatThreadPreview? tapped;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              ChatConversationsList(
                matches: [selected, other],
                selectedMatchId: selected.matchId,
                onThreadSelected: (preview) => tapped = preview,
              ),
            ],
          ),
        ),
      ),
    );

    final selectedSemantics = find.byKey(
      const ValueKey<String>('chat-conversation-selected-match-selected'),
    );
    expect(selectedSemantics, findsOneWidget);
    expect(
      tester.widget<Semantics>(selectedSemantics).properties.selected,
      true,
    );
    expect(
      find.byKey(
        const ValueKey<String>('chat-conversation-selected-match-other'),
      ),
      findsNothing,
    );

    await tester.tap(find.text('Selected guest'));
    expect(tapped?.matchId, selected.matchId);
  });
}

ChatThreadPreview _preview(String id, String name) {
  final match = Match(
    id: 'match-$id',
    user1Id: 'host',
    user2Id: 'guest-$id',
    createdAt: DateTime(2026, 8, 31),
    lastMessageAt: DateTime(2026, 8, 31, 9),
    lastMessagePreview: 'Can you help?',
    lastMessageSenderId: 'guest-$id',
  );
  return ChatThreadPreview(
    match: match,
    matchId: match.id,
    otherUid: 'guest-$id',
    displayName: name,
    photoUrl: null,
    previewText: 'Can you help?',
    timestamp: match.lastMessageAt!,
    unreadCount: 0,
    hasConversation: true,
    eventIds: const [],
  );
}
