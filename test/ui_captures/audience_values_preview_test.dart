import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalog/screen_capture_catalog.dart';
import 'support/capture_device.dart';
import 'support/capture_pump.dart';

const _output = String.fromEnvironment(
  'CAPTURE_OUTPUT_DIR',
  defaultValue: 'artifacts/ui-captures/audience-values-preview',
);

void main() {
  testWidgets(
    'captures Audience using native iOS typography',
    (tester) async {
      final entry = findScreenCapture('host_customers_populated');
      final artifacts = await captureCatchWidget(
        tester,
        id: entry.id,
        builder: entry.builder,
        providerOverrides: entry.providerOverrides,
        device: CaptureDevice.iphone17Pro,
        textScale: double.parse(
          const String.fromEnvironment('CAPTURE_TEXT_SCALE', defaultValue: '1'),
        ),
        pixelRatio: 2,
        outputDirectory: Directory(_output),
      );
      expect(artifacts, hasLength(2));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
