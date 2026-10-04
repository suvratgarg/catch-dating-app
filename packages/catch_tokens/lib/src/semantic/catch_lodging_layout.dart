import 'package:catch_tokens/src/primitives/catch_spacing.dart';

/// Layout dimensions for dated room allocation maps.
abstract final class CatchLodgingLayout {
  /// Allow a room label and roommate names side by side.
  static const double mapColumnExtent = CatchSpacing.s16 * 2;
}
