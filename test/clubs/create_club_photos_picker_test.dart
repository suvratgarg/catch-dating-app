import 'dart:convert';
import 'dart:typed_data';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('standard club photos picker exposes the empty add tile', (
    tester,
  ) async {
    var addCount = 0;

    await _pumpPhotosWidget(
      tester,
      CreateClubPhotosPicker(
        photos: const [],
        onAddPhotos: () => addCount++,
        onRemovePhoto: null,
        onReorderPhoto: null,
      ),
    );

    expect(find.text('Organizer photos'), findsOneWidget);
    expect(find.bySemanticsLabel('Add organizer photos'), findsOneWidget);

    await tester.tap(
      find.byKey(OrderedPhotoPickerKeys.addAction('Add organizer photos')),
    );
    await tester.pump();

    expect(addCount, 1);
  });

  testWidgets('edit strip keeps cover affordance and add tile', (tester) async {
    var addCount = 0;

    await _pumpPhotosWidget(
      tester,
      CreateClubPhotosPicker(
        photos: [_photo('one'), _photo('two')],
        onAddPhotos: () => addCount++,
        onRemovePhoto: (_) {},
        onReorderPhoto: (_, _) {},
        variant: CreateClubPhotosPickerVariant.editStrip,
      ),
    );

    expect(find.text('COVER'), findsOneWidget);
    expect(find.text('PHOTOS'), findsNothing);
    expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Photo 2'), findsOneWidget);
    expect(
      find.byKey(OrderedPhotoPickerKeys.addAction('Add photos')),
      findsOneWidget,
    );
    expect(find.textContaining('first photo is your cover'), findsOneWidget);

    await tester.tap(
      find.byKey(OrderedPhotoPickerKeys.addAction('Add photos')),
    );
    await tester.pump();

    expect(addCount, 1);
  });

  testWidgets('edit logo square exposes bottom-right add badge', (
    tester,
  ) async {
    var tapCount = 0;

    await _pumpPhotosWidget(
      tester,
      CreateClubProfileImagePicker(
        imageBytes: null,
        onTap: () => tapCount++,
        variant: CreateClubProfileImagePickerVariant.editLogo,
      ),
    );

    expect(find.text('CLUB LOGO'), findsNothing);
    expect(
      find.bySemanticsLabel('Add organizer profile image'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CatchIconTile &&
            widget.icon == CatchIcons.addPhotoAlternateOutlined,
      ),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Add organizer profile image'));
    await tester.pump();

    expect(tapCount, 1);
  });
}

Future<void> _pumpPhotosWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  );
  await tester.pump();
}

OrderedPhotoPreview _photo(String id) =>
    OrderedPhotoPreview(id: id, bytes: _pngBytes());

Uint8List _pngBytes() {
  return base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUl'
    'EQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
  );
}
