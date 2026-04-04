import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/publicProfile/data/public_profile_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MatchesListScreen extends ConsumerStatefulWidget {
  const MatchesListScreen({super.key});

  @override
  ConsumerState<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends ConsumerState<MatchesListScreen> {
  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: uidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (uid) {
          if (uid == null) return const SizedBox.shrink();

          // Listen for new matches to show the celebration dialog.
          ref.listen(matchesForUserProvider(uid), (previous, next) {
            if (!context.mounted) return;
            if (previous == null || !previous.hasValue || !next.hasValue) return;

            final prevIds = previous.value!.map((m) => m.id).toSet();
            final newMatches =
                next.value!.where((m) => !prevIds.contains(m.id)).toList();

            for (final match in newMatches) {
              _showMatchCelebration(context, ref, match, uid);
            }
          });

          final matchesAsync = ref.watch(matchesForUserProvider(uid));

          return matchesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (matches) {
              if (matches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matches yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep swiping to find your match!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: matches.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final match = matches[i];
                  final otherUid = match.otherId(uid);
                  final profileAsync =
                      ref.watch(publicProfileProvider(otherUid));

                  return ChatListTile(
                    match: match,
                    currentUid: uid,
                    onTap: () => context.goNamed(
                      Routes.chatScreen.name,
                      pathParameters: {'matchId': match.id},
                      extra: profileAsync.asData?.value,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

void _showMatchCelebration(
  BuildContext context,
  WidgetRef ref,
  Match match,
  String currentUid,
) {
  final otherUid = match.otherId(currentUid);

  showDialog<void>(
    context: context,
    builder: (dialogContext) => _MatchCelebrationDialog(
      match: match,
      otherUid: otherUid,
      onSendMessage: () {
        Navigator.of(dialogContext).pop();
        final otherProfile =
            ref.read(publicProfileProvider(otherUid)).asData?.value;
        context.goNamed(
          Routes.chatScreen.name,
          pathParameters: {'matchId': match.id},
          extra: otherProfile,
        );
      },
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _MatchCelebrationDialog extends ConsumerWidget {
  const _MatchCelebrationDialog({
    required this.match,
    required this.otherUid,
    required this.onSendMessage,
  });

  final Match match;
  final String otherUid;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(otherUid));
    final colorScheme = Theme.of(context).colorScheme;

    final profile = profileAsync.asData?.value;
    final name = profile?.name ?? '…';
    final photoUrl =
        profile?.photoUrls.isNotEmpty == true ? profile!.photoUrls.first : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo
            CircleAvatar(
              radius: 52,
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl) : null,
              backgroundColor: colorScheme.primaryContainer,
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 36,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              "It's a match! 🎉",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You and $name both liked each other.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onSendMessage,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send a message'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep swiping'),
            ),
          ],
        ),
      ),
    );
  }
}
