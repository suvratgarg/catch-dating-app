import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/primitives/catch_row_press_surface.dart';
import 'package:flutter/material.dart';

/// Field row anatomy with leading, body and trailing lanes; the parent owns geometry.
class CatchFieldRow extends StatelessWidget {
  const CatchFieldRow.standard({
    super.key,
    required this.body,
    this.leading,
    this.trailing,
    this.onTap,
    this.constraints = const BoxConstraints(),
    this.padding = _defaultPadding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.leadingTopPadding = 0,
    this.paddingDuration = CatchMotion.none,
    this.paddingCurve = CatchMotion.linearCurve,
  }) : leadingGap = leadingSlotGap,
       trailingGap = CatchFieldTokens.trailingGap;

  const CatchFieldRow.add({
    super.key,
    required this.leading,
    required this.body,
    this.onTap,
  }) : trailing = null,
       constraints = const BoxConstraints(),
       padding = const EdgeInsets.symmetric(
         horizontal: CatchFieldTokens.rowHorizontalPadding,
         vertical: CatchFieldTokens.rowVerticalPadding,
       ),
       crossAxisAlignment = CrossAxisAlignment.start,
       leadingTopPadding = 0,
       paddingDuration = CatchMotion.none,
       paddingCurve = CatchMotion.linearCurve,
       leadingGap = leadingSlotGap,
       trailingGap = CatchFieldTokens.trailingGap;

  /// Render size of icons in the leading slot.
  static const double leadingSlotIconSize = CatchFieldTokens.leadingIconExtent;

  /// Gap between the leading slot and the body lane.
  static const double leadingSlotGap = CatchFieldTokens.leadingGap;

  /// Horizontal distance from the row's padded edge to where the body
  /// lane starts when a leading slot is present. Containers that draw
  /// text-lane-aligned dividers derive their indent from this instead of
  /// hardcoding it, so resizing the leading icon moves the dividers too.
  static const double textLaneInset = CatchLayout.fieldRowTextLaneInset;

  static const _defaultPadding = EdgeInsets.fromLTRB(
    CatchFieldTokens.rowHorizontalPadding,
    CatchFieldTokens.rowVerticalPadding,
    CatchFieldTokens.rowHorizontalPadding,
    CatchFieldTokens.rowVerticalPadding,
  );

  final Widget body;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final double leadingTopPadding;
  final double leadingGap;
  final double trailingGap;
  final Duration paddingDuration;
  final Curve paddingCurve;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: constraints,
      child: AnimatedPadding(
        duration: paddingDuration,
        curve: paddingCurve,
        padding: padding,
        child: LayoutBuilder(
          builder: (context, rowConstraints) {
            // The trailing slot is intrinsic so trailing affordances pin to
            // the row's trailing edge; the body lane owns all remaining
            // width. Capping the slot at half the row keeps long trailing
            // values from starving the body lane on narrow rows.
            final trailingMaxWidth = rowConstraints.hasBoundedWidth
                ? rowConstraints.maxWidth / 2
                : double.infinity;
            return Row(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (leading != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: leadingTopPadding),
                    child: leading,
                  ),
                  SizedBox(width: leadingGap),
                ],
                Expanded(child: body),
                if (trailing != null) ...[
                  SizedBox(width: trailingGap),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: trailingMaxWidth),
                    child: trailing,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );

    if (onTap == null) return row;
    return CatchRowPressSurface(onTap: onTap, child: row);
  }
}
