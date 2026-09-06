import 'package:catch_dating_app/core/widgets/catch_fill_viewport_scroll_view.dart';
import 'package:catch_dating_app/core/widgets/catch_scene_viewport.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fractional max width preserves the smaller local limit', (
    tester,
  ) async {
    const childKey = Key('fractional-child');

    Future<void> pump(double laneWidth) => tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: laneWidth,
            child: const CatchFractionalMaxWidth(
              fraction: 0.8,
              maxWidth: 300,
              child: SizedBox(key: childKey, width: 500, height: 20),
            ),
          ),
        ),
      ),
    );

    await pump(500);
    expect(tester.getSize(find.byKey(childKey)).width, 300);

    await pump(200);
    expect(tester.getSize(find.byKey(childKey)).width, 160);
  });

  testWidgets('fill viewport scrolls overflow and keeps bounded width', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 300,
            child: CatchFillViewportScrollView(
              maxContentWidth: 240,
              child: SizedBox(key: Key('tall-content'), height: 600),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('tall-content'))).width, 240);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('scene viewport supplies bounded local geometry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 500,
            height: 320,
            child: CatchSceneViewport(
              maxWidth: 360,
              builder: (context, viewport) =>
                  Text('${viewport.width.toInt()}x${viewport.height.toInt()}'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('360x320'), findsOneWidget);
  });
}
