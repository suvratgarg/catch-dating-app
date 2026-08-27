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

/// Owner of the horizontal content gutter around a field row.
enum CatchFieldGutterOwnership { field, container }

/// Owner of the external corners around field interaction chrome.
///
/// [rounded] means the field paints its own complete rounded silhouette.
/// [sectionClipped] means an ancestor section owns one rounded clip for the
/// complete group, so each descendant paints a rectangular internal band.
enum CatchFieldInteractionShape { rounded, sectionClipped }

/// Ambient contract for field-row content and interaction geometry.
///
/// By default a [CatchField] row insets itself horizontally so it can sit
/// directly on a background or inside an unpadded surface. A container that
/// owns the horizontal gutter itself (e.g. [CatchSection.divided]) publishes
/// [CatchFieldGutterOwnership.container], and every field row below it drops
/// its own horizontal inset so content, trailing affordances, and
/// container-drawn dividers all share the container's edges.
///
/// [interactionBleed] is independent from the content gutter. It lets a
/// containing section publish how far pressed and active chrome must overlap
/// its edge. [interactionShape] declares whether the field owns its corners or
/// inherits them from one section clip. Contained field sections use one
/// hairline of bleed so the child ring and outer perimeter occupy the same
/// geometry instead of painting adjacent vertical strokes. When omitted,
/// container-owned gutters retain the divided-section tile bleed.
class CatchFieldGeometryScope extends InheritedWidget {
  const CatchFieldGeometryScope({
    super.key,
    required this.gutterOwnership,
    this.interactionBleed,
    this.interactionShape = CatchFieldInteractionShape.rounded,
    required super.child,
  }) : assert(interactionBleed == null || interactionBleed >= 0);

  final CatchFieldGutterOwnership gutterOwnership;
  final double? interactionBleed;
  final CatchFieldInteractionShape interactionShape;

  static CatchFieldGeometryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatchFieldGeometryScope>();

  static CatchFieldGutterOwnership gutterOwnershipOf(BuildContext context) =>
      maybeOf(context)?.gutterOwnership ?? CatchFieldGutterOwnership.field;

  static CatchFieldInteractionShape interactionShapeOf(BuildContext context) =>
      maybeOf(context)?.interactionShape ?? CatchFieldInteractionShape.rounded;

  static double interactionBleedOf(BuildContext context) {
    final scope = maybeOf(context);
    return scope?.interactionBleed ??
        (scope?.gutterOwnership == CatchFieldGutterOwnership.container
            ? CatchFieldTokens.dividedRowBleed
            : 0.0);
  }

  @override
  bool updateShouldNotify(CatchFieldGeometryScope oldWidget) =>
      gutterOwnership != oldWidget.gutterOwnership ||
      interactionBleed != oldWidget.interactionBleed ||
      interactionShape != oldWidget.interactionShape;
}
