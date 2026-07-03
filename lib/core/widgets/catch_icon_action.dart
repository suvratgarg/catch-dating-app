import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:flutter/material.dart';

/// Tooltip-wrapped icon action used by top bars and floating chrome.
class CatchIconAction extends StatelessWidget {
  const CatchIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.background,
    this.backgroundColor,
    this.foregroundColor,
    this.variant = CatchIconButtonVariant.bordered,
    this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final CatchIconButtonVariant variant;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: tooltip,
      child: CatchIconButton(
        onTap: onPressed,
        variant: variant,
        background: backgroundColor ?? background,
        size: size ?? CatchIconButton.navSize,
        child: Icon(icon, size: CatchIcon.md, color: foregroundColor ?? t.ink),
      ),
    );
  }
}
