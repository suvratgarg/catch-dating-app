import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton_effect.dart';
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
/// All constructors use the shared Skeletonizer effect and Catch-themed colors.
/// Reduce Motion keeps the placeholders static; temporary labels and controls
/// are excluded from accessibility and interaction while loading.
class CatchSkeleton extends StatelessWidget {
  const CatchSkeleton._({required this.child});

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

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Skeletonizer.zone(
        effect: catchSkeletonEffect(context),
        child: Skeleton.shade(child: child),
      ),
    );
  }
}
