part of '../club_list_tile.dart';

const double _avatarChipTileSize = CatchSpacing.s16;
const double _avatarChipColumnWidth = CatchLayout.clubAvatarRailColumnWidth;

Widget _buildAvatarChip(
  BuildContext context, {
  required Club club,
  bool showLiveBadge = false,
  VoidCallback? onTap,
}) {
  final t = CatchTokens.of(context);

  return Semantics(
    button: onTap != null,
    label: 'Open ${club.name} club',
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
                child: _buildClubImage(club: club, preferProfileImage: true),
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
                'Event soon',
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
