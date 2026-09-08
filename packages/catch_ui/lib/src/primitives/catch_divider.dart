import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchDividerVariant { section, fieldSection, fieldRow }

/// One token-backed separator for sections, field rows and metric columns.
///
/// The vertical recipe shares the section ink and hairline, with a bounded
/// extent; horizontal field rows retain their quieter ink and text-lane inset.
class CatchDivider extends StatelessWidget {
  const CatchDivider({
    super.key,
    this.variant = CatchDividerVariant.fieldRow,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  }) : axis = Axis.horizontal,
       extent = null;

  const CatchDivider.section({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  }) : variant = CatchDividerVariant.section,
       axis = Axis.horizontal,
       extent = null;

  const CatchDivider.fieldRow({
    super.key,
    this.indent = CatchLayout.fieldRowTextLaneInset,
    this.endIndent = 0,
    this.color,
  }) : variant = CatchDividerVariant.fieldRow,
       axis = Axis.horizontal,
       extent = null;

  const CatchDivider.fieldSection({
    super.key,
    this.indent = CatchLayout.fieldRowTextLaneInset,
    this.endIndent = 0,
    this.color,
  }) : variant = CatchDividerVariant.fieldSection,
       axis = Axis.horizontal,
       extent = null;

  /// Vertical separator between metric columns. Callers may select a bounded
  /// extent while retaining the same separator ink and stroke.
  const CatchDivider.vertical({
    super.key,
    double this.extent = CatchSpacing.s9,
    this.color,
  }) : assert(extent >= 0),
       variant = CatchDividerVariant.section,
       axis = Axis.vertical,
       indent = 0,
       endIndent = 0;

  final Axis axis;
  final double? extent;
  final CatchDividerVariant variant;
  final double indent;
  final double endIndent;
  final Color? color;

  static Color colorFor(CatchTokens tokens, CatchDividerVariant variant) {
    return switch (variant) {
      CatchDividerVariant.section => tokens.line,
      CatchDividerVariant.fieldSection => tokens.line,
      CatchDividerVariant.fieldRow => tokens.line.withValues(
        // `line` already carries the theme-specific alpha (8% in light,
        // 13% in dark). Replacing it with 38% made every row rule much darker
        // than both the token and the intended color-mix. Scale the existing
        // alpha so the field-row variant is genuinely quieter than a section.
        alpha: tokens.line.a * CatchOpacity.fieldRowDivider,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    if (axis == Axis.vertical) {
      return SizedBox(
        width: CatchStroke.hairline,
        height: extent,
        child: ColoredBox(color: color ?? colorFor(tokens, variant)),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: ColoredBox(
          color: color ?? colorFor(tokens, variant),
          child: const SizedBox(height: CatchStroke.hairline),
        ),
      ),
    );
  }
}
