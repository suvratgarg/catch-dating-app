import 'package:catch_dating_app/events/domain/event_attendee.dart';

enum HostRosterField {
  displayName,
  phone,
  email,
  externalReference,
  ticketType,
  status,
}

enum HostRosterImportIssue {
  unsupportedFile,
  missingRows,
  tooManyColumns,
  malformedCsv,
  unreadableXlsx,
  missingWorksheet,
}

class HostRosterImportException implements Exception {
  const HostRosterImportException(this.issue, {this.cause});

  final HostRosterImportIssue issue;
  final Object? cause;

  @override
  String toString() => 'HostRosterImportException($issue, $cause)';
}

enum HostRosterRowIssueType { missingNameColumn, missingName }

class HostRosterRowIssue {
  const HostRosterRowIssue(this.type, {this.rowNumber});

  final HostRosterRowIssueType type;
  final int? rowNumber;
}

class HostRosterTable {
  const HostRosterTable({
    required this.fileName,
    required this.format,
    required this.headers,
    required this.rows,
    required this.suggestedMapping,
  });

  final String fileName;
  final EventAttendeeImportFormat format;
  final List<String> headers;
  final List<List<String>> rows;
  final Map<HostRosterField, int?> suggestedMapping;

  HostRosterMappedRows mapRows(Map<HostRosterField, int?> mapping) {
    final nameColumn = mapping[HostRosterField.displayName];
    if (nameColumn == null) {
      return const HostRosterMappedRows(
        rows: [],
        issues: [HostRosterRowIssue(HostRosterRowIssueType.missingNameColumn)],
        truncatedCount: 0,
      );
    }
    final mapped = <EventAttendeeImportRow>[];
    final issues = <HostRosterRowIssue>[];
    final boundedRows = rows.take(250).toList(growable: false);
    for (var index = 0; index < boundedRows.length; index += 1) {
      final source = boundedRows[index];
      final displayName = _valueAt(source, nameColumn);
      if (displayName.isEmpty) {
        issues.add(
          HostRosterRowIssue(
            HostRosterRowIssueType.missingName,
            rowNumber: index + 2,
          ),
        );
        continue;
      }
      mapped.add(
        EventAttendeeImportRow(
          rowId: '${index + 2}',
          displayName: displayName,
          phone: _nullableValueAt(source, mapping[HostRosterField.phone]),
          email: _nullableValueAt(source, mapping[HostRosterField.email]),
          externalReference: _nullableValueAt(
            source,
            mapping[HostRosterField.externalReference],
          ),
          ticketType: _nullableValueAt(
            source,
            mapping[HostRosterField.ticketType],
          ),
          status: _parseStatus(
            _nullableValueAt(source, mapping[HostRosterField.status]),
          ),
        ),
      );
    }
    return HostRosterMappedRows(
      rows: mapped,
      issues: issues,
      truncatedCount: rows.length > 250 ? rows.length - 250 : 0,
    );
  }
}

class HostRosterMappedRows {
  const HostRosterMappedRows({
    required this.rows,
    required this.issues,
    required this.truncatedCount,
  });

  final List<EventAttendeeImportRow> rows;
  final List<HostRosterRowIssue> issues;
  final int truncatedCount;
}

List<String> uniqueHostRosterHeaders(List<String> rawHeaders) {
  final counts = <String, int>{};
  return [
    for (var index = 0; index < rawHeaders.length; index += 1)
      () {
        final base = rawHeaders[index].trim().isEmpty
            ? 'Column ${index + 1}'
            : rawHeaders[index].trim();
        final count = counts.update(
          base,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        return count == 1 ? base : '$base ($count)';
      }(),
  ];
}

Map<HostRosterField, int?> suggestHostRosterMapping(List<String> headers) {
  int? firstAlias(Set<String> aliases) {
    for (var index = 0; index < headers.length; index += 1) {
      final normalized = _normalizeHeader(headers[index]);
      if (aliases.contains(normalized)) return index;
    }
    return null;
  }

  return {
    HostRosterField.displayName: firstAlias({
      'name',
      'fullname',
      'guestname',
      'attendeename',
      'participantname',
    }),
    HostRosterField.phone: firstAlias({
      'phone',
      'phonenumber',
      'mobile',
      'mobilenumber',
      'contactnumber',
      'whatsapp',
    }),
    HostRosterField.email: firstAlias({'email', 'emailaddress'}),
    HostRosterField.externalReference: firstAlias({
      'id',
      'reference',
      'bookingid',
      'orderid',
      'ticketid',
    }),
    HostRosterField.ticketType: firstAlias({
      'ticket',
      'tickettype',
      'category',
      'pass',
    }),
    HostRosterField.status: firstAlias({
      'status',
      'registrationstatus',
      'bookingstatus',
      'rsvpstatus',
    }),
  };
}

String _normalizeHeader(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

String _valueAt(List<String> row, int index) =>
    index >= 0 && index < row.length ? row[index].trim() : '';

String? _nullableValueAt(List<String> row, int? index) {
  if (index == null) return null;
  final value = _valueAt(row, index);
  return value.isEmpty ? null : value;
}

EventAttendeeStatus _parseStatus(String? value) {
  final normalized = _normalizeHeader(value ?? '');
  if ({'waitlist', 'waitlisted', 'waiting'}.contains(normalized)) {
    return EventAttendeeStatus.waitlisted;
  }
  if ({'invited', 'invite', 'pending'}.contains(normalized)) {
    return EventAttendeeStatus.invited;
  }
  return EventAttendeeStatus.registered;
}
