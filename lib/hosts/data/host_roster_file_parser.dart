import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';

/// Produces a retry-safe key for one normalized Host roster upload.
String hostRosterImportKey({
  required String fileName,
  required EventAttendeeImportFormat format,
  required List<EventAttendeeImportRow> rows,
}) {
  final canonical = jsonEncode({
    'fileName': fileName.trim().toLowerCase(),
    'format': format.name,
    'rows': [
      for (final row in rows)
        {
          'rowId': row.rowId,
          'displayName': row.displayName,
          'phone': row.phone,
          'email': row.email,
          'externalReference': row.externalReference,
          'ticketType': row.ticketType,
          'status': row.status.name,
        },
    ],
  });
  return 'host-${sha256.convert(utf8.encode(canonical))}';
}

/// Parses a bounded CSV or XLSX upload into the framework-free roster model.
HostRosterTable parseHostRosterFile({
  required String fileName,
  required Uint8List bytes,
}) {
  final extension = fileName.split('.').last.toLowerCase();
  final format = switch (extension) {
    'csv' => EventAttendeeImportFormat.csv,
    'xlsx' => EventAttendeeImportFormat.xlsx,
    _ => throw const HostRosterImportException(
      HostRosterImportIssue.unsupportedFile,
    ),
  };
  final matrix = format == EventAttendeeImportFormat.csv
      ? _parseCsv(utf8.decode(bytes, allowMalformed: false))
      : _parseXlsx(bytes);
  final nonEmptyRows = matrix
      .map((row) => row.map((value) => value.trim()).toList(growable: false))
      .where((row) => row.any((value) => value.isNotEmpty))
      .toList(growable: false);
  if (nonEmptyRows.length < 2) {
    throw const HostRosterImportException(HostRosterImportIssue.missingRows);
  }
  final headers = uniqueHostRosterHeaders(nonEmptyRows.first);
  if (headers.length > 40) {
    throw const HostRosterImportException(HostRosterImportIssue.tooManyColumns);
  }
  return HostRosterTable(
    fileName: fileName,
    format: format,
    headers: headers,
    rows: nonEmptyRows.skip(1).toList(growable: false),
    suggestedMapping: suggestHostRosterMapping(headers),
  );
}

List<List<String>> _parseCsv(String source) {
  final text = source.startsWith('\ufeff') ? source.substring(1) : source;
  final rows = <List<String>>[];
  var row = <String>[];
  var field = StringBuffer();
  var quoted = false;
  for (var index = 0; index < text.length; index += 1) {
    final character = text[index];
    if (quoted) {
      if (character == '"') {
        if (index + 1 < text.length && text[index + 1] == '"') {
          field.write('"');
          index += 1;
        } else {
          quoted = false;
        }
      } else {
        field.write(character);
      }
      continue;
    }
    if (character == '"') {
      quoted = true;
    } else if (character == ',') {
      row.add(field.toString());
      field = StringBuffer();
    } else if (character == '\n' || character == '\r') {
      if (character == '\r' &&
          index + 1 < text.length &&
          text[index + 1] == '\n') {
        index += 1;
      }
      row.add(field.toString());
      rows.add(row);
      row = <String>[];
      field = StringBuffer();
    } else {
      field.write(character);
    }
  }
  if (quoted) {
    throw const HostRosterImportException(HostRosterImportIssue.malformedCsv);
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

List<List<String>> _parseXlsx(Uint8List bytes) {
  Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes, verify: true);
  } on Object catch (error) {
    throw HostRosterImportException(
      HostRosterImportIssue.unreadableXlsx,
      cause: error,
    );
  }
  final files = {for (final file in archive.files) file.name: file};
  final sharedStrings = _xlsxSharedStrings(files['xl/sharedStrings.xml']);
  final worksheetFiles =
      files.entries
          .where(
            (entry) =>
                entry.key.startsWith('xl/worksheets/sheet') &&
                entry.key.endsWith('.xml'),
          )
          .toList()
        ..sort((left, right) => left.key.compareTo(right.key));
  if (worksheetFiles.isEmpty) {
    throw const HostRosterImportException(
      HostRosterImportIssue.missingWorksheet,
    );
  }
  final document = _parseXmlFile(worksheetFiles.first.value);
  final rows = <List<String>>[];
  for (final rowElement in _elementsNamed(document, 'row')) {
    final values = <int, String>{};
    for (final cell in rowElement.childElements.where(
      (element) => element.name.local == 'c',
    )) {
      final reference = cell.getAttribute('r') ?? '';
      final columnIndex = _xlsxColumnIndex(reference);
      if (columnIndex == null || columnIndex >= 40) continue;
      values[columnIndex] = _xlsxCellValue(cell, sharedStrings);
    }
    if (values.isEmpty) continue;
    final width = values.keys.reduce(
      (left, right) => left > right ? left : right,
    );
    rows.add([
      for (var index = 0; index <= width; index += 1) values[index] ?? '',
    ]);
  }
  return rows;
}

List<String> _xlsxSharedStrings(ArchiveFile? file) {
  if (file == null) return const [];
  final document = _parseXmlFile(file);
  return _elementsNamed(document, 'si')
      .map(
        (element) =>
            _elementsNamed(element, 't').map((text) => text.innerText).join(),
      )
      .toList(growable: false);
}

String _xlsxCellValue(XmlElement cell, List<String> sharedStrings) {
  final type = cell.getAttribute('t');
  if (type == 'inlineStr') {
    return _elementsNamed(cell, 't').map((text) => text.innerText).join();
  }
  final value = _elementsNamed(cell, 'v').firstOrNull?.innerText ?? '';
  if (type == 's') {
    final index = int.tryParse(value);
    return index != null && index >= 0 && index < sharedStrings.length
        ? sharedStrings[index]
        : '';
  }
  if (type == 'b') return value == '1' ? 'true' : 'false';
  return value;
}

XmlDocument _parseXmlFile(ArchiveFile file) {
  try {
    return XmlDocument.parse(utf8.decode(file.content));
  } on Object catch (error) {
    throw HostRosterImportException(
      HostRosterImportIssue.unreadableXlsx,
      cause: error,
    );
  }
}

Iterable<XmlElement> _elementsNamed(XmlNode node, String localName) => node
    .descendants
    .whereType<XmlElement>()
    .where((element) => element.name.local == localName);

int? _xlsxColumnIndex(String reference) {
  final letters = RegExp(r'^[A-Za-z]+').stringMatch(reference);
  if (letters == null) return null;
  var value = 0;
  for (final codeUnit in letters.toUpperCase().codeUnits) {
    value = value * 26 + codeUnit - 64;
  }
  return value - 1;
}
