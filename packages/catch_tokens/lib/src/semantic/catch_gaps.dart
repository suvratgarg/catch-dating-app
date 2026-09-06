import 'package:catch_tokens/src/primitives/catch_spacing.dart';

/// Semantic vertical and horizontal gaps for common layout relationships.
///
/// Use [CatchSpacing] for primitive math inside reusable components. Feature
/// screens should prefer these relationship tokens so the code says why a gap
/// exists, not only how large it is.
abstract final class CatchGaps {
  /// Tight icon/label or metadata pair spacing.
  static const double inline = CatchSpacing.s2;

  /// Gap between a screen-header title and the kicker/subtitle paired with it
  /// (browse-header title→subtitle, Home dashboard eyebrow→title). Centralises
  /// the subtitle-to-title relationship of the shared root-screen header rhythm.
  static const double headerTitleToSubtitle = CatchSpacing.s1;

  /// Distance between closely related rows inside the same content cluster.
  static const double related = CatchSpacing.s3;

  /// Standard gap between controls in one form or settings group.
  static const double formField = CatchSpacing.s4;

  /// Default gap between peer sections in a page body.
  static const double section = CatchSpacing.s6;

  /// Extra separation between major page regions.
  static const double majorSection = CatchSpacing.s8;
}
