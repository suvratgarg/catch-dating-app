import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_new_matches_rail.dart';
import 'package:flutter/material.dart';

class ChatsListBody extends StatelessWidget {
  const ChatsListBody({super.key, required this.viewModel});

  final ChatsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        if (viewModel.newMatches.isNotEmpty)
          SliverToBoxAdapter(
            child: ChatNewMatchesRail(matches: viewModel.newMatches),
          ),
        if (viewModel.conversations.isNotEmpty)
          ChatConversationsList(matches: viewModel.conversations),
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
      ],
    );
  }
}
