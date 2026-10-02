import 'package:catch_tokens/src/primitives/catch_spacing.dart';
import 'package:catch_tokens/src/semantic/catch_layout.dart';

/// Shared native/Flutter launch and authentication presentation geometry.
abstract final class CatchStartupTokens {
  // Host reuses the existing transparent wordmark canvas. The larger extent
  // preserves its original lockup while giving the visible glyphs room to read.
  // These values also own the generated native iOS launch constraints.
  static const double hostStartupLogoExtent = 224.0;
  static const double hostStartupLogoTopInset =
      CatchSpacing.s16 + CatchSpacing.s2;
  static const double hostStartupLogoLeadingInset = CatchSpacing.s4;
  static const double hostStartupBrandStageExtent =
      hostStartupLogoTopInset + hostStartupLogoExtent + CatchSpacing.s6;
  static const double startupLogoExtent = 96.0;
  static const double startupBrandStageExtent = 120.0;
  static const double startupLogoTopInset = CatchSpacing.s2;
  static const double startupIndicatorExtent = CatchSpacing.s7;
  static const double startupIndicatorOffsetY = 76.0;
  static const double authContentEntranceOffset = CatchSpacing.s8;
  static const double authCountryCodeEmbeddedWidth = 116.0;
  static const double authOtpDigitHeight = CatchLayout.controlCompactMinHeight;
  static const double authOtpDigitGap = CatchSpacing.s2;
}
