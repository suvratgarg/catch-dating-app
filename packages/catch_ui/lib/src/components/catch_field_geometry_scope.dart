import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_gutter_ownership.dart';
import 'package:catch_ui/src/components/catch_field_interaction_plane_scope.dart';
import 'package:catch_ui/src/components/catch_field_interaction_shape.dart';
import 'package:flutter/widgets.dart';

/// Ambient contract for field-row content and interaction geometry.
///
/// By default a `CatchField` row insets itself horizontally so it can sit
/// directly on a background or inside an unpadded surface. A container that
/// owns the horizontal gutter itself (e.g. `CatchSection.divided`) publishes
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

  static CatchFieldGutterOwnership gutterOwnershipOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchFieldGeometryScope>()
          ?.gutterOwnership ??
      CatchFieldGutterOwnership.field;

  /// The inherited shape, retaining absence so a lane can use page policy.
  static CatchFieldInteractionShape? maybeInteractionShapeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<CatchFieldGeometryScope>()
      ?.interactionShape;

  static CatchFieldInteractionShape interactionShapeOf(BuildContext context) =>
      maybeInteractionShapeOf(context) ??
      CatchFieldInteractionShape.roundedTile;

  /// Explicit outsets only; descendant lanes must not freeze a resolved default.
  static EdgeInsets? explicitInteractionOutsetsOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchFieldGeometryScope>()
          ?.interactionOutsets;

  static EdgeInsets interactionOutsetsOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CatchFieldGeometryScope>();
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
