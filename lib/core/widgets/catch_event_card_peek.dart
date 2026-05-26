import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

/// Small image-left card used inside a horizontal rail (typically the map
/// peek state). Wider than [CatchEventCardCompact] is tall so a few fit in
/// the user's thumb sweep.
///
/// Selected state uses a subtle brand-tonal background and a 2px primary
/// border on the left edge — never a full primary outline (looks like a
/// validation error). The change in elevation also conveys selection.
class CatchEventCardPeek extends StatelessWidget {
  const CatchEventCardPeek({
    super.key,
    required this.title,
    required this.subtitle,
    required this.kickerLabel,
    required this.distanceLabel,
    required this.photoUrl,
    required this.pace,
    required this.activityKind,
    required this.selected,
    this.onTap,
    this.width = 264,
    this.height = 96,
  });

  final String title;
  final String subtitle;
  final String kickerLabel;
  final String? distanceLabel;
  final String? photoUrl;
  final PaceLevel pace;
  final ActivityKind activityKind;
  final bool selected;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final accentBar = AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      width: selected ? 3 : 0,
      color: selected ? t.primary : Colors.transparent,
    );

    return AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: selected ? t.primarySoft : t.surface,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        border: Border.all(color: t.line),
        boxShadow: selected ? CatchElevation.card : CatchElevation.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              accentBar,
              SizedBox(
                width: height,
                height: height,
                child: CatchEventThumbnail(
                  photoUrl: photoUrl,
                  pace: pace,
                  activityKind: activityKind,
                  scrim: CatchEventThumbnailScrim.none,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s3,
                    CatchSpacing.s3,
                    CatchSpacing.s3,
                    CatchSpacing.s3,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CatchKicker(
                              label: kickerLabel,
                              color: t.primary,
                              size: CatchKickerSize.sm,
                            ),
                          ),
                          if (distanceLabel != null) ...[
                            gapW6,
                            Text(
                              distanceLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CatchTextStyles.numericMeta(
                                context,
                                color: t.ink,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ),
                      gapH2,
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.titleS(context),
                      ),
                      gapH2,
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
