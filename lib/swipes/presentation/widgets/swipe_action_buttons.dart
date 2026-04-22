import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class SwipeActionButtons extends StatelessWidget {
  const SwipeActionButtons({
    super.key,
    required this.onPass,
    required this.onLike,
  });

  final VoidCallback onPass;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SwipeCircleButton(
            icon: Icons.close_rounded,
            color: colorScheme.error,
            onTap: onPass,
            surface: t.surface,
          ),
          SwipeCircleButton(
            icon: Icons.favorite_rounded,
            color: t.like,
            onTap: onLike,
            surface: t.surface,
          ),
        ],
      ),
    );
  }
}

class SwipeCircleButton extends StatelessWidget {
  const SwipeCircleButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.surface,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      elevation: 4,
      color: surface,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }
}
