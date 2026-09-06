import 'package:catch_tokens/generated/catch_design_tokens.g.dart';

/// Shared rhythm for readable identity and evidence rows. The section owns
/// outer gutters and separators; each row owns its local vertical breathing room.
abstract final class CatchRecordTokens {
  static const avatarExtent = GeneratedCatchLayoutTokens.recordAvatarExtent;
  static const leadingGap = GeneratedCatchLayoutTokens.recordLeadingGap;
  static const verticalPadding =
      GeneratedCatchLayoutTokens.recordVerticalPadding;
  static const titleGap = GeneratedCatchLayoutTokens.recordTitleGap;
  static const bodyGap = GeneratedCatchLayoutTokens.recordBodyGap;
  static const largeTextBreakpoint = 1.5;
  static const statusMaxWidthFraction = 0.45;
  static const statusHorizontalPadding =
      GeneratedCatchLayoutTokens.statusHorizontalPadding;
  static const statusVerticalPadding =
      GeneratedCatchLayoutTokens.statusVerticalPadding;
  static const selectionHorizontalPadding =
      GeneratedCatchLayoutTokens.selectionHorizontalPadding;
  static const selectionVerticalPadding =
      GeneratedCatchLayoutTokens.selectionVerticalPadding;
}
