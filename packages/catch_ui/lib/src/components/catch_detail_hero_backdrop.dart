import 'package:catch_ui/src/components/catch_detail_hero_fallback.dart';
import 'package:catch_ui/src/primitives/catch_graded_image.dart';
import 'package:catch_ui/src/primitives/catch_network_image.dart';
import 'package:catch_ui/src/primitives/catch_scrim.dart';
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
        if (showScrim) const CatchScrim.detailHero(),
      ],
    );
  }
}
