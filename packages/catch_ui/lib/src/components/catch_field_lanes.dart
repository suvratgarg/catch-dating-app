import 'package:catch_ui/src/components/catch_divided_field_interaction.dart';
import 'package:catch_ui/src/components/catch_divided_field_interaction_scope.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_gutter_ownership.dart';
import 'package:catch_ui/src/components/catch_field_interaction_shape.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:flutter/material.dart';

/// Explicit composition boundary for reusable Field rows that do not own a
/// titled or surfaced `CatchSection`.
///
/// Use [CatchFieldLanes.single] when a small reusable widget returns one Field
/// row for a parent section. Use [CatchFieldLanes.divided] when this boundary
/// owns a compact group and therefore also owns the separators between rows.
/// This keeps field gutter and divider ownership visible in the widget tree
/// without introducing another surface.
class CatchFieldLanes extends StatelessWidget {
  const CatchFieldLanes.single({super.key, required this.child})
    : children = const [];

  /// Declares field-lane ownership around a specialized layout whose spacing
  /// is intentionally not a simple divided row list (for example, a phone
  /// field paired with a country-code control).
  const CatchFieldLanes.custom({super.key, required this.child})
    : children = const [];

  const CatchFieldLanes.divided({super.key, required this.children})
    : assert(children.length > 0),
      child = null;

  final List<Widget> children;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final rowChildren = children;
    final content = rowChildren.isEmpty
        ? child!
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < rowChildren.length; index++) ...[
                if (index > 0) const CatchDivider.fieldRow(),
                rowChildren[index],
              ],
            ],
          );
    if (rowChildren.isEmpty) return content;
    return CatchFieldGeometryScope(
      gutterOwnership: CatchFieldGutterOwnership.container,
      interactionOutsets: CatchFieldGeometryScope.explicitInteractionOutsetsOf(
        context,
      ),
      interactionShape:
          CatchFieldGeometryScope.maybeInteractionShapeOf(context) ??
          (CatchDividedFieldInteractionScope.interactionOf(context) ==
                  CatchDividedFieldInteraction.fullBleed
              ? CatchFieldInteractionShape.fullBleedBand
              : CatchFieldInteractionShape.roundedTile),
      child: content,
    );
  }
}
