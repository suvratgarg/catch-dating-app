import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_new_matches_rail.dart';
import 'package:flutter/material.dart';

class ChatsListBody extends StatelessWidget {
  const ChatsListBody({super.key, required this.viewModel, required this.uid});

  final ChatsListViewModel viewModel;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.newMatches.isNotEmpty)
          ChatNewMatchesRail(matches: viewModel.newMatches, uid: uid),
        if (viewModel.conversations.isNotEmpty)
          ChatConversationsList(
            matches: viewModel.conversations,
            uid: uid,
          ),
        const SizedBox(height: CatchSpacing.s6),
      ],
    );
  }
}
