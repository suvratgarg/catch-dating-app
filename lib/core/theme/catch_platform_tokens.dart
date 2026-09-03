import 'package:catch_dating_app/core/theme/generated/catch_design_tokens.g.dart';
import 'package:flutter/foundation.dart';

/// Constant profile data selected by Flutter's native target. In profile and
/// release native builds, defaultTargetPlatform is a VM platform constant;
/// there is no device query or Theme lookup per widget. Debug overrides keep
/// both profiles testable. Web selects its browser platform at runtime.
///
/// iOS/macOS use the Apple profile; other targets use the Android baseline.
abstract final class CatchPlatformTokens {
  static bool get usesAppleMetrics => switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => true,
    _ => false,
  };

  static GeneratedCatchTypographyProfile get typography => usesAppleMetrics
      ? GeneratedCatchTypographyTokens.ios
      : GeneratedCatchTypographyTokens.android;

  static double get minimumInteractiveExtent => usesAppleMetrics
      ? GeneratedCatchInteractionTokens.iosMinimumExtent
      : GeneratedCatchInteractionTokens.androidMinimumExtent;
}
