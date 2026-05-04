part of '../run_club_list_tile.dart';

class _DirectoryCard extends ConsumerWidget {
  const _DirectoryCard({
    required this.club,
    required this.isJoined,
    this.onTap,
  });

  final RunClub club;
  final bool isJoined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final joinMutation = ref.watch(RunClubsListController.joinMutation);

    return CatchSurface(
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
                _ClubImage(club: club),
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
                if (isJoined)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CatchBadge(
                      label: 'Joined',
                      icon: Icons.check_rounded,
                      tone: CatchBadgeTone.neutral,
                      size: CatchBadgeSize.sm,
                      uppercase: true,
                      backgroundColor: Colors.white.withValues(alpha: 0.95),
                      foregroundColor: Colors.black,
                    ),
                  ),
                if (club.nextRunLabel != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CatchBadge(
                      label: 'NEXT: ${club.nextRunLabel}',
                      tone: CatchBadgeTone.solid,
                      size: CatchBadgeSize.sm,
                      uppercase: true,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        club.name,
                        style: CatchTextStyles.titleL(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (club.rating > 0) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.star_rounded, size: 13, color: t.gold),
                      const SizedBox(width: 2),
                      Text(
                        club.rating.toStringAsFixed(1),
                        style: CatchTextStyles.bodyS(context, color: t.ink2),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${club.area} · ${club.memberCount} runners',
                  style: CatchTextStyles.bodyS(context),
                ),
                if (club.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: club.tags.map((tag) {
                      return CatchBadge(
                        label: tag,
                        tone: CatchBadgeTone.brand,
                        size: CatchBadgeSize.sm,
                        uppercase: true,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: t.line,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _HostAvatar(club: club),
                    const SizedBox(width: 6),
                    Text(
                      club.hostName,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                    const Spacer(),
                    if (!isJoined)
                      CatchButton(
                        label: 'Join',
                        onPressed: joinMutation.isPending
                            ? null
                            : () {
                                final uid =
                                    ref.read(uidProvider).asData?.value;
                                if (uid == null) {
                                  context.pushNamed(
                                    Routes.onboardingScreen.name,
                                    queryParameters: {'from': '/clubs'},
                                  );
                                  return;
                                }
                                _joinClub(ref);
                              },
                        variant: CatchButtonVariant.secondary,
                        size: CatchButtonSize.sm,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _joinClub(WidgetRef ref) {
    RunClubsListController.joinMutation.run(ref, (transaction) async {
      await transaction
          .get(runClubsListControllerProvider.notifier)
          .joinClub(club.id);
    });
  }
}

class _HostAvatar extends StatelessWidget {
  const _HostAvatar({required this.club});

  final RunClub club;

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
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: t.ink2,
        ),
      ),
    );
  }
}
