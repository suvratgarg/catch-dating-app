import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.uppercase = false,
    this.heavy = false,
    this.padding = const EdgeInsets.only(bottom: 8),
    this.titleStyle,
  });

  final String title;
  final Widget? trailing;
  final bool uppercase;
  final bool heavy;
  final EdgeInsets padding;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final text = uppercase ? title.toUpperCase() : title;
    final style =
        titleStyle ??
        (heavy
            ? CatchTextStyles.labelL(
                context,
                color: t.ink2,
              ).copyWith(fontWeight: FontWeight.w700)
            : CatchTextStyles.labelL(context, color: t.ink2));
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(text, style: style)),
          ?trailing,
        ],
      ),
    );
  }
}
