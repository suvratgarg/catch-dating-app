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

    return Semantics(
      button: onTap != null,
      label: 'Open ${club.name} club',
      child: CatchSurface(
        onTap: onTap,
        borderColor: t.line,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ClubImage(
                    club: club,
                    fallbackCompact: false,
                    showFallbackLocationChip: false,
                    showFallbackFooterLabel: false,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.4, 1.0],
                        colors: [
                          Color(0x40000000),
                          Colors.transparent,
                          Color(0x1A000000),
                        ],
                      ),
                    ),
                  ),
                  if (club.nextEventLabel != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CatchBadge(
                          label: 'NEXT: ${club.nextEventLabel}',
                          tone: CatchBadgeTone.solid,
                          size: CatchBadgeSize.sm,
                          uppercase: true,
                        ),
                      ),
                    ),
                  if (club.rating > 0)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _RatingBadge(rating: club.rating),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: CatchTextStyles.cardTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  gapH2,
                  Text(
                    _clubSummaryLabel(club),
                    style: CatchTextStyles.supporting(context),
                  ),
                  if (visibleTags.isNotEmpty) ...[
                    gapH10,
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: visibleTags.map((tag) {
                        return CatchBadge(
                          label: tag,
                          tone: CatchBadgeTone.brand,
                          size: CatchBadgeSize.sm,
                          uppercase: true,
                        );
                      }).toList(),
                    ),
                  ],
                  if (_hasMetadataPills(club)) ...[
                    gapH10,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (club.nextEventLabel != null)
                          _ClubMetaPill(
                            icon: Icons.event_available_outlined,
                            label: 'Next ${club.nextEventLabel}',
                          ),
                        if (club.rating > 0 && club.reviewCount > 0)
                          _ClubMetaPill(
                            icon: Icons.star_rounded,
                            iconColor: t.gold,
                            label:
                                '${club.rating.toStringAsFixed(1)} · '
                                '${_reviewCountLabel(club.reviewCount)}',
                          ),
                      ],
                    ),
                  ],
                  gapH10,
                  Container(height: 1, color: t.line),
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
}

String _clubSummaryLabel(Club club) {
  final memberLabel = club.memberCount == 1 ? 'member' : 'members';
  return '${club.area} · ${club.memberCount} $memberLabel';
}

bool _hasMetadataPills(Club club) {
  return club.nextEventLabel != null ||
      (club.rating > 0 && club.reviewCount > 0);
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

class _ClubMetaPill extends StatelessWidget {
  const _ClubMetaPill({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: t.raised,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor ?? t.ink2),
          gapW4,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.labelS(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
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
    final t = CatchTokens.of(context);

    if (isHost) {
      return CatchButton(
        label: 'Host',
        onPressed: null,
        variant: CatchButtonVariant.secondary,
        size: CatchButtonSize.sm,
        icon: Icon(Icons.shield_rounded, size: 16, color: t.primary),
        isInteractive: false,
        backgroundColor: t.primary.withValues(alpha: 0.10),
        foregroundColor: t.primary,
        borderColor: t.primary.withValues(alpha: 0.22),
      );
    }

    if (isJoined) {
      return CatchButton(
        label: 'Joined',
        onPressed: null,
        variant: CatchButtonVariant.secondary,
        size: CatchButtonSize.sm,
        icon: Icon(Icons.check_rounded, size: 16, color: t.success),
        isInteractive: false,
        backgroundColor: t.success.withValues(alpha: 0.10),
        foregroundColor: t.success,
        borderColor: t.success.withValues(alpha: 0.22),
      );
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

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      borderColor: Colors.white.withValues(alpha: 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: t.gold),
          gapW2,
          Text(
            rating.toStringAsFixed(1),
            style: CatchTextStyles.labelS(context, color: t.ink),
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
