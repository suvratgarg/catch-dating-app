import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

class CatchBrandedSheetHeader extends StatelessWidget {
  const CatchBrandedSheetHeader({
    super.key,
    required this.glyph,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData glyph;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
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
              glyph,
              size: CatchLayout.sheetGlyphIconSize,
              color: t.primaryInk,
            ),
          ),
        ),
        const SizedBox(width: CatchLayout.sheetHeaderGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((title?.isNotEmpty ?? false))
                Text(title!, style: CatchTextStyles.titleL(context)),
              if ((subtitle?.isNotEmpty ?? false)) ...[
                gapH2,
                Text(
                  subtitle!,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
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
