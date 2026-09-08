import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:flutter/material.dart';

/// Primary root-screen action that preserves canonical top-bar geometry.
///
/// Preview: compact layouts use a quiet 44-point icon target.
/// Medium and expanded layouts retain the labelled small primary button.
/// Callers provide semantics and behavior; this member owns the breakpoint,
/// action primitive, size, palette, and icon/label composition.
class CatchTopBarPrimaryAction extends StatelessWidget {
  const CatchTopBarPrimaryAction({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final screenSize = CatchWindowSize.fromWidth(
      MediaQuery.sizeOf(context).width,
    );
    if (screenSize.isCompact) {
      return CatchIconAction.toolbar(
        icon: icon,
        tooltip: label,
        onPressed: onPressed,
        variant: CatchIconActionVariant.plain,
      );
    }

    return CatchButton(
      label: label,
      leading: Icon(icon, size: CatchIcon.sm),
      size: CatchButtonSize.sm,
      onPressed: onPressed,
    );
  }
}
