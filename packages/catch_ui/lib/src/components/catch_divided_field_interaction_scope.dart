import 'package:catch_ui/src/components/catch_divided_field_interaction.dart';
import 'package:flutter/widgets.dart';

/// Internal responsive policy scope published by section-page composition.
class CatchDividedFieldInteractionScope extends InheritedWidget {
  const CatchDividedFieldInteractionScope({
    super.key,
    required this.interaction,
    required super.child,
  });

  final CatchDividedFieldInteraction interaction;

  static CatchDividedFieldInteraction? maybeInteractionOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<CatchDividedFieldInteractionScope>()
      ?.interaction;

  static CatchDividedFieldInteraction interactionOf(BuildContext context) =>
      maybeInteractionOf(context) ?? CatchDividedFieldInteraction.roundedTile;

  @override
  bool updateShouldNotify(CatchDividedFieldInteractionScope oldWidget) =>
      interaction != oldWidget.interaction;
}
