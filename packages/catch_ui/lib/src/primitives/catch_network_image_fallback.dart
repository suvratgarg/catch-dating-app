import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

class CatchNetworkImageFallback extends StatelessWidget {
  const CatchNetworkImageFallback({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.icon,
    this.iconSize = CatchIcon.md,
  });

  final Color? backgroundColor;
  final Color? iconColor;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: backgroundColor ?? t.surface,
      child: Center(
        child: Icon(
          icon ?? CatchIcons.imageOutlined,
          color: iconColor ?? t.ink3,
          size: iconSize,
        ),
      ),
    );
  }
}
