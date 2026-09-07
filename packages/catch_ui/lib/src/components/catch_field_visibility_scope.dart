import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/widgets.dart';

/// Ambient visibility contract for disclosure fields inside obstructed scroll
/// surfaces.
///
/// A shell that overlays navigation on top of its body publishes the covered
/// bottom extent here. When a `CatchField` opens, it asks the nearest viewport
/// to reveal its commit controls plus this clearance, keeping the entire
/// interaction one gesture even when the field starts near the screen edge.
class CatchFieldVisibilityScope extends InheritedWidget {
  const CatchFieldVisibilityScope({
    super.key,
    required this.bottomObstruction,
    this.revealPadding = CatchSpacing.s2,
    required super.child,
  }) : assert(bottomObstruction >= 0),
       assert(revealPadding >= 0);

  final double bottomObstruction;
  final double revealPadding;

  /// Covered bottom extent, or zero when the shell has no obstruction.
  static double bottomObstructionOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchFieldVisibilityScope>()
          ?.bottomObstruction ??
      0;

  /// Clearance a disclosure needs beyond its commit controls.
  static double bottomClearanceOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CatchFieldVisibilityScope>();
    return (scope?.bottomObstruction ?? 0) +
        (scope?.revealPadding ?? CatchSpacing.s2);
  }

  @override
  bool updateShouldNotify(CatchFieldVisibilityScope oldWidget) =>
      bottomObstruction != oldWidget.bottomObstruction ||
      revealPadding != oldWidget.revealPadding;
}
