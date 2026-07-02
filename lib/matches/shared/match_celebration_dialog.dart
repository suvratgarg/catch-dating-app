import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchCelebrationDialog extends ConsumerWidget {
  const MatchCelebrationDialog({
    super.key,
    required this.match,
    required this.otherUid,
    required this.onSendMessage,
    required this.onKeepSwiping,
  });

  final Match match;
  final String otherUid;
  final VoidCallback onSendMessage;
  final VoidCallback onKeepSwiping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(watchPublicProfileProvider(otherUid));
    final t = CatchTokens.of(context);

    final profile = profileAsync.asData?.value;
    final name = profile?.name ?? '…';
    final photoUrl = profile?.primaryPhotoThumbnailUrl;

    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.match,
      eyebrow: 'New catch',
      title: "It's a Catch.",
      message: 'You and $name both liked each other.',
      icon: CatchIcons.favoriteRounded,
      visual: CatchPersonAvatar(
        size: 108,
        name: name,
        imageUrl: photoUrl,
        borderWidth: 3,
        borderColor: t.primary,
      ),
      details: [
        CelebrationDetail(
          icon: CatchIcons.favoriteBorderRounded,
          label: 'Match',
          value: '$name liked you back.',
        ),
      ],
      note:
          'Start with something specific from their profile or event history.',
      primaryAction: CelebrationAction(
        label: 'Send a message',
        onPressed: onSendMessage,
        icon: Icon(CatchIcons.sendRounded),
      ),
      secondaryAction: CelebrationAction(
        label: 'Keep catching',
        onPressed: onKeepSwiping,
      ),
      onClose: onKeepSwiping,
    );
  }
}
