import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_atoms.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:flutter/material.dart';

class EventRailTile extends StatelessWidget {
  const EventRailTile({super.key, required this.data, this.width, this.onTap});

  final EventTileData data;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      width: width,
      radius: CatchRadius.md,
      borderColor: t.line,
      backgroundColor: t.surface,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: EventTileFactWrap(
                    data: data,
                    includePrice: true,
                    includeSpots: false,
                  ),
                ),
                gapW8,
                EventTileStatusBadge(status: data.status),
              ],
            ),
            gapH12,
            Text(
              data.title,
              style: CatchTextStyles.titleM(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            gapH8,
            if (data.clubName != null) ...[
              EventTileMetaRow(
                icon: Icons.groups_2_outlined,
                label: data.clubName!,
                emphasize: true,
              ),
              gapH6,
            ],
            EventTileMetaRow(
              icon: Icons.schedule,
              label: '${data.dateLabel} · ${data.timeRangeLabel}',
            ),
            gapH6,
            EventTileMetaRow(
              icon: Icons.location_on_outlined,
              label: data.meetingPoint,
              maxLines: 2,
            ),
            gapH10,
            EventTileMetaRow(
              icon: Icons.person_add_alt_1_outlined,
              label: data.signupLabel,
              emphasize: true,
            ),
            if (data.reasonLabel != null) ...[
              gapH10,
              CatchBadge(
                label: data.reasonLabel!,
                tone: CatchBadgeTone.success,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
