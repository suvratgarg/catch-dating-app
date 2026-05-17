import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tile_atoms.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tile_data.dart';
import 'package:flutter/material.dart';

class RunAgendaTile extends StatelessWidget {
  const RunAgendaTile({
    super.key,
    required this.data,
    this.onTap,
    this.showClubName = false,
    this.badgeLabel,
  });

  final RunTileData data;
  final VoidCallback? onTap;
  final bool showClubName;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clubName = data.clubName?.trim();
    return CatchSurface(
      padding: const EdgeInsets.all(Sizes.p14),
      radius: CatchRadius.md,
      borderColor: t.line,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            left: 0,
            right: null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: const SizedBox(width: 4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data.timeLabel,
                        style: CatchTextStyles.labelM(context),
                      ),
                    ),
                    RunTileStatusBadge(
                      status: data.status,
                      label: badgeLabel,
                      uppercase: true,
                    ),
                  ],
                ),
                gapH6,
                Text(
                  data.meetingPoint,
                  style: CatchTextStyles.labelL(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (clubName != null && clubName.isNotEmpty) ...[
                  gapH4,
                  Text(
                    clubName,
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                gapH8,
                Text(
                  '${data.distanceLabel} · ${data.paceLabel} · ${data.spotsLabel}',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
