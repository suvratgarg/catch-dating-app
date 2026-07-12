import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Shared brand footer for exported rich share cards.
class CatchShareCardFooter extends StatelessWidget {
  const CatchShareCardFooter({
    super.key,
    required this.trailing,
    this.trailingColor,
  });

  final String trailing;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Text(
          context.l10n.coreCatchShareCardFooterTextCatch,
          style: CatchTextStyles.kicker(context, color: t.ink),
        ),
        gapW12,
        Expanded(
          child: Text(
            trailing,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: CatchTextStyles.labelS(
              context,
              color: trailingColor ?? t.ink2,
            ),
          ),
        ),
      ],
    );
  }
}
