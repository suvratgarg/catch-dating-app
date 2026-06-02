import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.preview, required this.onTap});

  final ChatThreadPreview preview;
  final VoidCallback onTap;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return AppTimeFormatters.time(dt);
    if (now.difference(dt).inDays < 7) return DateFormat.E().format(dt);
    return DateFormat.MMMd().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final unreadCount = preview.unreadCount;
    final hasUnread = unreadCount > 0;

    return CatchSurface(
      onTap: onTap,
      backgroundColor: hasUnread ? t.primarySoft : null,
      borderColor: hasUnread
          ? t.primary.withValues(alpha: CatchOpacity.chatUnreadBorder)
          : t.line,
      radius: CatchRadius.md,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasUnread)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: CatchLayout.chatUnreadStripWidth,
              child: ColoredBox(
                color: t.primary,
                child: const SizedBox.expand(),
              ),
            ),
          Padding(
            padding: CatchInsets.contentDense,
            child: Row(
              children: [
                PersonAvatar(
                  size: 60,
                  name: preview.displayName,
                  imageUrl: preview.photoUrl,
                  borderWidth: hasUnread ? 2 : 0,
                  borderColor: hasUnread ? t.primary : null,
                ),
                const SizedBox(width: CatchSpacing.s3),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              preview.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: hasUnread
                                  ? CatchTextStyles.titleL(context)
                                  : CatchTextStyles.sectionTitle(context),
                            ),
                          ),
                          const SizedBox(width: CatchSpacing.s2),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: CatchSpacing.micro2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(preview.timestamp),
                                  style: CatchTextStyles.statusLabel(
                                    context,
                                    color: hasUnread ? t.primary : t.ink2,
                                  ),
                                ),
                                if (hasUnread) ...[
                                  const SizedBox(width: CatchSpacing.s2),
                                  _UnreadCountPill(count: unreadCount),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: CatchSpacing.s1),
                      Text(
                        preview.previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: hasUnread
                            ? CatchTextStyles.chatMessage(context, color: t.ink)
                            : CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
