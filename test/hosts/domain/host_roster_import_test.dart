import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/hosts/data/host_roster_file_parser.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CSV parser maps common columns and quoted values', () {
    final table = parseHostRosterFile(
      fileName: 'guests.csv',
      bytes: Uint8List.fromList(
        utf8.encode(
          'Full Name,Mobile,Email,Ticket Type,Status\r\n'
          '"Shah, Asha",9876543210,asha@example.com,General,Confirmed\r\n'
          'Ravi Rao,+919812345678,ravi@example.com,VIP,Waitlisted',
        ),
      ),
    );

    expect(table.suggestedMapping[HostRosterField.displayName], 0);
    expect(table.suggestedMapping[HostRosterField.phone], 1);
    final mapped = table.mapRows(table.suggestedMapping);
    expect(mapped.issues, isEmpty);
    expect(mapped.rows, hasLength(2));
    expect(mapped.rows.first.displayName, 'Shah, Asha');
    expect(mapped.rows.last.status, EventAttendeeStatus.waitlisted);
  });

  test('mapping requires an explicit guest-name column', () {
    final table = parseHostRosterFile(
      fileName: 'guests.csv',
      bytes: Uint8List.fromList(utf8.encode('Phone\n9876543210')),
    );

    final mapped = table.mapRows(table.suggestedMapping);
    expect(mapped.rows, isEmpty);
    expect(mapped.issues.single.type, HostRosterRowIssueType.missingNameColumn);
  });

  test('file import keys are content-stable and change with mapped data', () {
    const first = EventAttendeeImportRow(
      rowId: '2',
      displayName: 'Asha Shah',
      status: EventAttendeeStatus.registered,
    );
    final original = hostRosterImportKey(
      fileName: 'Guests.csv',
      format: EventAttendeeImportFormat.csv,
      rows: const [first],
    );
    expect(
      hostRosterImportKey(
        fileName: 'guests.csv',
        format: EventAttendeeImportFormat.csv,
        rows: const [first],
      ),
      original,
    );
    expect(
      hostRosterImportKey(
        fileName: 'guests.csv',
        format: EventAttendeeImportFormat.csv,
        rows: const [
          EventAttendeeImportRow(
            rowId: '2',
            displayName: 'Asha Shah updated',
            status: EventAttendeeStatus.registered,
          ),
        ],
      ),
      isNot(original),
    );
  });

  test('XLSX parser reads shared strings from the first worksheet', () {
    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          'xl/sharedStrings.xml',
          '<?xml version="1.0"?>'
              '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
              '<si><t>Guest Name</t></si><si><t>Phone</t></si>'
              '<si><t>Asha Shah</t></si><si><t>9876543210</t></si>'
              '</sst>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'xl/worksheets/sheet1.xml',
          '<?xml version="1.0"?>'
              '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
              '<sheetData>'
              '<row r="1"><c r="A1" t="s"><v>0</v></c>'
              '<c r="B1" t="s"><v>1</v></c></row>'
              '<row r="2"><c r="A2" t="s"><v>2</v></c>'
              '<c r="B2" t="s"><v>3</v></c></row>'
              '</sheetData></worksheet>',
        ),
      );
    final bytes = ZipEncoder().encode(archive);

    final table = parseHostRosterFile(
      fileName: 'guests.xlsx',
      bytes: Uint8List.fromList(bytes),
    );
    final mapped = table.mapRows(table.suggestedMapping);

    expect(mapped.issues, isEmpty);
    expect(mapped.rows.single.displayName, 'Asha Shah');
    expect(mapped.rows.single.phone, '9876543210');
  });
}
