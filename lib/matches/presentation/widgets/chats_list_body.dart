import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_conversations_list.dart';
import 'package:flutter/material.dart';

class ChatsListBody extends StatelessWidget {
  const ChatsListBody({super.key, required this.viewModel});

  final ChatsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final threads = [...viewModel.newMatches, ...viewModel.conversations];
    final t = CatchTokens.of(context);
    final sectionLabel = AppConfig.appRole.isHost
        ? 'ATTENDEE QUERIES'
        : 'CONVERSATIONS';

    return SliverMainAxisGroup(
      slivers: [
        if (threads.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s4,
                CatchSpacing.micro14,
                CatchSpacing.s4,
                CatchSpacing.s2,
              ),
              child: Text(
                sectionLabel,
                style: CatchTextStyles.kicker(context, color: t.ink2),
              ),
            ),
          ),
        if (threads.isNotEmpty) ChatConversationsList(matches: threads),
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
      ],
    );
  }
}
