import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  testWidgets(
    'media readability preserves every production gradient',
    (tester) async {
      await matchCatchGolden(
        tester,
        'media_overlay_family',
        size: const Size(440, 570),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final overlay in [
                const CatchScrim.detailHero(),
                const CatchScrim.photoFrame(),
                CatchScrim.heroTint(base: CatchTokens.of(context).ink),
                const CatchEventThumbnailScrimOverlay(
                  style: CatchEventThumbnailScrim.bottom,
                ),
                const CatchEventThumbnailScrimOverlay(
                  style: CatchEventThumbnailScrim.full,
                ),
              ])
                SizedBox(
                  width: 190,
                  height: 160,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CatchTokens.of(context).primary,
                          CatchTokens.of(context).surface,
                        ],
                      ),
                    ),
                    child: overlay,
                  ),
                ),
            ],
          ),
        ),
      );
    },
    tags: const ['golden'],
  );
}
