import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton_effect.dart';
import 'package:catch_ui/src/patterns/catch_skeleton_variant.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Skeleton loading placeholders with a shimmer animation.
///
/// Use these instead of `CatchLoadingIndicator` when the content shape is
/// known — skeletons feel faster than spinners and reduce layout shift when
/// data arrives.
///
/// **Named constructors:**
/// - [CatchSkeleton.card] — rounded rectangle matching `CatchSurface` shape
/// - [CatchSkeleton.box] — fixed-size rounded rectangle for icons/pills
/// - [CatchSkeleton.text] — single text line
/// - [CatchSkeleton.textBlock] — multi-line paragraph
/// - [CatchSkeleton.circle] — circular avatar placeholder
/// - [CatchSkeleton.custom] — freeform child with shimmer overlay
///
/// - [CatchSkeleton.content] — derive the shape from a real composition
/// - [CatchSkeleton.cards] — repeated cards
/// - [CatchSkeleton.rows], [CatchSkeleton.mediaRows], [CatchSkeleton.iconRows]
///   — repeated content rows
/// - [CatchSkeleton.boxes] — equal-width control placeholders
/// - [CatchSkeleton.chips] — wrapping chip placeholders
///
/// All constructors use the shared Skeletonizer effect and Catch-themed colors.
/// Reduce Motion keeps the placeholders static; temporary labels and controls
/// are excluded from accessibility and interaction while loading.
class CatchSkeleton extends StatelessWidget {
  const CatchSkeleton._({required this.child})
    : variant = CatchSkeletonVariant.shape,
      enabled = true,
      _recipe = null;

  /// Derive placeholders from the real composition, restoring it when disabled.
  const CatchSkeleton.content({
    super.key,
    required Widget this.child,
    this.enabled = true,
  }) : variant = CatchSkeletonVariant.content,
       _recipe = null;

  /// A vertical list of card placeholders.
  const CatchSkeleton.cards({
    super.key,
    int count = 3,
    double height = CatchLayout.skeletonCardHeight,
    double spacing = CatchSpacing.s3,
  }) : _recipe = (count: count, height: height, spacing: spacing),
       variant = CatchSkeletonVariant.cards,
       child = null,
       enabled = true;

  /// Avatar rows with an optional title and dividers.
  const CatchSkeleton.rows({
    super.key,
    int count = 3,
    double? titleWidth,
    bool divided = false,
  }) : _recipe = (
         count: count,
         titleWidth: titleWidth,
         divided: divided,
         leading: _RowLeading.avatar,
       ),
       variant = CatchSkeletonVariant.rows,
       child = null,
       enabled = true;

  /// Media-tile rows with an optional title and dividers.
  const CatchSkeleton.mediaRows({
    super.key,
    int count = 3,
    double? titleWidth,
    bool divided = false,
  }) : _recipe = (
         count: count,
         titleWidth: titleWidth,
         divided: divided,
         leading: _RowLeading.mediaTile,
       ),
       variant = CatchSkeletonVariant.mediaRows,
       child = null,
       enabled = true;

  /// Compact icon rows with an optional title and dividers.
  const CatchSkeleton.iconRows({
    super.key,
    int count = 3,
    double? titleWidth,
    bool divided = false,
  }) : _recipe = (
         count: count,
         titleWidth: titleWidth,
         divided: divided,
         leading: _RowLeading.icon,
       ),
       variant = CatchSkeletonVariant.iconRows,
       child = null,
       enabled = true;

  /// Equal-width boxes reserve a compact control or action row.
  const CatchSkeleton.boxes({
    super.key,
    int count = 2,
    required double height,
    double radius = CatchRadius.md,
    double gap = CatchSpacing.s3,
  }) : _recipe = (count: count, height: height, radius: radius, gap: gap),
       variant = CatchSkeletonVariant.boxes,
       child = null,
       enabled = true;

  /// Wrapping placeholder pills with token-owned widths.
  const CatchSkeleton.chips({super.key, double height = CatchSpacing.s9})
    : _recipe = (height: height),
      variant = CatchSkeletonVariant.chips,
      child = null,
      enabled = true;

  /// Rounded-rectangle card placeholder.
  ///
  /// Defaults to full width with a 120 px height — a reasonable proxy for a
  /// `CatchSurface` or another content shell.
  factory CatchSkeleton.card({
    double? width,
    double height = CatchLayout.skeletonCardHeight,
  }) {
    return CatchSkeleton._(
      child: Builder(
        builder: (context) => Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: CatchTokens.of(context).raised,
            borderRadius: BorderRadius.circular(CatchRadius.md),
          ),
        ),
      ),
    );
  }

  /// Fixed-size rounded rectangle placeholder.
  factory CatchSkeleton.box({
    double? width,
    required double height,
    double radius = CatchRadius.xs,
    BorderRadiusGeometry? borderRadius,
    Color? borderColor,
  }) {
    return CatchSkeleton._(
      child: Builder(
        builder: (context) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: CatchTokens.of(context).raised,
            borderRadius:
                borderRadius ?? BorderRadius.all(Radius.circular(radius)),
            border: borderColor == null ? null : Border.all(color: borderColor),
          ),
        ),
      ),
    );
  }

  /// Single text line placeholder.
  factory CatchSkeleton.text({double width = double.infinity}) {
    return CatchSkeleton._(
      child: Builder(
        builder: (context) => Container(
          width: width,
          height: CatchLayout.skeletonTextHeight,
          decoration: BoxDecoration(
            color: CatchTokens.of(context).raised,
            borderRadius: BorderRadius.circular(CatchRadius.xs),
          ),
        ),
      ),
    );
  }

  /// Multi-line text block placeholder.
  ///
  /// Renders [lines] rows with decreasing width (last line at 60%).
  factory CatchSkeleton.textBlock({int lines = 3}) {
    return CatchSkeleton._(
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < lines - 1 ? CatchSpacing.s2 : CatchSpacing.s0,
                ),
                child: FractionallySizedBox(
                  widthFactor: i == lines - 1 ? 0.6 : 1.0,
                  child: Container(
                    height: CatchLayout.skeletonTextHeight,
                    decoration: BoxDecoration(
                      color: CatchTokens.of(context).raised,
                      borderRadius: BorderRadius.circular(CatchRadius.xs),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Circular avatar placeholder.
  factory CatchSkeleton.circle({
    double size = CatchLayout.skeletonCircleExtent,
  }) {
    return CatchSkeleton._(
      child: Builder(
        builder: (context) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: CatchTokens.of(context).raised,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// Freeform skeleton — wraps [child] in a shimmer overlay.
  ///
  /// Use when none of the named constructors match the content shape.
  /// The child's painted shape receives the shared loading effect.
  factory CatchSkeleton.custom({required Widget child}) {
    return CatchSkeleton._(child: child);
  }

  /// Selected recipe; constructors expose only the arguments that it supports.
  final CatchSkeletonVariant variant;
  final Widget? child;
  final bool enabled;
  final Object? _recipe;

  @override
  Widget build(BuildContext context) {
    switch (_recipe) {
      case (count: int count, height: double height, spacing: double spacing):
        return Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              CatchSkeleton.card(height: height),
              if (i < count - 1) SizedBox(height: spacing),
            ],
          ],
        );
      case (
        count: int count,
        titleWidth: double? titleWidth,
        divided: bool divided,
        leading: _RowLeading leading,
      ):
        final t = CatchTokens.of(context);
        return CatchSurface(
          borderColor: t.line,
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (titleWidth case final width?) ...[
                CatchSkeleton.text(width: width),
                gapH14,
              ],
              for (var i = 0; i < count; i++) ...[
                Row(
                  children: [
                    switch (leading) {
                      _RowLeading.mediaTile => CatchSkeleton.box(
                        width: CatchLayout.skeletonMediaTileExtent,
                        height: CatchLayout.skeletonMediaTileExtent,
                        radius: CatchRadius.sm,
                      ),
                      _RowLeading.avatar => CatchSkeleton.circle(
                        size: CatchLayout.skeletonAvatarCompactExtent,
                      ),
                      _RowLeading.icon => CatchSkeleton.box(
                        width: CatchIcon.md,
                        height: CatchIcon.md,
                        radius: CatchRadius.sm,
                      ),
                    },
                    gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CatchSkeleton.text(
                            width: i.isEven
                                ? CatchLayout.skeletonTextBodyLongWidth
                                : CatchLayout.skeletonTextSecondaryWidth,
                          ),
                          gapH6,
                          CatchSkeleton.text(
                            width: CatchLayout.skeletonTextDetailWidth,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i < count - 1)
                  if (divided) ...[
                    gapH14,
                    const SizedBox(
                      width: double.infinity,
                      child: CatchDivider(),
                    ),
                    gapH14,
                  ] else
                    gapH14,
              ],
            ],
          ),
        );
      case (
        count: int count,
        height: double height,
        radius: double radius,
        gap: double gap,
      ):
        return Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              Expanded(
                child: CatchSkeleton.box(height: height, radius: radius),
              ),
              if (i < count - 1) SizedBox(width: gap),
            ],
          ],
        );
      case (height: double height):
        return Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchSkeleton.box(
              width: CatchLayout.skeletonChipMediumWidth,
              height: height,
              radius: CatchRadius.pill,
            ),
            CatchSkeleton.box(
              width: CatchLayout.skeletonChipWideWidth,
              height: height,
              radius: CatchRadius.pill,
            ),
            CatchSkeleton.box(
              width: CatchLayout.skeletonChipNarrowWidth,
              height: height,
              radius: CatchRadius.pill,
            ),
          ],
        );
      case null:
        return ExcludeSemantics(
          excluding: enabled,
          child: variant == CatchSkeletonVariant.content
              ? Skeletonizer(
                  enabled: enabled,
                  effect: catchSkeletonEffect(context),
                  ignoreContainers: true,
                  child: child!,
                )
              : Skeletonizer.zone(
                  effect: catchSkeletonEffect(context),
                  child: Skeleton.shade(child: child!),
                ),
        );
      default:
        throw StateError('Unknown internal skeleton recipe');
    }
  }
}

enum _RowLeading { mediaTile, avatar, icon }
