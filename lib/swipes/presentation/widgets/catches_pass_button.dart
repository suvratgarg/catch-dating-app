import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:flutter/material.dart';

class CatchesPassButton extends StatelessWidget {
  const CatchesPassButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final passColor = Theme.of(context).colorScheme.error;

    return Tooltip(
      message: 'Pass',
      child: Semantics(
        label: 'Pass profile',
        button: true,
        child: Material(
          key: SwipeKeys.passButton,
          color: t.surface.withValues(alpha: 0.96),
          shape: CircleBorder(side: BorderSide(color: t.line)),
          elevation: 5,
          shadowColor: Colors.black.withValues(alpha: 0.24),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: 64,
              child: Icon(Icons.close_rounded, color: passColor, size: 34),
            ),
          ),
        ),
      ),
    );
  }
}
