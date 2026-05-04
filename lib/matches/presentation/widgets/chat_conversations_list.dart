import 'package:catch_dating_app/core/widgets/catch_vertical_section.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatConversationsList extends StatelessWidget {
  const ChatConversationsList({
    super.key,
    required this.matches,
    required this.uid,
  });

  final List<Match> matches;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return CatchVerticalSection(
      title: 'Messages',
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return ChatListTile(
          match: match,
          currentUid: uid,
          onTap: () => context.goNamed(
            Routes.chatScreen.name,
            pathParameters: {'matchId': match.id},
          ),
        );
      },
    );
  }
}
