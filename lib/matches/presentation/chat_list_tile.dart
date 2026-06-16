import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.preview,
    required this.onTap,
    this.divider = false,
  });

  final ChatThreadPreview preview;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final unreadCount = preview.unreadCount;
    final hasUnread = unreadCount > 0;
    final isNew = !preview.hasConversation;
    final emphasized = hasUnread || isNew;

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (divider)
                Positioned(
                  top: 0,
                  left: CatchLayout.chatListDividerInset,
                  right: 0,
                  child: ColoredBox(
                    color: t.line.withValues(
                      alpha: CatchOpacity.profileInfoDivider,
                    ),
                    child: const SizedBox(height: CatchStroke.hairline),
                  ),
                ),
              Padding(
                padding: CatchInsets.chatListTileVertical,
                child: Row(
                  children: [
                    CatchPersonAvatar(
                      size: CatchLayout.chatListAvatarExtent,
                      name: preview.displayName,
                      imageUrl: preview.photoUrl,
                      borderWidth: emphasized ? CatchStroke.underline : 0,
                      borderColor: emphasized ? t.primary : null,
                      shape: preview.match.isClubHostInquiry
                          ? CatchPersonAvatarShape.square
                          : CatchPersonAvatarShape.circle,
                    ),
                    const SizedBox(width: CatchLayout.chatListTextGap),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preview.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.infoRowTitle(
                              context,
                              color: emphasized ? t.ink : t.ink2,
                            ),
                          ),
                          const SizedBox(height: CatchSpacing.micro2),
                          Text(
                            preview.previewText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.chatPreview(
                              context,
                              color: isNew
                                  ? t.primary
                                  : hasUnread
                                  ? t.ink
                                  : t.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: CatchLayout.chatListTextGap),
                    _ChatListTrailing(
                      time: AppTimeFormatters.chatTimestamp(preview.timestamp),
                      unreadCount: unreadCount,
                      isNew: isNew,
                      emphasized: emphasized,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatListTrailing extends StatelessWidget {
  const _ChatListTrailing({
    required this.time,
    required this.unreadCount,
    required this.isNew,
    required this.emphasized,
  });

  final String time;
  final int unreadCount;
  final bool isNew;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasUnread = unreadCount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: CatchTextStyles.statusLabel(
            context,
            color: emphasized ? t.primary : t.ink3,
          ),
        ),
        if (hasUnread) ...[
          const SizedBox(height: CatchSpacing.micro6),
          _UnreadCountPill(count: unreadCount),
        ] else if (isNew) ...[
          const SizedBox(height: CatchSpacing.micro6),
          Semantics(
            label: 'New match',
            child: ClipOval(
              child: ColoredBox(
                color: t.primary,
                child: const SizedBox.square(dimension: CatchSpacing.s2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UnreadCountPill extends StatelessWidget {
  const _UnreadCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final label = count > 99 ? '99+' : '$count';

    return Semantics(
      label: count == 1 ? 'Unread chat' : '$label unread chats',
      child: CatchBadge(
        label: label,
        tone: CatchBadgeTone.brand,
        backgroundColor: t.primary,
        foregroundColor: t.primaryInk,
        borderColor: t.primary,
      ),
    );
  }
}
