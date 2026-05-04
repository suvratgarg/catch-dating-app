import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatNewMatchesRail extends ConsumerWidget {
  const ChatNewMatchesRail({
    super.key,
    required this.matches,
    required this.uid,
  });

  final List<Match> matches;
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatchHorizontalRail(
      title: 'New matches',
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _NewMatchAvatar(
          match: match,
          uid: uid,
          onTap: () => context.goNamed(
            Routes.chatScreen.name,
            pathParameters: {'matchId': match.id},
          ),
        );
      },
    );
  }
}

class _NewMatchAvatar extends ConsumerWidget {
  const _NewMatchAvatar({
    required this.match,
    required this.uid,
    required this.onTap,
  });

  final Match match;
  final String uid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUid = match.otherId(uid);
    final profileAsync = ref.watch(watchPublicProfileProvider(otherUid));
    final t = CatchTokens.of(context);
    final photoUrl = profileAsync.asData?.value?.photoUrls.isNotEmpty == true
        ? profileAsync.asData!.value!.photoUrls.first
        : null;
    final name = profileAsync.asData?.value?.name ?? otherUid;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              backgroundColor: t.primarySoft,
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: t.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: t.ink2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
