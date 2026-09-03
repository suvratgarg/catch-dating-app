import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Customer-directory typography experiment, pending visual review before
/// promotion into the shared semantic scale. The page and shell retain their
/// existing layout owners.
///
/// Fourth option: a custom compact iOS name role (16/20), 14/20 metadata,
/// 13/18 context, and 12/16 status. These are composition choices, not a claim
/// that all values are native defaults. Android retains title-medium 16/24.
/// https://developer.apple.com/design/human-interface-guidelines/typography
/// https://m3.material.io/styles/typography/type-scale-tokens
abstract final class HostCustomerTypography {
  static TextStyle body(BuildContext context) => CatchFonts.sans(
    fontSize: 16,
    height: 24 / 16,
    color: CatchTokens.of(context).ink,
  );

  static TextStyle metric(BuildContext context) => CatchFonts.sans(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    color: CatchTokens.of(context).ink,
  );

  static bool _ios(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;

  static TextStyle name(BuildContext context) => CatchFonts.sans(
    fontSize: 16,
    height: _ios(context) ? 20 / 16 : 24 / 16,
    fontWeight: _ios(context) ? FontWeight.w600 : FontWeight.w500,
    color: CatchTokens.of(context).ink,
  );

  static TextStyle secondary(BuildContext context) => CatchFonts.sans(
    fontSize: 14,
    height: 20 / 14,
    color: CatchTokens.of(context).ink2,
  );

  static TextStyle control(BuildContext context, {bool selected = false}) =>
      CatchFonts.sans(
        fontSize: _ios(context) ? 15 : 14,
        height: _ios(context) ? 20 / 15 : 20 / 14,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: CatchTokens.of(context).ink,
      );

  // The compact group and status treatment is a Catch composition choice;
  // its text uses iOS Subheadline / Footnote and Material label roles.
  static TextStyle group(BuildContext context, {required bool selected}) =>
      secondary(context).copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected
            ? CatchTokens.of(context).bg
            : CatchTokens.of(context).ink2,
      );

  static TextStyle status(BuildContext context, {Color? color}) =>
      CatchFonts.sans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        color: color ?? CatchTokens.of(context).ink2,
      );

  static TextStyle metadata(BuildContext context) => secondary(context);

  static TextStyle metadataStrong(BuildContext context) => metadata(
    context,
  ).copyWith(fontWeight: FontWeight.w500, color: CatchTokens.of(context).ink);

  static TextStyle context(BuildContext context) => CatchFonts.sans(
    fontSize: _ios(context) ? 13 : 12,
    height: _ios(context) ? 18 / 13 : 16 / 12,
    color: CatchTokens.of(context).ink2,
  );
}
