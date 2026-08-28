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

/// Section-level interaction treatment for divided field groups.
///
/// A page publishes its responsive default. One complete divided field
/// section may override that policy, but an individual field cannot.
enum CatchDividedFieldInteraction { fullBleed, roundedTile }

/// Responsive defaults for divided field-section interaction.
///
/// This policy is based on the local page composition rather than the device
/// operating system. A wide viewport with one readable lane can therefore use
/// a different policy from a true split-pane composition.
@immutable
class CatchResponsiveFieldInteractionPolicy {
  const CatchResponsiveFieldInteractionPolicy({
    this.singleColumn = CatchDividedFieldInteraction.fullBleed,
    this.splitPane = CatchDividedFieldInteraction.roundedTile,
  });

  final CatchDividedFieldInteraction singleColumn;
  final CatchDividedFieldInteraction splitPane;
}

/// Owner of the external corners around field interaction chrome.
///
/// [roundedTile] means the field paints its own complete rounded silhouette.
/// [sectionClipped] means an ancestor section owns one rounded clip for the
/// complete group, so each descendant paints a rectangular internal band.
/// [fullBleedBand] means a divided section paints one rectangular band to the
/// nearest page- or lane-owned interaction plane.
@internal
enum CatchFieldInteractionShape { roundedTile, sectionClipped, fullBleedBand }

/// Internal page/lane paint extent published by semantic body primitives.
///
/// The resolved values are the horizontal distance from padded content to the
/// interaction plane. Nested page-body primitives accumulate their insets, so
/// a field never reads viewport size or subtracts `screenPx` itself.
@internal
class CatchFieldInteractionPlaneScope extends InheritedWidget {
  const CatchFieldInteractionPlaneScope({
    super.key,
    required this.outsets,
    required super.child,
  });

  final EdgeInsets outsets;

  static EdgeInsets outsetsOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchFieldInteractionPlaneScope>()
          ?.outsets ??
      EdgeInsets.zero;

  @override
  bool updateShouldNotify(CatchFieldInteractionPlaneScope oldWidget) =>
      outsets != oldWidget.outsets;
}

/// Internal responsive policy scope published by section-page composition.
@internal
class CatchDividedFieldInteractionScope extends InheritedWidget {
  const CatchDividedFieldInteractionScope({
    super.key,
    required this.interaction,
    required super.child,
  });

  final CatchDividedFieldInteraction interaction;

  static CatchDividedFieldInteractionScope? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<CatchDividedFieldInteractionScope>();

  static CatchDividedFieldInteraction interactionOf(BuildContext context) =>
      maybeOf(context)?.interaction ?? CatchDividedFieldInteraction.roundedTile;

  @override
  bool updateShouldNotify(CatchDividedFieldInteractionScope oldWidget) =>
      interaction != oldWidget.interaction;
}

/// Ambient contract for field-row content and interaction geometry.
///
/// By default a [CatchField] row insets itself horizontally so it can sit
/// directly on a background or inside an unpadded surface. A container that
/// owns the horizontal gutter itself (e.g. [CatchSection.divided]) publishes
/// [CatchFieldGutterOwnership.container], and every field row below it drops
/// its own horizontal inset so content, trailing affordances, and
/// container-drawn dividers all share the container's edges.
///
/// [interactionOutsets] is independent from the content gutter. It lets a
/// containing section publish the exact horizontal paint extent for pressed,
/// active, and focus chrome. [interactionShape] declares whether the field owns
/// a tile, inherits one section clip, or reaches a page interaction plane.
/// Contained field sections use one hairline of outset so the child ring and
/// outer perimeter occupy the same coordinate instead of painting adjacent
/// vertical strokes. Full-bleed sections inherit their page/lane outsets.
@internal
class CatchFieldGeometryScope extends InheritedWidget {
  const CatchFieldGeometryScope({
    super.key,
    required this.gutterOwnership,
    this.interactionOutsets,
    this.interactionShape = CatchFieldInteractionShape.roundedTile,
    required super.child,
  });

  final CatchFieldGutterOwnership gutterOwnership;
  final EdgeInsets? interactionOutsets;
  final CatchFieldInteractionShape interactionShape;

  static CatchFieldGeometryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatchFieldGeometryScope>();

  static CatchFieldGutterOwnership gutterOwnershipOf(BuildContext context) =>
      maybeOf(context)?.gutterOwnership ?? CatchFieldGutterOwnership.field;

  static CatchFieldInteractionShape interactionShapeOf(BuildContext context) =>
      maybeOf(context)?.interactionShape ??
      CatchFieldInteractionShape.roundedTile;

  static EdgeInsets interactionOutsetsOf(BuildContext context) {
    final scope = maybeOf(context);
    final explicitOutsets = scope?.interactionOutsets;
    if (explicitOutsets != null) return explicitOutsets;
    return switch (scope?.interactionShape) {
      CatchFieldInteractionShape.fullBleedBand =>
        CatchFieldInteractionPlaneScope.outsetsOf(context),
      CatchFieldInteractionShape.sectionClipped => const EdgeInsets.symmetric(
        horizontal: CatchStroke.hairline,
      ),
      CatchFieldInteractionShape.roundedTile => const EdgeInsets.symmetric(
        horizontal: CatchFieldTokens.dividedRowBleed,
      ),
      null => EdgeInsets.zero,
    };
  }

  @override
  bool updateShouldNotify(CatchFieldGeometryScope oldWidget) =>
      gutterOwnership != oldWidget.gutterOwnership ||
      interactionOutsets != oldWidget.interactionOutsets ||
      interactionShape != oldWidget.interactionShape;
}
