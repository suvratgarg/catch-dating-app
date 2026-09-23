import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_pump_helpers.dart';
import 'catalog/screen_capture_catalog.dart';
import 'support/capture_device.dart';
import 'support/capture_pump.dart';

void main() {
  testWidgets(
    'captures response detail configurations',
    (tester) async {
      for (final id in [
        'host_form_response_application',
        'host_form_response_intake',
        'host_form_response_withdrawn',
        'host_form_response_large_text',
        'host_application_detail',
        'host_response_review_submitted',
        'host_response_review_imported',
        'host_response_review_revoked',
        'host_response_review_notes',
      ]) {
        final entry = findScreenCapture(
          id == 'host_response_review_notes'
              ? 'host_response_review_submitted'
              : id,
        );
        await captureCatchWidget(
          tester,
          id: id,
          builder: entry.builder,
          drive: id.endsWith('_notes')
              ? (tester) async {
                  final note = find.text('Save review note');
                  await tester.ensureVisible(note);
                  await pumpFeatureUi(tester);
                }
              : null,
          providerOverrides: entry.providerOverrides,
          device: CaptureDevice.iphone17Pro,
          includeOverlays: true,
          textScale: id.endsWith('large_text') ? 2 : 1,
          outputDirectory: Directory(
            const String.fromEnvironment(
              'CAPTURE_OUTPUT_DIR',
              defaultValue: 'artifacts/response-detail-review/after',
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
