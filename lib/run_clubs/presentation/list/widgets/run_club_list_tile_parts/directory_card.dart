part of '../run_club_list_tile.dart';

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.club,
    required this.isJoined,
    this.onTap,
  });

  final RunClub club;
  final bool isJoined;
  final VoidCallback? onTap;

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
                _ClubImage(imageUrl: club.imageUrl, seed: club.id),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
