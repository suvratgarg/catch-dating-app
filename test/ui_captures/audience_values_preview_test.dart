import 'dart:io';
import 'dart:ui' show SemanticsAction;

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
      final semantics = tester.ensureSemantics();
      try {
        final entry = findScreenCapture('host_customers_populated');
        final artifacts = await captureCatchWidget(
          tester,
          id: entry.id,
          builder: entry.builder,
          providerOverrides: entry.providerOverrides,
          device: CaptureDevice.iphone17Pro,
          textScale: double.parse(
            const String.fromEnvironment(
              'CAPTURE_TEXT_SCALE',
              defaultValue: '1',
            ),
          ),
          pixelRatio: 2,
          outputDirectory: Directory(_output),
          drive: (tester) async {
            for (final filter in ['all', 'repeat', 'newToOrganizer']) {
              final node = tester.getSemantics(
                find.byKey(ValueKey('host-customers-summary-$filter')),
              );
              expect(
                node.getSemanticsData().hasAction(SemanticsAction.tap),
                isTrue,
                reason: '$filter must expose its selection action',
              );
            }
          },
        );
        expect(artifacts, hasLength(2));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
