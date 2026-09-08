import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchButtonLabel extends StatelessWidget {
  const CatchButtonLabel({
    super.key,
    required this.label,
    required this.color,
    required this.textStyle,
    this.icon,
    this.gap = CatchSpacing.micro6,
    this.fullWidth = false,
    this.allowMultiline = false,
  });

  final String label;
  final Color color;
  final Widget? icon;
  final double gap;
  final bool fullWidth;
  final bool allowMultiline;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon;
    final labelWidget = Text(
      label,
      maxLines: allowMultiline ? null : 1,
      overflow: allowMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: textStyle.copyWith(color: color),
    );
    final content = Row(
      mainAxisSize: allowMultiline && fullWidth
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconWidget != null) ...[
          IconTheme(
            data: IconThemeData(color: color, size: CatchIcon.md),
            child: iconWidget,
          ),
          SizedBox(width: gap),
        ],
        Flexible(child: labelWidget),
      ],
    );

    return content;
  }
}
