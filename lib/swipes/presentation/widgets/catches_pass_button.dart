import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:flutter/material.dart';

class CatchesPassButton extends StatelessWidget {
  const CatchesPassButton({
    super.key,
    required this.onPressed,
    this.isPending = false,
  });

  final VoidCallback? onPressed;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final passColor = Theme.of(context).colorScheme.error;
    final isEnabled = onPressed != null && !isPending;

    return Tooltip(
      message: isPending ? 'Passing' : 'Pass',
      child: Semantics(
        label: isPending ? 'Passing profile' : 'Pass profile',
        button: true,
        enabled: isEnabled,
        child: AnimatedOpacity(
          opacity: isEnabled || isPending ? 1 : CatchOpacity.disabledControl,
          duration: const Duration(milliseconds: 120),
          child: Material(
            key: SwipeKeys.passButton,
            color: t.surface.withValues(alpha: CatchOpacity.passButtonFill),
            shape: CircleBorder(side: BorderSide(color: t.line)),
            elevation: CatchElevation.physicalPassControl,
            shadowColor: CatchTokens.editorialBlack.withValues(
              alpha: CatchOpacity.passButtonShadow,
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isEnabled ? onPressed : null,
              child: SizedBox.square(
                dimension: CatchLayout.passButtonExtent,
                child: Center(
                  child: isPending
                      ? SizedBox.square(
                          dimension: CatchIcon.passButton,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              passColor,
                            ),
                          ),
                        )
                      : Icon(
                          CatchIcons.closeRounded,
                          color: passColor,
                          size: CatchIcon.passButton,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
