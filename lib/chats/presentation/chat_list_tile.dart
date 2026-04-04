import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/publicProfile/data/public_profile_repository.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
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

        // "You: preview" if we sent the last message, otherwise plain preview
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
          backgroundColor: colorScheme.primaryContainer,
          child: photoUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                )
              : null,
        );

        return ListTile(
          onTap: onTap,
          leading: hasUnread
              ? Badge(
                  label: Text('$unreadCount'),
                  child: avatar,
                )
              : avatar,
          title: Text(
            name,
            style: TextStyle(
              fontWeight:
                  hasUnread ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          subtitle: Text(
            previewText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasUnread
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight:
                  hasUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Text(
            _formatTime(match.lastMessageAt ?? match.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: hasUnread
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight:
                      hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        );
      },
    );
  }
}
