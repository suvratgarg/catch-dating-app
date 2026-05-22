import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchDetailHeroBackdrop extends StatelessWidget {
  const CatchDetailHeroBackdrop({super.key, this.imageUrl, this.semanticLabel});

  final String? imageUrl;
  final String? semanticLabel;

  static bool hasImage(String? imageUrl) =>
      imageUrl != null && imageUrl.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = imageUrl?.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage(resolvedImageUrl))
          Image.network(
            resolvedImageUrl!,
            fit: BoxFit.cover,
            semanticLabel: semanticLabel,
            errorBuilder: (_, _, _) => const _CatchDetailHeroFallback(),
          )
        else
          const _CatchDetailHeroFallback(),
        const _CatchDetailHeroScrim(),
      ],
    );
  }
}

class _CatchDetailHeroFallback extends StatelessWidget {
  const _CatchDetailHeroFallback();

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

class _CatchDetailHeroScrim extends StatelessWidget {
  const _CatchDetailHeroScrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.45, 1.0],
          colors: [
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.16),
            Colors.black.withValues(alpha: 0.70),
          ],
        ),
      ),
    );
  }
}
