import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

/// Hero-sized event card used as the lead item in a feed or as the editorial
/// pick of the day. Full-bleed photo with a bottom scrim, a top-corner status
/// sash, brand-orange caps time kicker, and a single dot-separated meta row.
///
/// This primitive owns the visual composition; callers pass the raw event
/// fields they want surfaced. It deliberately does NOT take an
/// `EventTileData` so it can be reused for hero positions outside the
/// existing event tile system.
class CatchEventCardHero extends StatelessWidget {
  const CatchEventCardHero({
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
    this.editorialSash,
    this.onTap,
    this.aspectRatio = 4 / 5,
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

  /// Top-start corner sash (`You're in`, `Saved`, `Hosted`).
  final CatchEventSashSpec? sash;

  /// Optional editorial sash (e.g. `TONIGHT'S PICK`) painted in the top-end
  /// corner; renders only when [sash] is null on that side.
  final String? editorialSash;

  /// Top-end price label. Painted over the scrim in white.
  final String? priceLabel;

  final VoidCallback? onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final scaffold = AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CatchEventThumbnail(
            photoUrl: photoUrl,
            pace: pace,
            activityKind: activityKind,
            scrim: CatchEventThumbnailScrim.bottom,
          ),
          Positioned(
            left: CatchSpacing.s4,
            right: CatchSpacing.s4,
            bottom: CatchSpacing.s5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchKicker(
                  label: kickerLabel,
                  trailing: kickerTrailing,
                  color: Colors.white.withValues(alpha: 0.92),
                  size: CatchKickerSize.md,
                ),
                gapH8,
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.heroHeadline(
                    context,
                    color: Colors.white,
                  ).copyWith(fontSize: 28, height: 1.08),
                ),
                gapH6,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.bodyLead(
                    context,
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
                gapH12,
                CatchMetaDotRow(
                  entries: meta,
                  trailing: distanceTrailing,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ],
            ),
          ),
          if (sash != null)
            Positioned(
              top: CatchSpacing.s3,
              left: CatchSpacing.s3,
              child: CatchCornerSash(
                label: sash!.label,
                icon: sash!.icon,
                tone: sash!.tone,
              ),
            ),
          if (priceLabel != null)
            Positioned(
              top: CatchSpacing.s3,
              right: CatchSpacing.s3,
              child: _PriceTag(label: priceLabel!),
            )
          else if (editorialSash != null)
            Positioned(
              top: CatchSpacing.s3,
              right: CatchSpacing.s3,
              child: CatchCornerSash(
                label: editorialSash!,
                tone: CatchSashTone.brand,
                alignment: CatchSashAlignment.topEnd,
              ),
            ),
        ],
      ),
    );

    return CatchSurface(
      radius: CatchRadius.lg,
      elevation: CatchSurfaceElevation.card,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: scaffold,
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s2,
        vertical: CatchSpacing.micro3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: CatchTextStyles.labelL(
          context,
          color: CatchTokens.of(context).ink,
        ),
      ),
    );
  }
}

/// Lightweight spec for the corner sash, kept inside this file because the
/// hero card is its primary caller; reuse [CatchCornerSash] directly for
/// other surfaces.
class CatchEventSashSpec {
  const CatchEventSashSpec({
    required this.label,
    this.icon,
    this.tone = CatchSashTone.brand,
  });

  final String label;
  final IconData? icon;
  final CatchSashTone tone;
}
