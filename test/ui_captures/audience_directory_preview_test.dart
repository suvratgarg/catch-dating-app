import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalog/screen_capture_catalog.dart';
import 'support/capture_device.dart';
import 'support/capture_pump.dart';

void main() {
  testWidgets(
    'captures the four Audience directories',
    (tester) async {
      for (final entryId in [
        'host_customers_populated',
        'host_customers_audiences_populated',
        'host_forms_populated',
        'host_responses_populated',
      ]) {
        final entry = findScreenCapture(entryId);
        final artifacts = await captureCatchWidget(
          tester,
          id: entryId,
          builder: entry.builder,
          providerOverrides: entry.providerOverrides,
          device: CaptureDevice.iphone17Pro,
          includeOverlays: true,
          pixelRatio: 2,
          textScale: double.parse(
            const String.fromEnvironment(
              'CAPTURE_TEXT_SCALE',
              defaultValue: '1',
            ),
          ),
          outputDirectory: Directory(
            const String.fromEnvironment(
              'CAPTURE_OUTPUT_DIR',
              defaultValue: 'artifacts/audience-directory-preview',
            ),
          ),
        );
        expect(artifacts, hasLength(2));
        expect(tester.takeException(), isNull);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
