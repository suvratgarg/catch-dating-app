import 'package:catch_tokens/generated/catch_design_tokens.g.dart';

/// Layout spacing constants from the design-system 4-point scale.
abstract final class CatchSpacing {
  static const double s0 = GeneratedCatchSpacingTokens.s0;
  static const double s1 = GeneratedCatchSpacingTokens.s1;
  static const double s2 = GeneratedCatchSpacingTokens.s2;
  static const double s3 = GeneratedCatchSpacingTokens.s3;
  static const double s4 = GeneratedCatchSpacingTokens.s4;
  static const double s5 = GeneratedCatchSpacingTokens.s5;
  static const double s6 = GeneratedCatchSpacingTokens.s6;
  static const double s7 = GeneratedCatchSpacingTokens.s7;
  static const double s8 = GeneratedCatchSpacingTokens.s8;
  static const double s9 = GeneratedCatchSpacingTokens.s9;
  static const double s10 = GeneratedCatchSpacingTokens.s10;
  static const double s11 = GeneratedCatchSpacingTokens.s11;
  static const double s12 = GeneratedCatchSpacingTokens.s12;
  static const double s16 = GeneratedCatchSpacingTokens.s16;

  /// Component-internal micro spacing. Use only inside dense controls, charts,
  /// typographic underlines, and tiny badges where the 4-point rhythm is too
  /// coarse.
  static const double micro2 = GeneratedCatchSpacingTokens.micro2;
  static const double micro3 = GeneratedCatchSpacingTokens.micro3;
  static const double micro6 = GeneratedCatchSpacingTokens.micro6;
  static const double micro10 = GeneratedCatchSpacingTokens.micro10;
  static const double micro14 = GeneratedCatchSpacingTokens.micro14;
  static const double micro18 = GeneratedCatchSpacingTokens.micro18;

  /// App-wide page gutter and body padding from the design handoff.
  static const double screenPx = GeneratedCatchLayoutTokens.pageGutter;
  static const double screenPt = GeneratedCatchLayoutTokens.pageBodyStart;
  static const double screenPb = CatchSpacing.s5;
}
