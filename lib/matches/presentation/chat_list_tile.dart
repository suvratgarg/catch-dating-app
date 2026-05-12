import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
    if (now.difference(dt).inDays == 0) return DateFormat.jm().format(dt);
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
      tone: CatchSurfaceTone.surface,
      backgroundColor: hasUnread ? t.primarySoft : null,
      borderColor: hasUnread ? t.primary.withValues(alpha: 0.36) : t.line,
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
              width: 4,
              child: ColoredBox(
                color: t.primary,
                child: const SizedBox.expand(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(CatchSpacing.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                              style: CatchTextStyles.titleM(context).copyWith(
                                fontWeight: hasUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: CatchSpacing.s2),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(preview.timestamp),
                                  style:
                                      CatchTextStyles.bodyS(
                                        context,
                                        color: hasUnread ? t.primary : t.ink2,
                                      ).copyWith(
                                        fontWeight: hasUnread
                                            ? FontWeight.w800
                                            : FontWeight.w500,
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
                        style:
                            CatchTextStyles.bodyS(
                              context,
                              color: hasUnread ? t.ink : t.ink2,
                            ).copyWith(
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
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
      label: '$label unread messages',
      child: CatchBadge(
        label: label,
        tone: CatchBadgeTone.brand,
        backgroundColor: t.primary,
        foregroundColor: t.primaryInk,
        borderColor: Colors.transparent,
      ),
    );
  }
}
