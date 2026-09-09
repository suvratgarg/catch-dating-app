import 'package:catch_ui/src/components/catch_divided_field_interaction.dart';
import 'package:catch_ui/src/components/catch_divided_field_interaction_scope.dart';
import 'package:flutter/widgets.dart';

/// Internal page/lane paint extent published by semantic body primitives.
///
/// The resolved values are the horizontal distance from padded content to the
/// interaction plane. Nested page-body primitives accumulate their insets, so
/// a field never reads viewport size or subtracts `screenPx` itself.
class CatchFieldInteractionPlaneScope extends InheritedWidget {
  const CatchFieldInteractionPlaneScope({
    super.key,
    required this.outsets,
    required super.child,
  });

  /// Accumulates a semantic body's horizontal insets and supplies full-bleed
  /// interaction only when an ancestor has not already selected a policy.
  /// Read context at the mounting point, below any enclosing body scope.
  factory CatchFieldInteractionPlaneScope.fromPadding({
    Key? key,
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget child,
  }) {
    final resolved = padding.resolve(Directionality.of(context));
    final inherited = outsetsOf(context);
    return CatchFieldInteractionPlaneScope(
      key: key,
      outsets: EdgeInsets.only(
        left: inherited.left + resolved.left,
        right: inherited.right + resolved.right,
      ),
      child:
          CatchDividedFieldInteractionScope.maybeInteractionOf(context) == null
          ? CatchDividedFieldInteractionScope(
              interaction: CatchDividedFieldInteraction.fullBleed,
              child: child,
            )
          : child,
    );
  }

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
