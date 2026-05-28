part of '../club_list_tile.dart';

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.club,
    required this.isJoined,
    required this.isHost,
    this.onTap,
  });

  final Club club;
  final bool isJoined;
  final bool isHost;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sash = _membershipSashFor(isHost: isHost, isJoined: isJoined);
    final hasCoverImage = _hasCoverImage(club);

    return Semantics(
      button: onTap != null,
      label: 'Open ${club.name} club',
      child: hasCoverImage
          ? _DirectoryPhotoCard(
              club: club,
              isJoined: isJoined,
              isHost: isHost,
              sash: sash,
              onTap: onTap,
            )
          : _DirectoryIdentityCard(
              club: club,
              isJoined: isJoined,
              isHost: isHost,
              sash: sash,
              onTap: onTap,
            ),
    );
  }
}

class _DirectoryPhotoCard extends StatelessWidget {
  const _DirectoryPhotoCard({
    required this.club,
    required this.isJoined,
    required this.isHost,
    required this.sash,
    this.onTap,
  });

  final Club club;
  final bool isJoined;
  final bool isHost;
  final _MembershipSash? sash;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = ClubCoverVisualPalette.forClub(club);
    final visibleTags = _visibleTags(club);

    return CatchSurface(
      onTap: onTap,
      borderColor: t.line,
      radius: CatchRadius.lg,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.sm),
            child: _ClubPhotoMedia(club: club, sash: sash, palette: palette),
          ),
          gapH10,
          _DirectoryMonoLabel(_directoryCaption(club), color: t.ink3),
          gapH4,
          _ClubTitleLine(
            club: club,
            maxLines: 1,
            style: CatchTextStyles.clubDisplay(
              context,
              size: 30,
              height: 0.98,
              fontStyle: FontStyle.italic,
            ),
          ),
          gapH4,
          Text(
            club.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH10,
          _ClubHostActionRow(club: club, isJoined: isJoined, isHost: isHost),
          if (visibleTags.isNotEmpty) ...[
            gapH10,
            ClubTagWrap(tags: visibleTags.take(3).toList(growable: false)),
          ],
        ],
      ),
    );
  }
}

class _DirectoryIdentityCard extends StatelessWidget {
  const _DirectoryIdentityCard({
    required this.club,
    required this.isJoined,
    required this.isHost,
    required this.sash,
    this.onTap,
  });

  final Club club;
  final bool isJoined;
  final bool isHost;
  final _MembershipSash? sash;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = ClubCoverVisualPalette.forClub(club);
    final visibleTags = _visibleTags(club);

    return CatchSurface(
      onTap: onTap,
      borderColor: t.line,
      radius: CatchRadius.lg,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              sash == null ? CatchSpacing.s5 : CatchSpacing.s8,
              CatchSpacing.s5,
              CatchSpacing.s5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ClubFallbackCrest(club: club, palette: palette),
                    gapW14,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DirectoryMonoLabel(
                            _directoryCaption(club),
                            color: t.ink3,
                          ),
                          gapH4,
                          _ClubTitleLine(
                            club: club,
                            maxLines: 2,
                            style: CatchTextStyles.clubDisplay(
                              context,
                              size: 30,
                              height: 0.98,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          gapH8,
                          Text(
                            club.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.bodyLead(
                              context,
                              color: t.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    gapW10,
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClubMemberSeal(
                          label: clubMemberCountLabel(club),
                          accent: palette.accent,
                        ),
                      ],
                    ),
                  ],
                ),
                gapH18,
                _ClubRule(color: t.line),
                gapH14,
                _ClubHostActionRow(
                  club: club,
                  isJoined: isJoined,
                  isHost: isHost,
                ),
                if (visibleTags.isNotEmpty) ...[
                  gapH16,
                  _ClubRule(color: t.line),
                  gapH14,
                  ClubTagWrap(
                    tags: visibleTags.take(3).toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
          if (sash != null)
            Positioned(
              top: 0,
              left: 0,
              child: CatchCornerSash(
                label: sash!.label,
                icon: sash!.icon,
                tone: sash!.tone,
              ),
            ),
        ],
      ),
    );
  }
}

class _ClubPhotoMedia extends StatelessWidget {
  const _ClubPhotoMedia({
    required this.club,
    required this.sash,
    required this.palette,
  });

  final Club club;
  final _MembershipSash? sash;
  final ClubCoverVisualPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        final mediaHeight = (width * 9 / 16).clamp(168.0, 220.0);

        return SizedBox(
          height: mediaHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ClubImage(
                club: club,
                coverOnly: true,
                fallbackCompact: false,
                showFallbackLocationChip: false,
                showFallbackFooterLabel: false,
              ),
              const _ClubPhotoScrim(),
              Positioned(
                top: CatchSpacing.s3,
                left: CatchSpacing.s3,
                child: _ClubLogoCrest(
                  club: club,
                  palette: palette,
                  size: 38,
                  borderColor: Colors.white,
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
          ),
        );
      },
    );
  }
}

class _ClubPhotoScrim extends StatelessWidget {
  const _ClubPhotoScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.48, 1.0],
            colors: [
              Colors.black.withValues(alpha: 0.10),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClubLogoCrest extends StatelessWidget {
  const _ClubLogoCrest({
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
            ? Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _ClubLogoFallback(club: club),
              )
            : _ClubLogoFallback(club: club),
      ),
    );
  }
}

class _ClubFallbackCrest extends StatelessWidget {
  const _ClubFallbackCrest({required this.club, required this.palette});

  final Club club;
  final ClubCoverVisualPalette palette;

  @override
  Widget build(BuildContext context) {
    return _ClubLogoCrest(
      club: club,
      palette: palette,
      size: 74,
      borderColor: palette.iconBorder,
      borderWidth: 3,
    );
  }
}

class _ClubLogoFallback extends StatelessWidget {
  const _ClubLogoFallback({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return ClubCoverFallback(
      club: club,
      compact: true,
      showLocationChip: false,
      showFooterLabel: false,
    );
  }
}

class _ClubRule extends StatelessWidget {
  const _ClubRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
    );
  }
}

class _DirectoryMonoLabel extends StatelessWidget {
  const _DirectoryMonoLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.15,
        color: color,
      ),
    );
  }
}

class _ClubHostActionRow extends StatelessWidget {
  const _ClubHostActionRow({
    required this.club,
    required this.isJoined,
    required this.isHost,
  });

  final Club club;
  final bool isJoined;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return ClubHostIdentityLine(
      hostName: club.hostName,
      hostAvatarUrl: club.hostAvatarUrl,
      avatarSize: 28,
      trailing: _MembershipButton(
        clubId: club.id,
        isJoined: isJoined,
        isHost: isHost,
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

_MembershipSash? _membershipSashFor({
  required bool isHost,
  required bool isJoined,
}) {
  // Hosts are also included in joinedClubIds upstream; host has to win
  // precedence so owners do not render as ordinary joined members.
  if (isHost) {
    return _MembershipSash(
      label: 'You host',
      icon: CatchIcons.hostBadge,
      tone: CatchSashTone.solid,
    );
  }
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

class _MembershipButton extends StatelessWidget {
  const _MembershipButton({
    required this.clubId,
    required this.isJoined,
    required this.isHost,
  });

  final String clubId;
  final bool isJoined;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    if (isHost || isJoined) {
      // Membership state is communicated via the corner sash on the photo
      // now; no redundant button needed.
      return const SizedBox.shrink();
    }
    return _JoinClubButton(clubId: clubId);
  }
}

class _JoinClubButton extends ConsumerWidget {
  const _JoinClubButton({required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final joinMutation = ref.watch(ClubMembershipController.joinMutation);

    return CatchButton(
      label: 'Join',
      icon: Icon(CatchIcons.groupAddOutlined),
      onPressed: joinMutation.isPending
          ? null
          : () {
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
              _joinClub(ref);
            },
      variant: CatchButtonVariant.primary,
      size: CatchButtonSize.sm,
      backgroundColor: t.ink,
      foregroundColor: t.primaryInk,
    );
  }

  void _joinClub(WidgetRef ref) {
    ClubMembershipController.joinMutation.run(ref, (transaction) async {
      await transaction
          .get(clubMembershipControllerProvider.notifier)
          .join(clubId);
    });
  }
}

class _ClubTitleLine extends StatelessWidget {
  const _ClubTitleLine({
    required this.club,
    required this.style,
    required this.maxLines,
  });

  final Club club;
  final TextStyle style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            club.name,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (club.rating > 0) ...[
          gapW8,
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: ClubRatingPill(rating: club.rating),
          ),
        ],
      ],
    );
  }
}
