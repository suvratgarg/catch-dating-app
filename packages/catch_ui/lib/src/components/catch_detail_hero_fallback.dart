import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchDetailHeroFallback extends StatelessWidget {
  const CatchDetailHeroFallback({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.accent,
            Color.lerp(t.accent, t.ink, 0.36)!,
            Color.lerp(t.primary, t.ink, 0.50)!,
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
