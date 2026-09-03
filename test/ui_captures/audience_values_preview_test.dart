import 'dart:convert';
import 'dart:io';
import 'dart:ui' show SemanticsAction;

import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_row.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
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
      final measurements = <Map<String, Object>>[];
      final textScale = double.parse(
        const String.fromEnvironment('CAPTURE_TEXT_SCALE', defaultValue: '1'),
      );
      try {
        final entry = findScreenCapture('host_customers_populated');
        final artifacts = await captureCatchWidget(
          tester,
          id: entry.id,
          builder: entry.builder,
          providerOverrides: entry.providerOverrides,
          device: CaptureDevice.iphone17Pro,
          textScale: textScale,
          pixelRatio: 2,
          outputDirectory: Directory(_output),
          drive: (tester) async {
            Map<String, double> rect(Finder finder) {
              final bounds = tester.getRect(finder);
              return {
                'x': bounds.left,
                'y': bounds.top,
                'width': bounds.width,
                'height': bounds.height,
              };
            }

            final rowMetrics = <Map<String, Object>>[];
            for (final element in find.byType(HostCustomerRow).evaluate()) {
              final finder = find.byWidget(element.widget);
              final row = element.widget as HostCustomerRow;
              final bounds = tester.getRect(finder);
              if (textScale == 1) {
                expect(
                  bounds.height,
                  closeTo(88, 0.1),
                  reason: 'Badges must not change the standard customer rhythm',
                );
              }
              rowMetrics.add({
                'name': row.contact.displayName,
                'row': rect(finder),
                'avatar': rect(
                  find.descendant(
                    of: finder,
                    matching: find.byType(CatchPersonAvatar),
                  ),
                ),
                'nameLine': rect(
                  find.descendant(
                    of: finder,
                    matching: find.text(row.contact.displayName),
                  ),
                ),
              });
            }
            final rail = tester.getRect(find.byType(HostAudienceTabRail));
            final tabLabel = tester.getRect(find.text('People').first);
            expect(tabLabel.top, greaterThanOrEqualTo(rail.top));
            expect(
              tabLabel.bottom,
              lessThanOrEqualTo(rail.bottom),
              reason: 'The pinned rail must contain the enlarged label',
            );
            measurements.add({
              'textScale': textScale,
              'title': rect(find.text('Audience').first),
              'tabRail': rect(find.byType(HostAudienceTabRail)),
              'groups': {
                for (final filter in ['all', 'repeat', 'newToOrganizer'])
                  filter: rect(
                    find.byKey(ValueKey('host-customers-summary-$filter')),
                  ),
              },
              'sort': rect(find.byKey(const ValueKey('host-customers-sort'))),
              'filters': rect(
                find.byKey(const ValueKey('host-customers-filters')),
              ),
              'rows': rowMetrics,
            });
            for (final filter in ['all', 'repeat', 'newToOrganizer']) {
              expect(
                tester
                    .getSize(
                      find.byKey(ValueKey('host-customers-summary-$filter')),
                    )
                    .height,
                greaterThanOrEqualTo(44),
              );
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
        await tester.runAsync(() async {
          await File('$_output/geometry.json').writeAsString(
            const JsonEncoder.withIndent('  ').convert(measurements),
          );
        });
      } finally {
        semantics.dispose();
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
