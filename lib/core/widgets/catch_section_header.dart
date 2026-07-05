import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchSectionHeader extends StatelessWidget {
  const CatchSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.uppercase = false,
    this.heavy = false,
    this.padding = const EdgeInsets.only(bottom: CatchSpacing.s2),
    this.titleStyle,
  });

  final String title;

  /// Optional supporting line under the title.
  final String? subtitle;

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
            ? CatchTextStyles.titleL(context, color: t.ink)
            : CatchTextStyles.sectionTitle(context, color: t.ink));
    Widget content = Row(
      children: [
        Expanded(child: Text(text, style: style)),
        ?trailing,
      ],
    );
    if (subtitle != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          gapH4,
          Text(
            subtitle!,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      );
    }
    return Padding(padding: padding, child: content);
  }
}
