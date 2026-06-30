import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
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
          final unreadCount = preview.unreadCount;
          final isNew = !preview.hasConversation;
          return CatchPersonRow(
            data: CatchPersonRowData(
              name: preview.displayName,
              imageUrl: preview.photoUrl,
              lastMessage: preview.previewText,
              timestamp: AppTimeFormatters.chatTimestamp(preview.timestamp),
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
        }, childCount: matches.length),
      ),
    );
  }
}
