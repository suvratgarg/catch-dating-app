import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchIconTile extends StatelessWidget {
  const CatchIconTile({
    super.key,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.size = 42,
    this.iconSize = 21,
    this.radius = CatchRadius.md,
  });

  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? t.raised,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? t.line),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
