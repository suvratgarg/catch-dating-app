import 'dart:ui' as ui;

import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('photo grading preserves image opacity in $brightness', (
      tester,
    ) async {
      const capture = ValueKey('grade-alpha');
      await tester.pumpWidget(
        MaterialApp(
          theme: brightness == Brightness.light
              ? CatchTheme.light
              : CatchTheme.dark,
          home: Center(
            child: RepaintBoundary(
              key: capture,
              child: ColoredBox(
                color: const Color(0xff00ff00),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final opacity in [1.0, 0.5, 0.0])
                        SizedBox.square(
                          dimension: 80,
                          child: CatchGradedImage(
                            child: ColoredBox(
                              color: Colors.red.withValues(alpha: opacity),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(capture),
      );
      final pixels = await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          return await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        } finally {
          image.dispose();
        }
      });
      List<int> pixelAt(int x, int y) =>
          pixels!.buffer.asUint8List((y * 260 + x) * 4, 4);
      const background = [0, 255, 0, 255];
      expect(pixelAt(1, 1), background, reason: 'No paint outside the image.');
      expect(
        pixelAt(210, 50),
        background,
        reason: 'Fully transparent pixels stay transparent.',
      );
      final opaque = pixelAt(50, 50);
      final translucent = pixelAt(130, 50);
      for (var channel = 0; channel < 3; channel++) {
        expect(
          translucent[channel],
          closeTo((opaque[channel] + background[channel]) / 2, 2),
          reason: 'The grade changes color, not the image opacity.',
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
