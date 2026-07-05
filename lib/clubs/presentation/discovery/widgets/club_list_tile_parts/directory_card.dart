part of '../club_list_tile.dart';

class DirectoryCard extends StatelessWidget {
  const DirectoryCard({
    super.key,
    required this.club,
    required this.isJoined,
    this.onTap,
  });

  final Club club;
  final bool isJoined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasCoverImage = _hasCoverImage(club);

    return Semantics(
      button: onTap != null,
      label: 'Open ${club.name} club',
      child: DirectoryClubCard(
        club: club,
        isJoined: isJoined,
        hasCoverImage: hasCoverImage,
        onTap: onTap,
      ),
    );
  }
}

class DirectoryClubCard extends StatelessWidget {
  const DirectoryClubCard({
    super.key,
    required this.club,
    required this.isJoined,
    required this.hasCoverImage,
    this.onTap,
  });

  final Club club;
  final bool isJoined;
  final bool hasCoverImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = ClubCoverVisualPalette.forClub(context, club);
    final visibleTags = _visibleTags(club);
    final sash = _membershipSashFor(isJoined: isJoined);

    return CatchPolaroid(
      onTap: onTap,
      media: hasCoverImage
          ? ClubPhotoMediaOverlay(club: club)
          : ClubPolaroidArtwork(club: club),
      mediaOverlay: ClubPhotoChrome(club: club, sash: sash, palette: palette),
      caption: _directoryCaption(club),
      captionColor: t.ink3,
      title: club.name,
      titleMaxLines: hasCoverImage ? 1 : 2,
      subtitle: club.description,
      showArrow: false,
      footer: ClubDirectoryFooter(
        club: club,
        isJoined: isJoined,
        visibleTags: visibleTags,
      ),
    );
  }
}

class ClubPhotoMediaOverlay extends StatelessWidget {
  const ClubPhotoMediaOverlay({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return ClubImage(club: club, coverOnly: true, fallbackCompact: false);
  }
}

class ClubPhotoChrome extends StatelessWidget {
  const ClubPhotoChrome({
    super.key,
    required this.club,
    required this.sash,
    required this.palette,
  });

  final Club club;
  final _MembershipSash? sash;
  final ClubCoverVisualPalette palette;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CatchScrim.photoFrame(),
        Positioned(
          top: CatchSpacing.s3,
          left: CatchSpacing.s3,
          child: ClubLogoCrest(
            club: club,
            palette: palette,
            size: 38,
            borderColor: CatchTokens.editorialLight,
            borderWidth: 2,
          ),
        ),
        if (sash != null)
          Positioned(
            left: 0,
            bottom: 0,
            child: CatchCornerSash(
              label: sash!.label,
              icon: sash!.icon,
              tone: sash!.tone,
            ),
          ),
        Positioned(
          top: CatchSpacing.s3,
          right: CatchSpacing.s3,
          child: ClubMemberSeal(
            label: clubMemberCountLabel(club),
            accent: palette.accent,
            compact: true,
          ),
        ),
      ],
    );
  }
}

class ClubLogoCrest extends StatelessWidget {
  const ClubLogoCrest({
    super.key,
    required this.club,
    required this.palette,
    required this.size,
    required this.borderColor,
    required this.borderWidth,
  });

  final Club club;
  final ClubCoverVisualPalette palette;
  final double size;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final logoUrl = club.profileImageUrl?.trim();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.accent,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: CatchElevation.card,
      ),
      child: ClipOval(
        child: logoUrl != null && logoUrl.isNotEmpty
            ? CatchNetworkImage(
                logoUrl,
                errorBuilder: (_, _, _) => const ClubLogoFallback(),
              )
            : const ClubLogoFallback(),
      ),
    );
  }
}

class ClubLogoFallback extends StatelessWidget {
  const ClubLogoFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

class ClubDirectoryFooter extends StatelessWidget {
  const ClubDirectoryFooter({
    super.key,
    required this.club,
    required this.isJoined,
    required this.visibleTags,
  });

  final Club club;
  final bool isJoined;
  final List<String> visibleTags;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (club.rating > 0) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: ClubRatingPill(rating: club.rating),
          ),
          gapH10,
        ],
        ClubHostActionRow(club: club, isJoined: isJoined),
        if (visibleTags.isNotEmpty) ...[
          gapH10,
          ClubRule(color: t.line),
          gapH10,
          ClubTagWrap(tags: visibleTags.take(3).toList(growable: false)),
        ],
      ],
    );
  }
}

class ClubRule extends StatelessWidget {
  const ClubRule({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
    );
  }
}

class ClubHostActionRow extends StatelessWidget {
  const ClubHostActionRow({
    super.key,
    required this.club,
    required this.isJoined,
  });

  final Club club;
  final bool isJoined;

  @override
  Widget build(BuildContext context) {
    return ClubHostIdentityLine(
      hostName: club.displayHostName,
      hostAvatarUrl: club.hostAvatarUrl,
      trailing: MembershipTrailingController(
        clubId: club.id,
        isJoined: isJoined,
      ),
    );
  }
}

bool _hasCoverImage(Club club) {
  return club.imageUrl?.trim().isNotEmpty ?? false;
}

String _directoryCaption(Club club) {
  final nextEventLabel = club.nextEventLabel?.trim();
  if (nextEventLabel != null && nextEventLabel.isNotEmpty) {
    return nextEventLabel.toUpperCase();
  }
  return '${club.area} / ${cityLabel(club.location)}'.toUpperCase();
}

_MembershipSash? _membershipSashFor({required bool isJoined}) {
  if (isJoined) {
    return _MembershipSash(
      label: 'Joined',
      icon: CatchIcons.joinedCheck,
      tone: CatchSashTone.success,
    );
  }
  return null;
}

class _MembershipSash {
  const _MembershipSash({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final CatchSashTone tone;
}

List<String> _visibleTags(Club club) {
  return visibleClubTags(club);
}

class MembershipTrailingController extends ConsumerWidget {
  const MembershipTrailingController({
    super.key,
    required this.clubId,
    required this.isJoined,
  });

  final String clubId;
  final bool isJoined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isJoined) {
      return const MembershipTrailing(
        isJoined: true,
        isPending: false,
        onJoinPressed: null,
      );
    }

    // Key by clubId so each tile observes only its own join state; an unkeyed
    // shared mutation would spin/disable every visible Join button at once.
    final mutation = ClubMembershipController.joinMutation(clubId);
    final joinMutation = ref.watch(mutation);
    void joinClub() {
      unawaited(
        mutation
            .run(ref, (transaction) async {
              await transaction
                  .get(clubMembershipControllerProvider.notifier)
                  .join(clubId);
            })
            .catchError((Object error, StackTrace stackTrace) {
              ref
                  .read(errorLoggerProvider)
                  .logError(
                    error,
                    stackTrace,
                    reason: 'MembershipTrailingController._joinClub failed',
                  );
            }),
      );
    }

    return CatchMutationErrorListener(
      mutation: mutation,
      errorContext: AppErrorContext.club,
      child: MembershipTrailing(
        isJoined: false,
        isPending: joinMutation.isPending,
        onJoinPressed: () {
          final uid = ref.read(uidProvider).asData?.value;
          if (uid == null) {
            context.go(
              Uri(
                path: Routes.authScreen.path,
                queryParameters: {'from': '/clubs/$clubId'},
              ).toString(),
            );
            return;
          }
          joinClub();
        },
      ),
    );
  }
}

class MembershipTrailing extends StatelessWidget {
  const MembershipTrailing({
    super.key,
    required this.isJoined,
    required this.isPending,
    required this.onJoinPressed,
  });

  final bool isJoined;
  final bool isPending;
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context) {
    if (isJoined) {
      // Membership state is communicated via the corner sash on the photo now; no
      // redundant button needed.
      return const SizedBox.shrink();
    }

    final t = CatchTokens.of(context);
    return CatchButton(
      label: 'Join',
      icon: Icon(CatchIcons.groupAddOutlined),
      onPressed: isPending ? null : onJoinPressed,
      size: CatchButtonSize.sm,
      backgroundColor: t.ink,
      foregroundColor: t.primaryInk,
    );
  }
}
