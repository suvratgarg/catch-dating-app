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
      borderColor: t.line,
      radius: CatchRadius.md,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ChatAvatar(
            name: preview.displayName,
            photoUrl: preview.photoUrl,
            unreadCount: unreadCount,
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
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: CatchSpacing.s2),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatTime(preview.timestamp),
                        style:
                            CatchTextStyles.bodyS(
                              context,
                              color: hasUnread ? t.primary : t.ink2,
                            ).copyWith(
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
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
                            ? FontWeight.w500
                            : FontWeight.w400,
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

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({
    required this.name,
    required this.photoUrl,
    required this.unreadCount,
  });

  final String name;
  final String? photoUrl;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: PersonAvatar(size: 60, name: name, imageUrl: photoUrl),
          ),
          if (unreadCount > 0)
            Positioned(
              top: 0,
              right: -2,
              child: CatchBadge(
                label: '$unreadCount',
                tone: CatchBadgeTone.warning,
                size: CatchBadgeSize.sm,
              ),
            ),
        ],
      ),
    );
  }
}
