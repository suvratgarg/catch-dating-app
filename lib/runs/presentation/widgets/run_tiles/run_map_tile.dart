import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tile_atoms.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tile_data.dart';
import 'package:flutter/material.dart';

class RunMapTile extends StatelessWidget {
  const RunMapTile({
    super.key,
    required this.data,
    required this.selected,
    required this.onTap,
    this.width,
  });

  final RunTileData data;
  final bool selected;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '${data.meetingPoint} run',
      child: CatchSurface(
        width: width,
        padding: const EdgeInsets.all(CatchSpacing.s3),
        tone: selected ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
        radius: CatchRadius.md,
        borderColor: selected ? t.primary : t.line,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RunTileStatusBadge(status: data.status)),
                if (!data.hasExactStartingPoint) ...[
                  gapW6,
                  const CatchBadge(
                    label: 'No pin',
                    tone: CatchBadgeTone.warning,
                  ),
                ],
              ],
            ),
            gapH8,
            Text(
              data.meetingPoint,
              style: CatchTextStyles.labelL(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (data.clubName != null) ...[
              gapH4,
              Text(
                data.clubName!,
                style: CatchTextStyles.bodyS(context, color: t.ink2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            gapH8,
            Text(
              '${data.dateLabel} · ${data.compactTimeRangeLabel}',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            gapH4,
            Text(
              '${data.distanceLabel} · ${data.paceLabel} · ${data.priceLabel}',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            gapH4,
            Text(
              data.spotsLabel,
              style: CatchTextStyles.labelS(context, color: t.ink2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
