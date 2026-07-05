import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class ChatsListBody extends StatelessWidget {
  const ChatsListBody({
    super.key,
    required this.viewModel,
    required this.onThreadSelected,
    this.onHostBroadcastSelected,
  });

  final ChatsListViewModel viewModel;
  final ChatThreadSelectedCallback onThreadSelected;
  final VoidCallback? onHostBroadcastSelected;

  @override
  Widget build(BuildContext context) {
    final threads = [...viewModel.newMatches, ...viewModel.conversations];
    final t = CatchTokens.of(context);
    final isHostApp = AppConfig.appRole.isHost;
    final sectionLabel = isHostApp ? null : 'CONVERSATIONS';

    return SliverMainAxisGroup(
      slivers: [
        if (threads.isNotEmpty && isHostApp)
          SliverToBoxAdapter(
            child: Padding(
              padding: CatchInsets.pageBody.copyWith(
                top: CatchSpacing.micro14,
                bottom: CatchSpacing.s4,
              ),
              child: HostInboxBroadcastCard(
                threadCount: viewModel.totalThreadCount,
                onTap: onHostBroadcastSelected,
              ),
            ),
          ),
        if (threads.isNotEmpty && sectionLabel != null)
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
        if (threads.isNotEmpty)
          ChatConversationsList(
            matches: threads,
            onThreadSelected: onThreadSelected,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
      ],
    );
  }
}

class HostInboxBroadcastCard extends StatelessWidget {
  const HostInboxBroadcastCard({
    super.key,
    required this.threadCount,
    this.onTap,
  });

  final int threadCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final countLabel = threadCount <= 0
        ? 'attendees'
        : '$threadCount attendees';

    return CatchSurface(
      radius: CatchRadius.md,
      backgroundColor: t.ink,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s3,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Icon(CatchIcons.megaphone, size: CatchIcon.md, color: t.primaryInk),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message all $countLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.fieldRowTitle(
                    context,
                    color: t.primaryInk,
                  ),
                ),
                const SizedBox(height: CatchSpacing.micro2),
                Text(
                  'Reminders, the meeting point, changes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(
                    context,
                    color: t.primaryInk.withValues(
                      alpha: CatchOpacity.primaryInkProminent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: CatchSpacing.s2),
          Icon(
            CatchIcons.chevronRightRounded,
            size: CatchIcon.control,
            color: t.primaryInk.withValues(
              alpha: CatchOpacity.primaryInkProminent,
            ),
          ),
        ],
      ),
    );
  }
}
