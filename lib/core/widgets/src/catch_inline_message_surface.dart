import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchInlineMessageSurface extends StatelessWidget {
  const CatchInlineMessageSurface({
    super.key,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.title,
    this.actions = const [],
    this.outerColor,
    this.backgroundColor,
    this.borderColor,
    this.iconSize = CatchIcon.md,
    this.iconTopPadding = CatchStroke.hairline,
    this.margin,
    this.padding = CatchInsets.tileContentCompact,
    this.titleStyle,
    this.messageStyle,
  });

  final String message;
  final IconData icon;
  final Color iconColor;
  final String? title;
  final List<Widget> actions;
  final Color? outerColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double iconSize;
  final double iconTopPadding;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  @override
  Widget build(BuildContext context) {
    final content = CatchSurface(
      tone: backgroundColor == null
          ? CatchSurfaceTone.transparent
          : CatchSurfaceTone.surface,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      radius: CatchRadius.md,
      padding: padding,
      margin: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: iconTopPadding),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: titleStyle ?? CatchTextStyles.labelL(context),
                  ),
                  const SizedBox(height: CatchSpacing.s1),
                ],
                Text(
                  message,
                  style: messageStyle ?? CatchTextStyles.supporting(context),
                ),
              ],
            ),
          ),
          for (final action in actions) ...[gapW8, action],
        ],
      ),
    );

    final outerColor = this.outerColor;
    if (outerColor == null) return content;
    return ColoredBox(color: outerColor, child: content);
  }
}
