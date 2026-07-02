import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:flutter/material.dart';

class CatchDetailHeroBackdrop extends StatelessWidget {
  const CatchDetailHeroBackdrop({
    super.key,
    this.imageUrl,
    this.semanticLabel,
    this.showScrim = true,
  });

  final String? imageUrl;
  final String? semanticLabel;
  final bool showScrim;

  static bool hasImage(String? imageUrl) =>
      imageUrl != null && imageUrl.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = imageUrl?.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage(resolvedImageUrl))
          CatchGradedImage(
            child: CatchNetworkImage(
              resolvedImageUrl!,
              semanticLabel: semanticLabel,
              errorBuilder: (context, _, _) => const CatchDetailHeroFallback(),
            ),
          )
        else
          const CatchDetailHeroFallback(),
        if (showScrim) const CatchDetailHeroScrim(),
      ],
    );
  }
}

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

class CatchDetailHeroScrim extends StatelessWidget {
  const CatchDetailHeroScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.45, 1.0],
          colors: [
            CatchTokens.editorialDark.withValues(
              alpha: CatchOpacity.photoScrimLight,
            ),
            CatchTokens.editorialDark.withValues(
              alpha: CatchOpacity.photoScrimMedium,
            ),
            CatchTokens.editorialDark.withValues(
              alpha: CatchOpacity.onDarkMuted,
            ),
          ],
        ),
      ),
    );
  }
}
