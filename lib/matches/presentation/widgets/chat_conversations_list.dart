import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatConversationsList extends StatelessWidget {
  const ChatConversationsList({super.key, required this.matches});

  final List<ChatThreadPreview> matches;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index.isOdd) return SizedBox(height: CatchSpacing.s3);

          final preview = matches[index ~/ 2];
          return ChatListTile(
            preview: preview,
            onTap: () => context.goNamed(
              Routes.chatScreen.name,
              pathParameters: {'matchId': preview.matchId},
            ),
          );
        }, childCount: matches.isEmpty ? 0 : matches.length * 2 - 1),
      ),
    );
  }
}
