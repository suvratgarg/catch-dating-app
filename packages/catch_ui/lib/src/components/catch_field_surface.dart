import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_interaction_shape.dart';
import 'package:catch_ui/src/components/catch_field_motion.dart';
import 'package:flutter/material.dart';

/// Field interaction background, border, and shadow beneath its content.
///
/// The field owns gestures, focus, and expansion. This surface paints their
/// resolved states using the containing section's shape and horizontal outsets.
/// [WidgetState.selected] represents an active field (focused or expanded).
class CatchFieldSurface extends StatelessWidget {
  const CatchFieldSurface({
    super.key,
    required this.child,
    required this.pressedOverlayKey,
    this.states = const {},
  });

  final Widget child;
  final Key pressedOverlayKey;
  final Set<WidgetState> states;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final active = states.contains(WidgetState.selected);
    final focused = states.contains(WidgetState.focused);
    final pressed = states.contains(WidgetState.pressed);
    final interactionShape = CatchFieldGeometryScope.interactionShapeOf(
      context,
    );
    final interactionBorderRadius = switch (interactionShape) {
      CatchFieldInteractionShape.roundedTile => BorderRadius.circular(
        CatchFieldTokens.tileRadius,
      ),
      CatchFieldInteractionShape.sectionClipped ||
      CatchFieldInteractionShape.fullBleedBand => BorderRadius.zero,
    };
    final interactionBorder = CatchBorder.resolve(
      t,
      CatchBorderRole.boundary,
    ).all;
    final fullBleedFocusBorder = CatchBorder.resolve(
      t,
      CatchBorderRole.focus,
    ).all;
    final fullBleedFocused =
        interactionShape == CatchFieldInteractionShape.fullBleedBand &&
        focused &&
        !pressed;
    final activeDecoration = BoxDecoration(
      color: active && !pressed
          ? CatchFieldTokens.activeSurface(t)
          : Colors.transparent,
      borderRadius: interactionBorderRadius,
      // The active and pressed layers hand one stroke between them. This
      // prevents their animated decorations from ever stacking two outlines.
      border: fullBleedFocused
          ? fullBleedFocusBorder
          : active &&
                !pressed &&
                interactionShape != CatchFieldInteractionShape.fullBleedBand
          ? interactionBorder
          : null,
      boxShadow:
          active && interactionShape == CatchFieldInteractionShape.roundedTile
          ? CatchElevation.fieldActive(Theme.of(context).brightness)
          : CatchElevation.none,
    );
    final pressDecoration = BoxDecoration(
      color: pressed ? CatchFieldTokens.pressedSurface(t) : Colors.transparent,
      borderRadius: interactionBorderRadius,
      // A divided or standalone row owns its complete pressed silhouette.
      // A contained row inherits the section perimeter and stays a tint-only
      // internal band. A rounded row temporarily owns the one shared stroke
      // while pressed, whether or not it was already active.
      border:
          pressed && interactionShape == CatchFieldInteractionShape.roundedTile
          ? interactionBorder
          : null,
    );
    final overlayOutsets = CatchFieldGeometryScope.interactionOutsetsOf(
      context,
    );
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -overlayOutsets.left,
          right: -overlayOutsets.right,
          top: -CatchStroke.hairline,
          bottom: -CatchStroke.hairline,
          child: IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  key: pressedOverlayKey,
                  duration: catchFieldMotionDuration(
                    context,
                    pressed
                        ? CatchFieldTokens.pressIn
                        : CatchFieldTokens.pressOut,
                  ),
                  curve: CatchFieldTokens.curve,
                  decoration: pressDecoration,
                ),
                AnimatedContainer(
                  key: const ValueKey('catch-field-active-overlay'),
                  duration: catchFieldMotionDuration(
                    context,
                    active
                        ? CatchFieldTokens.standard
                        : CatchFieldTokens.pressOut,
                  ),
                  curve: CatchFieldTokens.curve,
                  decoration: activeDecoration,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
