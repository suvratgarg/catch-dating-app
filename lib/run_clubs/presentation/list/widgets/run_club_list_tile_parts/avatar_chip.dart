part of '../run_club_list_tile.dart';

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({
    required this.club,
    this.showLiveBadge = false,
    this.onTap,
  });

  final RunClub club;
  final bool showLiveBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: t.line2, width: 1.5),
                  ),
                  child: ClipOval(child: _ClubImage(club: club)),
                ),
                if (showLiveBadge)
                  Positioned(
                    bottom: -2,
                    right: -6,
                    child: CatchBadge(
                      label: 'LIVE',
                      tone: CatchBadgeTone.live,
                      size: CatchBadgeSize.sm,
                      uppercase: true,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              club.name,
              style: CatchTextStyles.labelM(context, color: t.ink),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
