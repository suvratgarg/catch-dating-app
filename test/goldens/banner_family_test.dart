import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('inline feedback preserves recipes at scale $scale', (
      tester,
    ) async {
      await matchCatchGolden(
        tester,
        'banner_family${scale == 1 ? '' : '@2.0'}',
        textScale: scale,
        size: const Size(440, 1400),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final tone in CatchSurfaceMessageTone.values) ...[
                CatchSurface.message(
                  title: 'Host notice',
                  message: 'Booking updated.',
                  messageTone: tone,
                ),
                const SizedBox(height: 16),
              ],
              const CatchErrorBanner(message: 'Could not save.'),
              const SizedBox(height: 16),
              CatchErrorBanner.withRetry(
                message: 'Could not save.',
                retryLabel: 'Retry',
                onRetry: () {},
              ),
            ],
          ),
        ),
      );
    }, tags: const ['golden']);
  }
}
