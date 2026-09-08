import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'bar indicators preserve value and series recipes at $scale',
      (tester) async {
        await matchCatchGolden(
          tester,
          'bar_indicator_family@$scale',
          size: const Size(440, 1450),
          textScale: scale,
          builder: (context) => DefaultTextStyle(
            style: CatchTextStyles.bodyL(context),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Text(
                    'Single bars: negative, zero, tiny, partial, full, clamped',
                  ),
                  SizedBox(
                    height: 100,
                    child: Row(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CatchAnalyticsBar(value: -4, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchAnalyticsBar(value: 0, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchAnalyticsBar(value: 0.1, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchAnalyticsBar(value: 2, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchAnalyticsBar(value: 8, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchAnalyticsBar(value: 16, maxValue: 8),
                        ),
                      ],
                    ),
                  ),
                  Text('The same bounded values as a series'),
                  CatchMiniBarChart(
                    values: [-4, 0, 0.1, 2, 8, 16],
                    maxValue: 8,
                    height: 100,
                    semanticLabel: 'Relative activity values',
                  ),
                  Text('Automatic maximum'),
                  CatchMiniBarChart(values: [0, 2, 6, 3], height: 100),
                  Text('No observations'),
                  CatchMiniBarChart(values: [], height: 100),
                  Text('All-zero observations'),
                  CatchMiniBarChart(values: [0, 0, 0], height: 100),
                  Text('Custom minimum fill and colors'),
                  CatchMiniBarChart(
                    values: [-2, 0, 0.1, 6, 12],
                    maxValue: 8,
                    height: 100,
                    minFilledHeightFactor: 0.15,
                    emptyHeightFactor: 0.04,
                    filledColor: Colors.indigo,
                    emptyColor: Colors.amber,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      tags: const ['golden'],
    );
  }
}
