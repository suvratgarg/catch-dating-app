import 'package:catch_ui/src/components/catch_empty_state_icon.dart';
import 'package:catch_ui/src/components/catch_empty_state_types.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

class CatchEmptyStateContent extends StatelessWidget {
  const CatchEmptyStateContent({
    super.key,
    required this.layout,
    required this.titleStyle,
    required this.messageStyle,
    this.icon,
    this.iconStyle = CatchEmptyStateIconStyle.plain,
    this.iconSize,
    this.iconContainerSize,
    this.title,
    this.message,
    this.action,
  });

  final CatchEmptyStateLayout layout;
  final IconData? icon;
  final CatchEmptyStateIconStyle iconStyle;
  final double? iconSize;
  final double? iconContainerSize;
  final String? title;
  final String? message;
  final Widget? action;
  final TextStyle titleStyle;
  final TextStyle messageStyle;

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    final titleText = title;
    final messageText = message;
    final actionWidget = action;

    return switch (layout) {
      CatchEmptyStateLayout.stacked => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null)
            CatchEmptyStateIcon(
              icon: iconData,
              style: iconStyle,
              size: iconSize,
              containerSize: iconContainerSize,
            ),
          if (_hasText(titleText)) ...[
            if (iconData != null) gapH12,
            Text(titleText!, style: titleStyle, textAlign: TextAlign.center),
          ],
          if (_hasText(messageText)) ...[
            if (_hasText(titleText)) gapH6 else if (iconData != null) gapH12,
            Text(
              messageText!,
              style: messageStyle,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionWidget != null) ...[gapH16, actionWidget],
        ],
      ),
      CatchEmptyStateLayout.inline => Row(
        children: [
          if (iconData != null) ...[
            CatchEmptyStateIcon(
              icon: iconData,
              style: iconStyle,
              size: iconSize,
              containerSize: iconContainerSize ?? 44,
            ),
            gapW12,
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasText(titleText)) Text(titleText!, style: titleStyle),
                if (_hasText(messageText)) ...[
                  if (_hasText(titleText)) gapH4,
                  Text(messageText!, style: messageStyle),
                ],
                if (actionWidget != null) ...[gapH12, actionWidget],
              ],
            ),
          ),
        ],
      ),
    };
  }
}

bool _hasText(String? value) => value != null && value.isNotEmpty;
