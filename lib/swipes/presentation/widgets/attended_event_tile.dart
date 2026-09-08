import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class AttendedEventTile extends StatelessWidget {
  const AttendedEventTile({
    super.key,
    required this.row,
    required this.onOpenCatch,
    required this.onOpenRecap,
  });

  final CatchesHubEventRow row;
  final VoidCallback onOpenCatch;
  final VoidCallback onOpenRecap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      label: row.title,
      button: true,
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: t.line,
        onTap: onOpenCatch,
        child: Row(
          children: [
            SizedBox(
              width: CatchLayout.attendedEventTileArtExtent,
              height: CatchLayout.attendedEventTileArtExtent,
              child: ColoredBox(
                color: t.primarySoft,
                child: Icon(CatchIcons.favoriteRounded, color: t.primary),
              ),
            ),
            gapW14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.swipesAttendedEventTileTextOpenCatchWindow,
                    style: CatchTextStyles.kicker(context, color: t.primary),
                  ),
                  gapH4,
                  Text(
                    row.title,
                    style: CatchTextStyles.titleL(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  gapH4,
                  Text(
                    row.dateAttendeeLabel,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            gapW10,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  row.tileCountdownLabel,
                  style: CatchTextStyles.mono(context, color: t.ink),
                ),
                gapH4,
                CatchButton(
                  label: context.l10n.swipesAttendedEventTileLabelRecap,
                  onPressed: onOpenRecap,
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.sm,
                  foregroundColor: t.primary,
                ),
                gapH4,
                CatchBadge.solidStatus(
                  label: context.l10n.swipesAttendedEventTileLabelCatch,
                  size: CatchBadgeSize.md,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
