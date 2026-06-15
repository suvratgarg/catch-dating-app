import 'dart:convert';
import 'dart:typed_data';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty picker exposes the add photo action', (tester) async {
    var addCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: OrderedPhotoPicker(
            label: const Text('Event photos'),
            photos: const [],
            onAddPhotos: () => addCount++,
            onRemovePhoto: null,
            onReorderPhoto: null,
            emptyActionLabel: 'Add event photos',
            addActionLabel: 'Add photos',
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Add event photos'), findsOneWidget);

    await tester.tap(
      find.byKey(OrderedPhotoPickerKeys.addAction('Add event photos')),
    );
    await tester.pump();

    expect(addCount, 1);
  });

  testWidgets('filled picker exposes keyed remove actions', (tester) async {
    final removed = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: OrderedPhotoPicker(
            label: const Text('Club photos'),
            photos: [
              OrderedPhotoPreview(id: 'one', bytes: _pngBytes()),
              OrderedPhotoPreview(id: 'two', bytes: _pngBytes()),
            ],
            onAddPhotos: () {},
            onRemovePhoto: removed.add,
            onReorderPhoto: null,
            emptyActionLabel: 'Add club photos',
            addActionLabel: 'Add photos',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);
    expect(find.byTooltip('Remove photo 2'), findsOneWidget);

    await tester.tap(find.byKey(OrderedPhotoPickerKeys.removeAction(1)));
    await tester.pump();

    expect(removed, [1]);
  });
}

Uint8List _pngBytes() {
  return base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUl'
    'EQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
  );
}
