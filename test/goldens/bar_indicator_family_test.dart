import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  testWidgets('series paints nonzero-width bars and exposes its meaning', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: CatchBarSeriesIndicator(
                  values: [0, 1, 4],
                  maxValue: 4,
                  height: 100,
                  filledColor: Colors.indigo,
                  emptyColor: Colors.amber,
                  semanticLabel: 'Observed values',
                ),
              ),
            ),
          ),
        ),
      );
      final bars = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            [Colors.indigo, Colors.amber].contains(widget.color),
      );
      expect(bars, findsNWidgets(3));
      final sizes = List.generate(3, (index) => tester.getSize(bars.at(index)));
      expect(sizes.map((size) => size.width), everyElement(greaterThan(0)));
      expect(sizes.map((size) => size.height), [6, 25, 100]);
      expect(find.bySemanticsLabel('Observed values'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

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
                          child: CatchBarIndicator(value: -4, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchBarIndicator(value: 0, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchBarIndicator(value: 0.1, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchBarIndicator(value: 2, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchBarIndicator(value: 8, maxValue: 8),
                        ),
                        Expanded(
                          child: CatchBarIndicator(value: 16, maxValue: 8),
                        ),
                      ],
                    ),
                  ),
                  Text('The same bounded values as a series'),
                  CatchBarSeriesIndicator(
                    values: [-4, 0, 0.1, 2, 8, 16],
                    maxValue: 8,
                    height: 100,
                    semanticLabel: 'Relative activity values',
                  ),
                  Text('Automatic maximum'),
                  CatchBarSeriesIndicator(values: [0, 2, 6, 3], height: 100),
                  Text('No observations'),
                  CatchBarSeriesIndicator(values: [], height: 100),
                  Text('All-zero observations'),
                  CatchBarSeriesIndicator(values: [0, 0, 0], height: 100),
                  Text('Custom minimum fill and colors'),
                  CatchBarSeriesIndicator(
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
