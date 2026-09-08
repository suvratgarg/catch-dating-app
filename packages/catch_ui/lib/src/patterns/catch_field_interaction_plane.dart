import 'package:catch_ui/src/components/catch_divided_field_interaction.dart';
import 'package:catch_ui/src/components/catch_divided_field_interaction_scope.dart';
import 'package:catch_ui/src/components/catch_field_interaction_plane_scope.dart';
import 'package:flutter/widgets.dart';

/// Internal page-body publication of accumulated field paint extents.
///
/// Semantic page and lane owners compose this with their padding. Feature
/// surfaces use those owners instead of constructing paint geometry directly.
class CatchFieldInteractionPlane extends StatelessWidget {
  const CatchFieldInteractionPlane({
    super.key,
    required this.padding,
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final resolved = padding.resolve(Directionality.of(context));
    final inherited = CatchFieldInteractionPlaneScope.outsetsOf(context);
    Widget result = CatchFieldInteractionPlaneScope(
      outsets: EdgeInsets.only(
        left: inherited.left + resolved.left,
        right: inherited.right + resolved.right,
      ),
      child: child,
    );
    if (CatchDividedFieldInteractionScope.maybeInteractionOf(context) == null) {
      result = CatchDividedFieldInteractionScope(
        interaction: CatchDividedFieldInteraction.fullBleed,
        child: result,
      );
    }
    return result;
  }
}
