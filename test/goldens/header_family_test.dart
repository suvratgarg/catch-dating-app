import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('header recipes preserve geometry at scale $scale', (
      tester,
    ) async {
      await matchCatchGolden(
        tester,
        'header_family@$scale',
        textScale: scale,
        size: const Size(440, 1600),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CatchSectionHeader(
                title: 'Your details',
                subtitle: 'Visible to your guests',
                trailing: Text('Edit'),
              ),
              const SizedBox(height: 24),
              const CatchSectionHeader(
                title: 'Schedule',
                uppercase: true,
                heavy: true,
              ),
              const SizedBox(height: 24),
              CatchSectionKicker(
                text: 'Guests',
                count: 24,
                color: CatchTokens.of(context).ink,
                trailing: const Text('View all'),
              ),
              const SizedBox(height: 24),
              const CatchPlainSheetHeader(
                title: 'Choose a time',
                subtitle: 'Guests see your local time',
                trailing: Icon(Icons.close),
              ),
              const SizedBox(height: 24),
              const CatchBrandedSheetHeader(
                glyph: Icons.event,
                title: 'Choose a time',
                subtitle: 'Guests see your local time',
                trailing: Icon(Icons.close),
              ),
              const SizedBox(height: 24),
              const CatchScreenHeaderTitle.block(
                title: 'Your events',
                eyebrow: 'This week',
                subtitle: 'Everything you are planning',
                leading: Icon(Icons.event),
                actions: [Text('Create'), Icon(Icons.add)],
              ),
              const SizedBox(height: 24),
              for (final extent in [64.0, 72.0, 128.0]) ...[
                FlexibleSpaceBarSettings(
                  toolbarOpacity: 1,
                  minExtent: 64,
                  maxExtent: 240,
                  currentExtent: extent,
                  child: const CatchCollapsedSliverTitle(title: 'Event title'),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      );
    }, tags: const ['golden']);
  }
}
