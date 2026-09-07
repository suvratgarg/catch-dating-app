import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_count_badge.dart';
import 'package:flutter/material.dart';

class CatchTabBarIcon extends StatelessWidget {
  const CatchTabBarIcon({
    super.key,
    required this.icon,
    required this.color,
    this.badgeCount = 0,
    this.child,
  });

  final IconData icon;
  final Color color;
  final int badgeCount;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final glyph =
        child ?? Icon(icon, size: CatchLayout.tabBarIconSize, color: color);
    return SizedBox(
      width: CatchLayout.tabBarIconBoxExtent,
      height: CatchLayout.tabBarIconBoxExtent,
      child: CatchCountBadge(
        count: badgeCount,
        offset: const Offset(-1, 2),
        child: Align(child: glyph),
      ),
    );
  }
}
