part of '../club_list_tile.dart';

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({
    required this.club,
    this.showLiveBadge = false,
    this.onTap,
  });

  final Club club;

  /// Whether the club has an event coming up. Rendered as a discreet brand
  /// status dot + caption strip — never the loud "LIVE" pill the prior
  /// implementation used, which read as "streaming video".
  final bool showLiveBadge;

  final VoidCallback? onTap;

  static const double _tileSize = 64;
  static const double _columnWidth = 76;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: onTap != null,
      label: 'Open ${club.name} club',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _columnWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: _tileSize,
                height: _tileSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  border: Border.all(
                    color: showLiveBadge ? t.primary : t.line2,
                    width: showLiveBadge ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  child: _ClubImage(
                    club: club,
                    preferProfileImage: true,
                    showFallbackFooterLabel: false,
                  ),
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
}
