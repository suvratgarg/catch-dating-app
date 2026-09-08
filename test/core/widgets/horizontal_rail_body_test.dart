import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final height in <double?>[80, null]) {
    testWidgets('rail height $height keeps item order and trailing action', (
      tester,
    ) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 420,
                child: CatchHorizontalRailBody(
                  itemCount: 2,
                  height: height,
                  spacing: 12,
                  listPadding: const EdgeInsets.symmetric(horizontal: 8),
                  itemWidth: 100,
                  itemBuilder: (context, index) =>
                      SizedBox(height: 44, child: Text('Item $index')),
                  trailing: TextButton(
                    onPressed: () => selected++,
                    child: const Text('More'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.getTopLeft(find.text('Item 0')).dx, 8);
      expect(
        tester.getTopLeft(find.text('Item 1')).dx -
            tester.getTopLeft(find.text('Item 0')).dx,
        112,
      );
      if (height != null) {
        expect(tester.getSize(find.byType(CatchHorizontalRailBody)).height, 80);
        expect(find.byType(ListView), findsOneWidget);
      } else {
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(
          tester.getSize(find.byType(CatchHorizontalRailBody)).height,
          tester.getSize(find.byType(TextButton)).height,
        );
      }
      await tester.tap(find.text('More'));
      expect(selected, 1);
      expect(tester.takeException(), isNull);
    });
  }

  for (final sizing in [(160.0, 200.0), (320.0, 240.0), (600.0, 260.0)]) {
    testWidgets('parent rail clamps item width at viewport ${sizing.$1}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: sizing.$1,
                child: CatchHorizontalRail(
                  title: 'Rail',
                  itemCount: 1,
                  height: null,
                  itemWidth: const CatchRailItemWidth.fractional(
                    fraction: 0.75,
                    min: 200,
                    max: 260,
                  ),
                  itemBuilder: (context, index) => const SizedBox(
                    key: ValueKey('slot'),
                    height: 40,
                    child: Text('Item'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('slot'))).width,
        sizing.$2,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
