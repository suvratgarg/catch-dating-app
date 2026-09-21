import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/components/catch_toolbar_control.dart';
import 'package:flutter/material.dart';

/// Primary root-screen action that preserves canonical top-bar geometry.
///
/// Compact layouts use the shared outlined 44-point icon control.
/// Medium and expanded layouts retain its outlined labelled action.
/// Callers provide semantics and behavior; this member owns the breakpoint,
/// action primitive, size, palette, and icon/label composition.
class CatchTopBarPrimaryButton extends StatelessWidget {
  const CatchTopBarPrimaryButton({
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
      );
    }

    return CatchToolbarControl.action(
      label: label,
      semanticLabel: label,
      tooltip: label,
      icon: icon,
      onPressed: onPressed,
    );
  }
}
