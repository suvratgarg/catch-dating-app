import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
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
            key: SwipeKeys.passButton,
            icon: Icons.close_rounded,
            color: colorScheme.error,
            onTap: onPass,
            tooltip: 'Pass',
            semanticLabel: 'Pass, swipe left',
          ),
          SwipeCircleButton(
            key: SwipeKeys.likeButton,
            icon: Icons.favorite_rounded,
            color: t.like,
            onTap: onLike,
            tooltip: 'Like',
            semanticLabel: 'Like, swipe right',
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
    required this.tooltip,
    this.semanticLabel,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: semanticLabel ?? tooltip,
        button: true,
        child: Material(
          shape: const CircleBorder(),
          elevation: 4,
          color: t.surface,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Icon(icon, color: color, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
