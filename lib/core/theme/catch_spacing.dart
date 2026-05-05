import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/widgets.dart';

/// Fine-grained layout constants that bridge older `Sizes.p*` call sites to the
/// canonical Catch design-system spacing scale.
///
/// Prefer `CatchSpacing.s*` for new code when the value exists on the 4-point
/// scale. Keep `Sizes.p*` only for intermediate values such as 2, 3, 6, 10, 14,
/// or 18 where a tighter component-level spacing is intentional.
abstract final class Sizes {
  static const double p2 = 2.0;
  static const double p3 = 3.0;
  static const double p4 = CatchSpacing.s1;
  static const double p6 = 6.0;
  static const double p8 = CatchSpacing.s2;
  static const double p10 = 10.0;
  static const double p12 = CatchSpacing.s3;
  static const double p14 = 14.0;
  static const double p16 = CatchSpacing.s4;
  static const double p18 = 18.0;
  static const double p20 = CatchSpacing.s5;
  static const double p24 = CatchSpacing.s6;
  static const double p32 = CatchSpacing.s8;
  static const double p40 = CatchSpacing.s10;
  static const double p48 = CatchSpacing.s12;
  static const double p64 = CatchSpacing.s16;
}

// Vertical gaps.
const gapH2 = SizedBox(height: Sizes.p2);
const gapH3 = SizedBox(height: Sizes.p3);
const gapH4 = SizedBox(height: Sizes.p4);
const gapH6 = SizedBox(height: Sizes.p6);
const gapH8 = SizedBox(height: Sizes.p8);
const gapH10 = SizedBox(height: Sizes.p10);
const gapH12 = SizedBox(height: Sizes.p12);
const gapH14 = SizedBox(height: Sizes.p14);
const gapH16 = SizedBox(height: Sizes.p16);
const gapH18 = SizedBox(height: Sizes.p18);
const gapH20 = SizedBox(height: Sizes.p20);
const gapH24 = SizedBox(height: Sizes.p24);
const gapH32 = SizedBox(height: Sizes.p32);
const gapH40 = SizedBox(height: Sizes.p40);
const gapH48 = SizedBox(height: Sizes.p48);
const gapH64 = SizedBox(height: Sizes.p64);

// Horizontal gaps.
const gapW2 = SizedBox(width: Sizes.p2);
const gapW3 = SizedBox(width: Sizes.p3);
const gapW4 = SizedBox(width: Sizes.p4);
const gapW6 = SizedBox(width: Sizes.p6);
const gapW8 = SizedBox(width: Sizes.p8);
const gapW10 = SizedBox(width: Sizes.p10);
const gapW12 = SizedBox(width: Sizes.p12);
const gapW14 = SizedBox(width: Sizes.p14);
const gapW16 = SizedBox(width: Sizes.p16);
const gapW20 = SizedBox(width: Sizes.p20);
const gapW24 = SizedBox(width: Sizes.p24);
const gapW32 = SizedBox(width: Sizes.p32);
const gapW48 = SizedBox(width: Sizes.p48);
const gapW64 = SizedBox(width: Sizes.p64);
