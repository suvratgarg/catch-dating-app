import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loading placeholders with a shimmer animation.
///
/// Use these instead of [CatchLoadingIndicator] when the content shape is
/// known — skeletons feel faster than spinners and reduce layout shift when
/// data arrives.
///
/// **Named constructors:**
/// - [CatchSkeleton.card] — rounded rectangle matching [CatchSurface] shape
/// - [CatchSkeleton.text] — single text line
/// - [CatchSkeleton.textBlock] — multi-line paragraph
/// - [CatchSkeleton.circle] — circular avatar placeholder
/// - [CatchSkeleton.custom] — freeform child with shimmer overlay
///
/// All constructors render inside [Shimmer] from the `shimmer` package,
/// using Catch-themed colors (warm base, slightly lighter highlight).
class CatchSkeleton extends StatelessWidget {
  const CatchSkeleton._({required this.child});

  /// Rounded-rectangle card placeholder.
  ///
  /// Defaults to full width with a 120 px height — a reasonable proxy for a
  /// [RunCard] or [CatchSurface].
  factory CatchSkeleton.card({double? width, double height = 120}) {
    return CatchSkeleton._(
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  /// Single text line placeholder.
  factory CatchSkeleton.text({double width = double.infinity}) {
    return CatchSkeleton._(
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Multi-line text block placeholder.
  ///
  /// Renders [lines] rows with decreasing width (last line at 60%).
  factory CatchSkeleton.textBlock({int lines = 3}) {
    return CatchSkeleton._(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i < lines - 1 ? 8 : 0),
              child: FractionallySizedBox(
                widthFactor: i == lines - 1 ? 0.6 : 1.0,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Circular avatar placeholder.
  factory CatchSkeleton.circle({double size = 48}) {
    return CatchSkeleton._(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Freeform skeleton — wraps [child] in a shimmer overlay.
  ///
  /// Use when none of the named constructors match the content shape.
  /// The child should use `Colors.white` for its decoration fill so the
  /// shimmer gradient is visible.
  factory CatchSkeleton.custom({required Widget child}) {
    return CatchSkeleton._(child: child);
  }

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Shimmer(
      gradient: LinearGradient(
        colors: [
          t.raised,
          t.surface,
          t.raised,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// A list of skeleton cards with a [count] and optional spacing.
///
/// Convenience widget for swipe hubs, dashboards, and club lists.
class CatchSkeletonList extends StatelessWidget {
  const CatchSkeletonList({
    super.key,
    this.count = 3,
    this.height = 120,
    this.spacing = 12,
  });

  final int count;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          CatchSkeleton.card(height: height),
          if (i < count - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
