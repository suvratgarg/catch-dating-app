import 'dart:math' as math;

import 'package:catch_tokens/src/primitives/catch_spacing.dart';
import 'package:catch_tokens/src/semantic/catch_opacity.dart';
import 'package:flutter/material.dart';

/// Geometry for the Welcome word reel and its landing composition.
abstract final class CatchWelcomeTokens {
  static const double welcomeBrandMarkExtent = 52.0;
  static const double welcomeMaxWidth = 430.0;
  static const double welcomeReferenceWidth = 320.0;
  static const double welcomeMinHorizontalScale = 0.82;
  static const double welcomeReelRowHeight = 90.0;
  static const double welcomeReelRowHalfHeight = 45.0;
  static const double welcomeReelTop = 50.0;
  static const double welcomeReelHeight = 540.0;
  static const double welcomeReelFocus = 230.0;
  static const double welcomeReelCatchLeft = 24.0;
  static const double welcomeReelCatchLineTopOffset = 14.0;
  static const double welcomeReelCatchFocusTop =
      welcomeReelFocus -
      welcomeReelRowHalfHeight +
      welcomeReelCatchLineTopOffset;
  static const double welcomeReelObjectLeft = 116.0;
  static const double welcomeReelObjectRight = 18.0;
  static const double welcomeFocusLockupMaxWidth =
      welcomeReferenceWidth - welcomeReelCatchLeft - welcomeReelObjectRight;
  static const double welcomeReelMinRightInset = 12.0;
  static const double welcomeReelMaxTextScale = 1.10;
  static const double welcomeReelUnderlineGap = 2.0;
  static const double welcomeReelUnderlineThickness = 4.0;
  static const double welcomeReelDimRange =
      welcomeReelRowHeight * CatchOpacity.welcomeReelDimDistanceRows;
  static const double welcomeBodyTop = 340.0;
  static const double welcomeBodyHorizontalPadding = 26.0;
  static const double welcomeButtonsBottom = 30.0;
  static const double welcomeButtonGap = 10.0;
  static const double welcomeCtaApproxHeight = 122.0;
  static const double welcomeMinBodyToCtaGap = 16.0;
  static const double welcomeHeadlineToBodyGap = 66.0;
  static const double welcomeRevealOffsetY = 16.0;

  static double welcomeReelLandingOffset(int index) =>
      (index * welcomeReelRowHeight) +
      welcomeReelRowHalfHeight -
      welcomeReelFocus;

  static double welcomeReelHorizontalScale(double width) =>
      (width / welcomeReferenceWidth).clamp(welcomeMinHorizontalScale, 1.0);

  static double welcomeReelCatchLeftForWidth(double width) =>
      welcomeReelCatchLeft * welcomeReelHorizontalScale(width);

  static double welcomeReelObjectLeftForWidth(double width) =>
      welcomeReelObjectLeft * welcomeReelHorizontalScale(width);

  static double welcomeReelRightForWidth(double width) => math.max(
    welcomeReelMinRightInset,
    welcomeReelObjectRight * welcomeReelHorizontalScale(width),
  );

  static double welcomeReelTopFor(EdgeInsets mediaPadding) =>
      math.max(welcomeReelTop, mediaPadding.top + CatchSpacing.s1);

  static double welcomeReelCatchTopFor(EdgeInsets mediaPadding) =>
      welcomeReelTopFor(mediaPadding) + welcomeReelCatchFocusTop;

  static double welcomeReelRowCenter({
    required int rowIndex,
    required double trackOffset,
  }) =>
      (rowIndex * welcomeReelRowHeight) -
      trackOffset +
      welcomeReelRowHalfHeight;

  static bool welcomeReelRowIsFocused(double distance) =>
      distance.abs() < welcomeReelRowHalfHeight;
}
