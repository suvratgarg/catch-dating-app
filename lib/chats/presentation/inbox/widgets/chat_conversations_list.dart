import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:flutter/material.dart';

typedef ChatThreadSelectedCallback = void Function(ChatThreadPreview preview);
typedef ChatPreviewTextBuilder = String Function(ChatThreadPreview preview);
typedef ChatTimestampTextBuilder = String Function(ChatThreadPreview preview);

class ChatConversationsList extends StatelessWidget {
  const ChatConversationsList({
    super.key,
    required this.matches,
    required this.onThreadSelected,
    this.previewTextFor,
    this.timestampTextFor,
    this.selectedMatchId,
    this.now,
  });

  final List<ChatThreadPreview> matches;
  final ChatThreadSelectedCallback onThreadSelected;
  final ChatPreviewTextBuilder? previewTextFor;
  final ChatTimestampTextBuilder? timestampTextFor;
  final String? selectedMatchId;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: CatchInsets.chatListGutter,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final preview = matches[index];
          final unreadCount = preview.unreadCount;
          final isNew = !preview.hasConversation;
          final row = CatchPersonRow(
            data: CatchPersonRowData(
              name: preview.displayName,
              imageUrl: preview.photoUrl,
              lastMessage: previewTextFor?.call(preview) ?? preview.previewText,
              timestamp:
                  timestampTextFor?.call(preview) ??
                  AppTimeFormatters.chatTimestamp(preview.timestamp, now: now),
              unreadCount: unreadCount,
              isFresh: unreadCount > 0 || isNew,
              showFreshDot: unreadCount == 0 && isNew,
              avatarShape: preview.match.isClubHostInquiry
                  ? CatchPersonAvatarShape.square
                  : CatchPersonAvatarShape.circle,
            ),
            avatarSize: CatchLayout.chatListAvatarExtent,
            padding: CatchInsets.chatListTileVertical,
            divider: index > 0,
            showFreshBackground: false,
            onTap: () => onThreadSelected(preview),
          );
          if (selectedMatchId != preview.matchId) return row;
          return Semantics(
            key: ValueKey<String>(
              'chat-conversation-selected-${preview.matchId}',
            ),
            container: true,
            selected: true,
            child: ColoredBox(
              color: CatchTokens.of(
                context,
              ).ink.withValues(alpha: CatchOpacity.tabBarPillFill),
              child: row,
            ),
          );
        }, childCount: matches.length),
      ),
    );
  }
}
