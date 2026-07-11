import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
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
            CatchSurface(
              width: CatchLayout.attendedEventTileArtExtent,
              height: CatchLayout.attendedEventTileArtExtent,
              radius: CatchRadius.attendedEventTile,
              gradient: t.heroGrad,
              borderWidth: 0,
              child: Icon(CatchIcons.favoriteRounded, color: t.primaryInk),
            ),
            gapW14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPEN CATCH WINDOW',
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
                  label: 'Recap',
                  onPressed: onOpenRecap,
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.sm,
                  foregroundColor: t.primary,
                ),
                gapH4,
                const CatchBadge(
                  label: 'Catch',
                  tone: CatchBadgeTone.solid,
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
