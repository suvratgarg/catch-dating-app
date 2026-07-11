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
    final isHostApp = AppConfig.appRole.isHost;

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
                audienceCount: viewModel.totalThreadCount,
                audienceLabel: 'attendee',
                subtitle: 'Reminders, the meeting point, changes',
                onTap: onHostBroadcastSelected,
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
    required this.audienceCount,
    required this.audienceLabel,
    required this.subtitle,
    this.onTap,
  });

  final int audienceCount;
  final String audienceLabel;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final countLabel = audienceCount == 1
        ? '1 $audienceLabel'
        : '$audienceCount ${audienceLabel}s';
    final title = audienceCount == 0
        ? 'No ${audienceLabel}s yet'
        : 'Message $countLabel';

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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.fieldRowTitle(
                    context,
                    color: t.primaryInk,
                  ),
                ),
                const SizedBox(height: CatchSpacing.micro2),
                Text(
                  subtitle,
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
