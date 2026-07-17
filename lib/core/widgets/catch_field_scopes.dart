part of 'catch_field.dart';

/// Ambient visibility contract for disclosure fields inside obstructed scroll
/// surfaces.
///
/// A shell that overlays navigation on top of its body publishes the covered
/// bottom extent here. When a [CatchField] opens, it asks the nearest viewport
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

  static CatchFieldVisibilityScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatchFieldVisibilityScope>();

  @override
  bool updateShouldNotify(CatchFieldVisibilityScope oldWidget) =>
      bottomObstruction != oldWidget.bottomObstruction ||
      revealPadding != oldWidget.revealPadding;
}

/// Ambient contract for who owns a field row's horizontal gutter and active
/// edge geometry.
///
/// By default a [CatchField] row insets itself horizontally so it can sit
/// directly on a background or inside an unpadded surface. A container that
/// owns the horizontal gutter itself (e.g. [CatchSection.divided]) publishes
/// `flush: true`, and every field row below it drops its own horizontal
/// inset so content, trailing affordances, and container-drawn dividers all
/// share the container's edges.
///
/// [activeOverlayBleed] is independent from the content inset. It lets a
/// containing section publish how far active row chrome must overlap its edge.
/// Contained FieldSections use one hairline so the child ring and outer
/// perimeter occupy the same geometry instead of painting adjacent vertical
/// strokes. When omitted, flush rows retain their divided-section tile bleed.
class CatchFieldInsetScope extends InheritedWidget {
  const CatchFieldInsetScope({
    super.key,
    required this.flush,
    this.activeOverlayBleed,
    required super.child,
  }) : assert(activeOverlayBleed == null || activeOverlayBleed >= 0);

  final bool flush;
  final double? activeOverlayBleed;

  static CatchFieldInsetScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatchFieldInsetScope>();

  static bool flushOf(BuildContext context) => _of(context)?.flush ?? false;

  static double activeOverlayBleedOf(BuildContext context) {
    final scope = _of(context);
    return scope?.activeOverlayBleed ??
        (scope?.flush == true ? CatchFieldTokens.dividedRowBleed : 0.0);
  }

  @override
  bool updateShouldNotify(CatchFieldInsetScope oldWidget) =>
      flush != oldWidget.flush ||
      activeOverlayBleed != oldWidget.activeOverlayBleed;
}
