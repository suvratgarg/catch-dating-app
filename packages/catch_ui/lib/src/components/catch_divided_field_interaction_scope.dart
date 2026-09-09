import 'package:catch_ui/src/components/catch_divided_field_interaction_scope_mode.dart';
import 'package:flutter/widgets.dart';

/// Internal responsive policy scope published by section-page composition.
class CatchDividedFieldInteractionScope extends InheritedWidget {
  const CatchDividedFieldInteractionScope({
    super.key,
    required this.interaction,
    required super.child,
  });

  final CatchDividedFieldInteractionScopeMode interaction;

  static CatchDividedFieldInteractionScopeMode? maybeInteractionOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<CatchDividedFieldInteractionScope>()
      ?.interaction;

  static CatchDividedFieldInteractionScopeMode interactionOf(
    BuildContext context,
  ) =>
      maybeInteractionOf(context) ??
      CatchDividedFieldInteractionScopeMode.roundedTile;

  @override
  bool updateShouldNotify(CatchDividedFieldInteractionScope oldWidget) =>
      interaction != oldWidget.interaction;
}
