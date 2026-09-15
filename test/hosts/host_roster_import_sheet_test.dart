import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_roster_import_sheet.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('phone import footer is reachable at text scale $scale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      HostRosterImportPlan? imported;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: CatchButton(
                  label: 'Open guest import',
                  onPressed: () async {
                    imported = await showHostRosterMapping(context, _table);
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open guest import'));
      await pumpFeatureUi(tester);
      expect(tester.takeException(), isNull);
      final importAction = find.text('Import 2 guests');
      expect(importAction.hitTestable(), findsNothing);
      await tester.ensureVisible(importAction);
      await pumpFeatureUi(tester);
      await tester.tap(importAction);
      await pumpFeatureUi(tester);
      expect(imported?.rows.map((row) => row.displayName), ['Asha', 'Ravi']);
      expect(find.byType(HostRosterImportSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

const _table = HostRosterTable(
  fileName: 'guests.csv',
  format: EventAttendeeImportFormat.csv,
  headers: ['Guest', 'Email'],
  rows: [
    ['Asha', 'asha@example.com'],
    ['Ravi', 'ravi@example.com'],
  ],
  suggestedMapping: {HostRosterField.displayName: 0, HostRosterField.email: 1},
  adapter: HostRosterAdapterDetection(
    adapterId: HostRosterAdapterId.genericV1,
    support: HostRosterAdapterSupport.generic,
    confidence: 1,
  ),
);
