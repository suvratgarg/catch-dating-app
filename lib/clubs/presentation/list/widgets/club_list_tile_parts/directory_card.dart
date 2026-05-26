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
    final t = CatchTokens.of(context);
    final visibleTags = _visibleTags(club);
    final sash = _membershipSash();

    return Semantics(
      button: onTap != null,
      label: 'Open ${club.name} club',
      child: CatchSurface(
        onTap: onTap,
        borderColor: t.line,
        radius: CatchRadius.lg,
        elevation: CatchSurfaceElevation.card,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ClubImage(
                    club: club,
                    fallbackCompact: false,
                    showFallbackLocationChip: false,
                    showFallbackFooterLabel: false,
                  ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.45, 0.78, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.32),
                            Colors.black.withValues(alpha: 0.58),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (sash != null)
                    Positioned(
                      top: CatchSpacing.s3,
                      left: CatchSpacing.s3,
                      child: CatchCornerSash(
                        label: sash.label,
                        icon: sash.icon,
                        tone: sash.tone,
                      ),
                    ),
                  if (club.rating > 0)
                    Positioned(
                      right: CatchSpacing.s3,
                      bottom: CatchSpacing.s3,
                      child: _RatingBadge(rating: club.rating),
                    ),
                  Positioned(
                    left: CatchSpacing.s4,
                    right: CatchSpacing.s4,
                    bottom: CatchSpacing.s3,
                    child: Text(
                      club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.cardTitle(
                        context,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s4,
                CatchSpacing.s3,
                CatchSpacing.s4,
                CatchSpacing.s3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatchMetaDotRow(
                    entries: _buildClubMetaEntries(club, t),
                  ),
                  if (visibleTags.isNotEmpty) ...[
                    gapH8,
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: visibleTags
                          .take(3)
                          .map(
                            (tag) => CatchBadge(
                              label: tag,
                              tone: CatchBadgeTone.brand,
                              size: CatchBadgeSize.sm,
                              uppercase: true,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  gapH10,
                  Row(
                    children: [
                      _HostAvatar(club: club),
                      gapW6,
                      Expanded(
                        child: Text(
                          club.hostName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ),
                      gapW10,
                      _MembershipButton(
                        clubId: club.id,
                        isJoined: isJoined,
                        isHost: isHost,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MembershipSash? _membershipSash() {
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

List<CatchMetaEntry> _buildClubMetaEntries(Club club, CatchTokens t) {
  final memberLabel = club.memberCount == 1 ? 'member' : 'members';
  return [
    CatchMetaEntry(icon: CatchIcons.pinOutlined, label: club.area),
    CatchMetaEntry(
      icon: CatchIcons.group,
      label: '${club.memberCount} $memberLabel',
    ),
    if (club.rating > 0 && club.reviewCount > 0)
      CatchMetaEntry(
        icon: CatchIcons.rated,
        iconColor: t.gold,
        label:
            '${club.rating.toStringAsFixed(1)} · '
            '${_reviewCountLabel(club.reviewCount)}',
      ),
  ];
}

String _reviewCountLabel(int count) {
  return count == 1 ? '1 review' : '$count reviews';
}

List<String> _visibleTags(Club club) {
  final locationNames = {
    club.location.toLowerCase(),
    cityLabel(club.location).toLowerCase(),
  };
  return club.tags
      .where((tag) => !locationNames.contains(tag.trim().toLowerCase()))
      .toList(growable: false);
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
      // now — no redundant button needed.
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
    final joinMutation = ref.watch(ClubMembershipController.joinMutation);

    return CatchButton(
      label: 'Join',
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
      variant: CatchButtonVariant.secondary,
      size: CatchButtonSize.sm,
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

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s2,
        vertical: CatchSpacing.micro3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CatchIcons.rated, size: 13, color: t.gold),
          gapW2,
          Text(
            rating.toStringAsFixed(1),
            style: CatchTextStyles.labelL(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}

class _HostAvatar extends StatelessWidget {
  const _HostAvatar({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    if (club.hostAvatarUrl != null) {
      return CircleAvatar(
        radius: 9,
        backgroundImage: NetworkImage(club.hostAvatarUrl!),
        backgroundColor: t.line,
      );
    }

    return CircleAvatar(
      radius: 9,
      backgroundColor: t.line,
      child: Text(
        club.hostName.isNotEmpty ? club.hostName[0].toUpperCase() : '?',
        style: CatchTextStyles.statusLabel(
          context,
          color: t.ink2,
        ).copyWith(fontSize: 8),
      ),
    );
  }
}
