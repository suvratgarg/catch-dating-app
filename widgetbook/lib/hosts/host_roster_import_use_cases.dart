import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_roster_import_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_roster_mapping_field.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/page_preview.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

const _headers = ['Guest', 'Email', 'Ticket'];
const _rows = [
  ['Asha Shah', 'asha@example.com', 'General'],
  ['Ravi Rao', 'ravi@example.com', 'VIP'],
];

@widgetbook.UseCase(
  name: 'Ready and missing name mapping',
  type: HostRosterImportSheet,
  path: '[P1 product surfaces]/Host/Roster',
)
Widget hostRosterImportSheetStates(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'HostRosterImportSheet',
      catalogId: 'host.roster_import',
      children: [
        for (final mapped in [true, false])
          WidgetbookPageStateCard(
            label: mapped ? 'Ready to import' : 'Guest name mapping required',
            child: WidgetbookViewportFrame.sheet(
              size: const Size(390, 760),
              child: HostRosterImportSheet(
                table: HostRosterTable(
                  fileName: 'guests.csv',
                  format: EventAttendeeImportFormat.csv,
                  headers: _headers,
                  rows: _rows,
                  suggestedMapping: {
                    if (mapped) HostRosterField.displayName: 0,
                    HostRosterField.email: 1,
                    HostRosterField.ticketType: 2,
                  },
                  adapter: const HostRosterAdapterDetection(
                    adapterId: HostRosterAdapterId.genericV1,
                    support: HostRosterAdapterSupport.generic,
                    confidence: 1,
                  ),
                ),
                suggestedRevenueAmountMinor: 150000,
              ),
            ),
          ),
      ],
    );

@widgetbook.UseCase(
  name: 'Mapped and excluded columns',
  type: HostRosterMappingField,
  path: '[P1 product surfaces]/Host/Roster',
)
Widget hostRosterMappingFieldStates(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'HostRosterMappingField',
      catalogId: 'host.roster_mapping',
      children: [
        for (final mapped in [true, false])
          WidgetbookPageStateCard(
            label: mapped ? 'Guest samples' : 'Column excluded',
            child: WidgetbookContentFrame(
              child: HostRosterMappingField(
                field: HostRosterField.displayName,
                headers: _headers,
                rows: _rows,
                value: mapped ? 0 : null,
                onChanged: (_) {},
              ),
            ),
          ),
      ],
    );
