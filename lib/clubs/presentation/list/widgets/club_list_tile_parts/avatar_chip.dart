part of '../club_list_tile.dart';

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({
    required this.club,
    this.showLiveBadge = false,
    this.onTap,
  });

  final Club club;
  final bool showLiveBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: onTap != null,
      label: 'Open ${club.name} club',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 82,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CatchSurface(
                    width: 76,
                    height: 76,
                    radius: CatchRadius.md,
                    borderColor: t.line2,
                    borderWidth: 1.5,
                    clipBehavior: Clip.antiAlias,
                    child: _ClubImage(
                      club: club,
                      preferProfileImage: true,
                      showFallbackFooterLabel: false,
                    ),
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
              gapH6,
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
      ),
    );
  }
}
