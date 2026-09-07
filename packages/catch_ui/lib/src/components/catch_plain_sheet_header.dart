import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

class CatchPlainSheetHeader extends StatelessWidget {
  const CatchPlainSheetHeader({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((title?.isNotEmpty ?? false))
                Text(title!, style: CatchTextStyles.titleL(context)),
              if ((subtitle?.isNotEmpty ?? false)) ...[
                gapH6,
                Text(
                  subtitle!,
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
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
