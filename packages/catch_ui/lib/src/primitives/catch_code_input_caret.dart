import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Token-styled insertion caret used inside code input cells.
class CatchCodeInputCaret extends StatelessWidget {
  const CatchCodeInputCaret({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? CatchTokens.of(context).ink,
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
      child: const SizedBox(
        width: CatchLayout.otpCaretWidth,
        height: CatchLayout.otpCaretHeight,
      ),
    );
  }
}
