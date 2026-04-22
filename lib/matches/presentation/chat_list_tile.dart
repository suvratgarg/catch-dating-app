import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatListTile extends ConsumerWidget {
  const ChatListTile({
    super.key,
    required this.match,
    required this.currentUid,
    required this.onTap,
  });

  final Match match;
  final String currentUid;
  final VoidCallback onTap;

  String get _otherUid =>
      match.user1Id == currentUid ? match.user2Id : match.user1Id;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return DateFormat.jm().format(dt);
    if (now.difference(dt).inDays < 7) return DateFormat.E().format(dt);
    return DateFormat.MMMd().format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(_otherUid));
    final t = CatchTokens.of(context);
    final unreadCount = match.unreadCounts[currentUid] ?? 0;
    final hasUnread = unreadCount > 0;

    return profileAsync.when(
      loading: () => const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Text('Loading…'),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (profile) {
        final name = profile?.name ?? 'Unknown';
        final photoUrl = profile?.photoUrls.isNotEmpty == true
            ? profile!.photoUrls.first
            : null;

        final String previewText;
        if (match.lastMessagePreview == null) {
          previewText = 'You matched!';
        } else if (match.lastMessageSenderId == currentUid) {
          previewText = 'You: ${match.lastMessagePreview}';
        } else {
          previewText = match.lastMessagePreview!;
        }

        final avatar = CircleAvatar(
          radius: 28,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          backgroundColor: t.primarySoft,
          child: photoUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: CatchTextStyles.labelMd(context, color: t.primary),
                )
              : null,
        );

        return ListTile(
          onTap: onTap,
          leading: hasUnread
              ? Badge(label: Text('$unreadCount'), child: avatar)
              : avatar,
          title: Text(
            name,
            style: CatchTextStyles.labelLg(context).copyWith(
              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          subtitle: Text(
            previewText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.bodySm(
              context,
              color: hasUnread ? t.ink : t.ink2,
              weight: hasUnread ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          trailing: Text(
            _formatTime(match.lastMessageAt ?? match.createdAt),
            style:
                CatchTextStyles.caption(
                  context,
                  color: hasUnread ? t.primary : t.ink2,
                ).copyWith(
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        );
      },
    );
  }
}
