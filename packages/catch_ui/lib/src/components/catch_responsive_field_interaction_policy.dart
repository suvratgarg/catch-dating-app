import 'package:catch_ui/src/components/catch_divided_field_interaction.dart';
import 'package:flutter/foundation.dart';

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
