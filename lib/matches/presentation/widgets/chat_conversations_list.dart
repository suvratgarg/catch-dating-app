import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:flutter/material.dart';

typedef ChatThreadSelectedCallback = void Function(ChatThreadPreview preview);

class ChatConversationsList extends StatelessWidget {
  const ChatConversationsList({
    super.key,
    required this.matches,
    required this.onThreadSelected,
  });

  final List<ChatThreadPreview> matches;
  final ChatThreadSelectedCallback onThreadSelected;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: CatchInsets.chatListGutter,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final preview = matches[index];
          return ChatListTile(
            preview: preview,
            divider: index > 0,
            onTap: () => onThreadSelected(preview),
          );
        }, childCount: matches.length),
      ),
    );
  }
}
