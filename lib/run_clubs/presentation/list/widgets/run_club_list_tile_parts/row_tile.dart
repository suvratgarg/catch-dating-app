part of '../run_club_list_tile.dart';

class _RowTile extends StatelessWidget {
  const _RowTile({
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
    final subtitle = isJoined
        ? (club.nextRunLabel ?? 'Next run coming up')
        : '${club.area} · ${club.memberCount} runners';

    return CatchSurface(
      onTap: onTap,
      tone: CatchSurfaceTone.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12),
      borderWidth: 0,
      radius: CatchRadius.md,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 54,
              height: 54,
              child: _ClubImage(club: club),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: CatchTextStyles.titleM(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: CatchTextStyles.bodyS(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CatchButton(
            label: isJoined ? 'Joined' : 'Join',
            onPressed: isJoined ? null : onJoin,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
            foregroundColor: isJoined ? t.ink3 : t.ink2,
            borderColor: t.line2,
          ),
        ],
      ),
    );
  }
}
