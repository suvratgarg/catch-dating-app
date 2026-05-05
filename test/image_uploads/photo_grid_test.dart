import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('only active, non-loading photo slots are tappable', (
    tester,
  ) async {
    final tappedSlots = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PhotoGrid(
            photoUrls: const [],
            loadingIndices: const {0},
            onSlotTapped: tappedSlots.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(PhotoGridKeys.slot(0)));
    await tester.tap(find.byKey(PhotoGridKeys.slot(1)));
    await tester.pump();

    expect(tappedSlots, isEmpty);
    expect(find.bySemanticsLabel('Photo 1 uploading'), findsOneWidget);
    expect(find.bySemanticsLabel('Photo slot 2 unavailable'), findsOneWidget);
  });

  testWidgets('the next empty photo slot adds a photo', (tester) async {
    final tappedSlots = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PhotoGrid(photoUrls: const [], onSlotTapped: tappedSlots.add),
        ),
      ),
    );

    await tester.tap(find.byKey(PhotoGridKeys.slot(0)));
    await tester.pump();

    expect(tappedSlots, [0]);
    expect(find.bySemanticsLabel('Add photo 1'), findsOneWidget);
  });
}
