import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.screenH,
        14,
        CatchSpacing.screenH,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: CatchTextStyles.displaySm(context),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: CatchTextStyles.labelMd(context, color: t.ink2),
            ),
        ],
      ),
    );
  }
}
