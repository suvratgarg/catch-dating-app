part of '../run_club_list_tile.dart';

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.club, required this.isActive, this.onTap});

  final RunClub club;
  final bool isActive;
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
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? t.primary : t.line2,
                  width: isActive ? 3 : 1,
                ),
              ),
              padding: EdgeInsets.all(isActive ? 2 : 0),
              child: ClipOval(
                child: _ClubImage(imageUrl: club.imageUrl, seed: club.id),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              club.name,
              style: CatchTextStyles.labelM(
                context,
                color: isActive ? t.primary : t.ink2,
              ),
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
