import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Fourth-option preview palette. Loyalty needs a categorical color distinct
/// from positive/new and attention/at-risk; global promotion is pending review.
abstract final class HostCustomerPalette {
  static Color regular(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFC5A6E7)
      : const Color(0xFF77529D);

  static Color atRisk(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFF0AF80)
      : const Color(0xFF97451C);

  static Color newCustomer(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? CatchTokens.of(context).success
      : const Color(0xFF236B45);
}
