import 'dart:io';

import 'package:catch_dating_app/hosts/presentation/customers/host_customer_memory.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';
import 'catalog/screen_capture_catalog.dart';
import 'support/capture_device.dart';
import 'support/capture_pump.dart';

void main() {
  testWidgets(
    'captures customer detail views and editing',
    (tester) async {
      final entry = findScreenCapture('host_customer_detail_memory');
      for (final view in ['overview', 'memory', 'history', 'events', 'edit']) {
        final artifacts = await captureCatchWidget(
          tester,
          id: view,
          builder: (context) =>
              KeyedSubtree(key: ValueKey(view), child: entry.builder(context)),
          providerOverrides: entry.providerOverrides,
          device: CaptureDevice.iphone17Pro,
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
              defaultValue: 'artifacts/customer-detail-preview',
            ),
          ),
          drive: (tester) async {
            for (final label in ['Overview', 'Memory', 'History']) {
              final paragraph = tester.renderObject<RenderParagraph>(
                find.text(label),
              );
              expect(
                paragraph.didExceedMaxLines,
                isFalse,
                reason: 'Customer detail tab labels must remain readable',
              );
            }
            if (view == 'memory' || view == 'history') {
              final tab = find.text(view == 'memory' ? 'Memory' : 'History');
              await tester.ensureVisible(tab);
              await tester.tap(tab);
              await pumpFeatureUi(tester);
              expect(
                find.byType(HostCustomerMemorySection),
                view == 'memory' ? findsOneWidget : findsNothing,
              );
              expect(
                find.byType(HostCustomerTimelineSection),
                view == 'history' ? findsOneWidget : findsNothing,
              );
              if (view == 'history') {
                for (final paragraph
                    in find
                        .descendant(
                          of: find.byType(HostCustomerTimelineSection),
                          matching: find.byType(RichText),
                        )
                        .evaluate()) {
                  expect(
                    (paragraph.renderObject! as RenderParagraph)
                        .didExceedMaxLines,
                    isFalse,
                    reason: 'The sample history must not truncate',
                  );
                }
              }
            } else if (view == 'events') {
              await tester.ensureVisible(
                find.byKey(const ValueKey('host-customer-recent-events')),
              );
              await pumpFeatureUi(tester);
              expect(find.text('Sunday Run Club'), findsOneWidget);
            } else if (view == 'edit') {
              final edit = find.byKey(
                const ValueKey('host-customer-edit-details'),
              );
              await tester.ensureVisible(edit);
              await tester.tap(edit);
              await pumpFeatureUi(tester);
              expect(find.byType(TextField), findsWidgets);
            }
            expect(tester.takeException(), isNull);
          },
        );
        expect(artifacts, hasLength(2));
        expect(tester.takeException(), isNull);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
