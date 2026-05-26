import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_hero.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

/// List-row event card used inside day-grouped feeds (Today, Tomorrow,
/// Saturday…). Photo runs along the left edge, content fills the right.
/// Designed to fit ~3–4 rows per phone screen.
class CatchEventCardCompact extends StatelessWidget {
  const CatchEventCardCompact({
    super.key,
    required this.title,
    required this.subtitle,
    required this.kickerLabel,
    required this.kickerTrailing,
    required this.meta,
    required this.distanceTrailing,
    required this.photoUrl,
    required this.pace,
    required this.activityKind,
    this.sash,
    this.priceLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String kickerLabel;
  final String? kickerTrailing;
  final List<CatchMetaEntry> meta;
  final CatchMetaEntry? distanceTrailing;
  final String? photoUrl;
  final PaceLevel pace;
  final ActivityKind activityKind;
  final CatchEventSashSpec? sash;
  final String? priceLabel;
  final VoidCallback? onTap;

  static const double _thumbWidth = 104;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.lg,
      elevation: CatchSurfaceElevation.card,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _thumbWidth,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CatchEventThumbnail(
                    photoUrl: photoUrl,
                    pace: pace,
                    activityKind: activityKind,
                    scrim: CatchEventThumbnailScrim.none,
                  ),
                  if (sash != null)
                    Positioned(
                      top: CatchSpacing.s2,
                      left: CatchSpacing.s2,
                      child: CatchCornerSash(
                        label: sash!.label,
                        icon: sash!.icon,
                        tone: sash!.tone,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s4,
                  CatchSpacing.s3,
                  CatchSpacing.s4,
                  CatchSpacing.s3,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CatchKicker(
                            label: kickerLabel,
                            trailing: kickerTrailing,
                            color: t.primary,
                            size: CatchKickerSize.sm,
                          ),
                        ),
                        if (priceLabel != null) ...[
                          gapW8,
                          Text(
                            priceLabel!,
                            style: CatchTextStyles.labelL(
                              context,
                              color: priceLabel == 'Free' ? t.success : t.ink,
                            ),
                          ),
                        ],
                      ],
                    ),
                    gapH4,
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH2,
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                    gapH8,
                    CatchMetaDotRow(
                      entries: meta,
                      trailing: distanceTrailing,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
