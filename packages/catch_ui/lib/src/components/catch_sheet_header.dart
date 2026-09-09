import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_sheet_header_variant.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

/// Sheet heading with plain or branded glyph presentation and a trailing slot.
class CatchSheetHeader extends StatelessWidget {
  const CatchSheetHeader({super.key, this.title, this.subtitle, this.trailing})
    : _glyph = null,
      variant = CatchSheetHeaderVariant.plain;
  const CatchSheetHeader.branded({
    super.key,
    required IconData this._glyph,
    this.title,
    this.subtitle,
    this.trailing,
  }) : variant = CatchSheetHeaderVariant.branded;

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final CatchSheetHeaderVariant variant;
  final IconData? _glyph;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final branded = variant == CatchSheetHeaderVariant.branded;
    return Row(
      crossAxisAlignment: branded
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (branded) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: t.ink,
              borderRadius: BorderRadius.circular(
                CatchLayout.sheetGlyphTileRadius,
              ),
            ),
            child: SizedBox.square(
              dimension: CatchLayout.sheetGlyphTileSize,
              child: Icon(
                _glyph,
                size: CatchLayout.sheetGlyphIconSize,
                color: t.primaryInk,
              ),
            ),
          ),
          const SizedBox(width: CatchLayout.sheetHeaderGap),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title?.isNotEmpty ?? false)
                Text(title!, style: CatchTextStyles.titleL(context)),
              if (subtitle?.isNotEmpty ?? false) ...[
                branded ? gapH2 : gapH6,
                Text(
                  subtitle!,
                  style: branded
                      ? CatchTextStyles.bodyS(context, color: t.ink2)
                      : CatchTextStyles.bodyM(context, color: t.ink2),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: CatchLayout.sheetHeaderGap),
          trailing!,
        ],
      ],
    );
  }
}
