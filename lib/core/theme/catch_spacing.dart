import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/widgets.dart';

export 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchSpacing;

/// Compatibility constants that bridge older `Sizes.p*` call sites to the
/// canonical Catch design-system spacing scale.
///
/// Prefer `CatchSpacing.s*` for new code when the value exists on the 4-point
/// scale and `CatchSpacing.micro*` for reviewed component-internal values.
abstract final class Sizes {
  static const double p2 = CatchSpacing.micro2;
  static const double p3 = CatchSpacing.micro3;
  static const double p4 = CatchSpacing.s1;
  static const double p6 = CatchSpacing.micro6;
  static const double p8 = CatchSpacing.s2;
  static const double p10 = CatchSpacing.micro10;
  static const double p12 = CatchSpacing.s3;
  static const double p14 = CatchSpacing.micro14;
  static const double p16 = CatchSpacing.s4;
  static const double p18 = CatchSpacing.micro18;
  static const double p20 = CatchSpacing.s5;
  static const double p24 = CatchSpacing.s6;
  static const double p28 = CatchSpacing.s7;
  static const double p32 = CatchSpacing.s8;
  static const double p36 = CatchSpacing.s9;
  static const double p40 = CatchSpacing.s10;
  static const double p44 = CatchSpacing.s11;
  static const double p48 = CatchSpacing.s12;
  static const double p64 = CatchSpacing.s16;
}

// Vertical gaps.
const gapH2 = SizedBox(height: CatchSpacing.micro2);
const gapH3 = SizedBox(height: CatchSpacing.micro3);
const gapH4 = SizedBox(height: CatchSpacing.s1);
const gapH6 = SizedBox(height: CatchSpacing.micro6);
const gapH8 = SizedBox(height: CatchSpacing.s2);
const gapH10 = SizedBox(height: CatchSpacing.micro10);
const gapH12 = SizedBox(height: CatchSpacing.s3);
const gapH14 = SizedBox(height: CatchSpacing.micro14);
const gapH16 = SizedBox(height: CatchSpacing.s4);
const gapH18 = SizedBox(height: CatchSpacing.micro18);
const gapH20 = SizedBox(height: CatchSpacing.s5);
const gapH24 = SizedBox(height: CatchSpacing.s6);
const gapH28 = SizedBox(height: Sizes.p28);
const gapH32 = SizedBox(height: CatchSpacing.s8);
const gapH36 = SizedBox(height: Sizes.p36);
const gapH40 = SizedBox(height: CatchSpacing.s10);
const gapH44 = SizedBox(height: Sizes.p44);
const gapH48 = SizedBox(height: CatchSpacing.s12);
const gapH64 = SizedBox(height: CatchSpacing.s16);

// Horizontal gaps.
const gapW2 = SizedBox(width: CatchSpacing.micro2);
const gapW3 = SizedBox(width: CatchSpacing.micro3);
const gapW4 = SizedBox(width: CatchSpacing.s1);
const gapW6 = SizedBox(width: CatchSpacing.micro6);
const gapW8 = SizedBox(width: CatchSpacing.s2);
const gapW10 = SizedBox(width: CatchSpacing.micro10);
const gapW12 = SizedBox(width: CatchSpacing.s3);
const gapW14 = SizedBox(width: CatchSpacing.micro14);
const gapW16 = SizedBox(width: CatchSpacing.s4);
const gapW20 = SizedBox(width: CatchSpacing.s5);
const gapW24 = SizedBox(width: CatchSpacing.s6);
const gapW28 = SizedBox(width: Sizes.p28);
const gapW32 = SizedBox(width: CatchSpacing.s8);
const gapW36 = SizedBox(width: Sizes.p36);
const gapW40 = SizedBox(width: CatchSpacing.s10);
const gapW44 = SizedBox(width: Sizes.p44);
const gapW48 = SizedBox(width: CatchSpacing.s12);
const gapW64 = SizedBox(width: CatchSpacing.s16);
