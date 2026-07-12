part of '../club_list_tile.dart';

const double _avatarChipTileSize = CatchSpacing.s16;
const double _avatarChipColumnWidth = CatchLayout.clubAvatarRailColumnWidth;

class AvatarChip extends StatelessWidget {
  const AvatarChip({
    super.key,
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
      label: context.l10n.clubsAvatarChipLabelOpenNameClub(name: club.name),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _avatarChipColumnWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _avatarChipTileSize,
                height: _avatarChipTileSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  border: Border.all(
                    color: showLiveBadge ? t.primary : t.line2,
                    width: showLiveBadge ? 2 : 1,
                  ),
                ),
                padding: CatchInsets.iconChipContentTight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  child: ClubImage(club: club, preferProfileImage: true),
                ),
              ),
              gapH6,
              Text(
                club.name,
                style: CatchTextStyles.labelM(context, color: t.ink),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showLiveBadge) ...[
                gapH2,
                Text(
                  context.l10n.clubsAvatarChipTextEventSoon,
                  style: CatchTextStyles.labelS(context, color: t.primary),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
