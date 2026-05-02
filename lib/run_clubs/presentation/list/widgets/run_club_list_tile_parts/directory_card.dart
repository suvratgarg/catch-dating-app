part of '../run_club_list_tile.dart';

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.club,
    required this.isJoined,
    this.onTap,
    this.onJoin,
  });

  final RunClub club;
  final bool isJoined;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      onTap: onTap,
      borderColor: t.line,
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
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: t.line,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 40,
                      child: Stack(
                        children: [
                          for (var j = 0; j < 3; j++)
                            Positioned(
                              left: j * 16.0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    CatchRadius.sm,
                                  ),
                                  border: Border.all(
                                    color: t.surface,
                                    width: 1.5,
                                  ),
                                  color: t.line,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 16,
                                    color: t.ink3,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Recent runs',
                        style: CatchTextStyles.bodyS(context, color: t.ink2),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: t.ink3),
                  ],
                ),
                if (!isJoined && onJoin != null) ...[
                  const SizedBox(height: 14),
                  CatchButton(
                    label: 'Join',
                    onPressed: onJoin,
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
