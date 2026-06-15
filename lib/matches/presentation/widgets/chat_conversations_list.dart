import 'package:catch_dating_app/core/app_config.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final preview = matches[index];
          final routeName = AppConfig.appRole.isHost
              ? Routes.hostChatScreen.name
              : Routes.chatScreen.name;
          return ChatListTile(
            preview: preview,
            divider: index > 0,
            onTap: () => context.goNamed(
              routeName,
              pathParameters: {'matchId': preview.matchId},
            ),
          );
        }, childCount: matches.length),
      ),
    );
  }
}
