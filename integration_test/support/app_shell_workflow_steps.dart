import 'dart:ui' as ui;

import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/events/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart' show Icons, TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import '../../test/test_pump_helpers.dart';

Future<void> submitValidEvent(WidgetTester tester) async {
  await fillCreateEventBasicsStep(tester);
  await tapCatchButton(tester, 'Next');

  await enterCreateEventText(
    tester,
    CreateEventFormKeys.meetingPoint,
    'Bandra Fort',
  );
  await pickCreateEventMapPoint(tester);
  await enterCreateEventText(
    tester,
    CreateEventFormKeys.locationDetails,
    'Meet at the gate',
  );
  await tapCatchButton(tester, 'Next');

  await pickFutureEventDate(tester);
  await acceptInitialEventTime(tester);
  await tapCatchButton(tester, 'Next');

  await enterCreateEventText(tester, CreateEventFormKeys.capacity, '18');
  await enterCreateEventText(tester, CreateEventFormKeys.price, '249.5');
  await enterCreateEventText(tester, CreateEventFormKeys.minAge, '21');
  await enterCreateEventText(tester, CreateEventFormKeys.maxAge, '35');
  await tapCatchButton(tester, 'Next');
  await tapCatchButton(tester, 'Schedule event');
}

Future<void> enterClubText(
  String label,
  String text,
  WidgetTester tester,
) async {
  await tester.enterText(find.widgetWithText(CatchField, label), text);
}

Future<void> selectClubCity(WidgetTester tester, String label) async {
  tester.binding.focusManager.primaryFocus?.unfocus();
  await tester.pump();
  final cityDropdownIcon = find.byIcon(Icons.expand_more_rounded);
  await tester.ensureVisible(cityDropdownIcon);
  await tester.tap(cityDropdownIcon);
  await pumpFeatureUi(tester);
  await tester.tap(find.text(label).hitTestable());
  await pumpFeatureUi(tester);
}

Future<void> fillCreateEventBasicsStep(WidgetTester tester) async {
  await enterCreateEventText(tester, CreateEventFormKeys.distance, '7.5');
  await tester.tap(find.text('MODERATE'));
  await enterCreateEventText(
    tester,
    CreateEventFormKeys.description,
    'Social pacing with a coffee stop.',
  );
  await pumpFeatureUi(tester);
}

Future<void> pickCreateEventMapPoint(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateEventFormKeys.mapPicker));
  await pumpFeatureUi(tester);

  const selectedPoint = LocationCoordinate(19.12345, 72.98765);
  final pickerContext = tester.element(find.byType(LocationPickerScreen));
  Navigator.of(pickerContext).pop(
    const LocationPickerResult(
      coordinate: selectedPoint,
      name: 'Bandra Fort',
      address: 'Bandra Fort',
    ),
  );
  await pumpFeatureUi(tester);
}

Future<void> pickFutureEventDate(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateEventFormKeys.datePicker));
  await pumpFeatureUi(tester);
  await tester.tap(find.byTooltip('Next month'));
  await pumpFeatureUi(tester);
  await tester.tap(find.text('1').hitTestable());
  await pumpFeatureUi(tester);
  await tester.tap(find.text('OK'));
  await pumpFeatureUi(tester);
}

Future<void> acceptInitialEventTime(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateEventFormKeys.timePicker));
  await pumpFeatureUi(tester);
  await tester.tap(find.text('OK'));
  await pumpFeatureUi(tester);
}

Future<void> enterCreateEventText(
  WidgetTester tester,
  Key fieldKey,
  String text,
) async {
  await tester.enterText(
    find.descendant(of: find.byKey(fieldKey), matching: find.byType(TextField)),
    text,
  );
}

Future<void> tapCatchButton(WidgetTester tester, String label) async {
  tester.binding.focusManager.primaryFocus?.unfocus();
  await tester.pump();
  final buttonFinder = find.widgetWithText(CatchButton, label);
  await tester.ensureVisible(buttonFinder);
  await tester.tap(buttonFinder);
  await pumpFeatureUi(tester);
}

Future<void> tapCreateClub(WidgetTester tester) async {
  final createClub = find.bySemanticsLabel('Create club').first;
  await tester.tap(createClub);
  await pumpFeatureUi(tester);
}

Future<XFile> generatedPngXFile(String name) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(const ui.Color(0xFFFF6B4A), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 2);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return XFile.fromData(
    byteData!.buffer.asUint8List(),
    name: name,
    mimeType: 'image/png',
  );
}
