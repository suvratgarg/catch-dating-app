import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('text roles preserve typography at scale $scale', (
      tester,
    ) async {
      await matchCatchGolden(
        tester,
        'text_roles${scale == 1 ? '' : '@2.0'}',
        textScale: scale,
        size: const Size(440, 500),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const CatchKicker(label: 'Host notes'),
              const CatchKicker(label: 'Featured', size: CatchKickerSize.lg),
              const CatchKicker(
                label: 'Your details',
                size: CatchKickerSize.fieldSection,
              ),
              CatchMonoLabel('250 views', color: CatchTokens.of(context).ink2),
              CatchMonoLabel(
                'Sold out',
                color: CatchTokens.of(context).ink2,
                uppercase: true,
              ),
              const CatchSectionLabel(label: 'Your guests'),
              CatchSectionLabel(
                label: 'Your guests',
                icon: CatchIcons.groupsOutlined,
              ),
            ],
          ),
        ),
      );
    }, tags: const ['golden']);
  }
}
