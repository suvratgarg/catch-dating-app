import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void showMatchCelebration(
  BuildContext context,
  WidgetRef ref,
  Match match,
  String currentUid,
) {
  final otherUid = match.otherId(currentUid);

  showDialog<void>(
    context: context,
    builder: (dialogContext) => MatchCelebrationDialog(
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

class MatchCelebrationDialog extends ConsumerWidget {
  const MatchCelebrationDialog({
    super.key,
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
    final t = CatchTokens.of(context);

    final profile = profileAsync.asData?.value;
    final name = profile?.name ?? '…';
    final photoUrl =
        profile?.photoUrls.isNotEmpty == true ? profile!.photoUrls.first : null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CatchRadius.cardLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl) : null,
              backgroundColor: t.primarySoft,
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: CatchTextStyles.displayXl(context, color: t.primary),
                    )
                  : null,
            ),
            gapH20,
            Text(
              "It's a match! 🎉",
              style: CatchTextStyles.displayLg(context, color: t.primary),
            ),
            gapH8,
            Text(
              'You and $name both liked each other.',
              textAlign: TextAlign.center,
              style: CatchTextStyles.bodyMd(context, color: t.ink2),
            ),
            gapH24,
            FilledButton.icon(
              onPressed: onSendMessage,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send a message'),
            ),
            gapH12,
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
