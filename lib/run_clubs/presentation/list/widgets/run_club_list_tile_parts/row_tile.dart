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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 54,
                height: 54,
                child: _ClubImage(imageUrl: club.imageUrl, seed: club.id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: CatchTextStyles.labelLg(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CatchTextStyles.caption(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: isJoined ? null : onJoin,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: t.line2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CatchRadius.button),
                ),
              ),
              child: Text(
                isJoined ? 'Joined' : 'Join',
                style: CatchTextStyles.labelMd(
                  context,
                  color: isJoined ? t.ink3 : t.ink2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
