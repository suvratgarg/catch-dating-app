import 'dart:convert';

/// Parses NUL-delimited `git ls-files --stage` output without consulting disk.
///
/// Sparse checkouts intentionally omit many tracked files from disk. Filtering
/// this list through [File.existsSync] would therefore truncate the canonical
/// audit registry to the current sparse cone. Symlinks are excluded because the
/// registry inventories files owned by Catch, not workspace convenience links.
List<String> trackedAuditPathsFromGitIndex(String output) {
  if (output.isEmpty) return <String>[];
  if (!output.endsWith('\u0000')) {
    throw const FormatException('Git index output is not NUL terminated.');
  }

  final paths = <String>{};
  final records = output.split('\u0000')..removeLast();
  for (final record in records) {
    final separator = record.indexOf('\t');
    if (separator <= 0 || separator == record.length - 1) {
      throw FormatException('Malformed Git index record: $record');
    }
    final metadata = record.substring(0, separator).split(' ');
    final path = record.substring(separator + 1);
    if (metadata.length != 3 ||
        !RegExp(r'^[0-9a-f]+$').hasMatch(metadata[1]) ||
        metadata[2] != '0') {
      throw FormatException('Malformed Git index metadata: $record');
    }
    switch (metadata[0]) {
      case '100644':
      case '100755':
        paths.add(path);
        break;
      case '120000':
      case '160000':
        break;
      default:
        throw FormatException('Unsupported Git index mode: ${metadata[0]}');
    }
  }

  final sorted = paths.toList()..sort();
  return sorted;
}

/// Loads an authoritative JSON object from a materialized file when present,
/// or from its Git-index blob when a sparse checkout omits that file.
///
/// Missing or malformed authoritative input is an error. Returning an empty
/// object here would silently erase registry policy metadata during refresh.
Map<String, dynamic> requiredJsonObjectFromWorkingTreeOrIndex({
  required String path,
  String? workingTreeContent,
  int? indexExitCode,
  String indexStdout = '',
  String indexStderr = '',
  Iterable<String> requiredListKeys = const <String>[],
}) {
  final content =
      workingTreeContent ??
      (() {
        if (indexExitCode != 0) {
          throw StateError(
            'Required JSON file $path is absent from the working tree and cannot '
            'be read from the Git index: ${indexStderr.trim()}',
          );
        }
        return indexStdout;
      })();

  final Object? decoded;
  try {
    decoded = jsonDecode(content);
  } on FormatException catch (error) {
    throw FormatException('Required JSON file $path is invalid: $error');
  }
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Required JSON file $path must contain an object.');
  }
  for (final key in requiredListKeys) {
    if (decoded[key] is! List) {
      throw FormatException(
        'Required JSON file $path must contain a $key list.',
      );
    }
  }
  return decoded;
}

List<String> missingAuditPaths({
  required Iterable<String> requested,
  required Iterable<String> available,
}) {
  final availablePaths = available.toSet();
  final missing =
      requested.where((path) => !availablePaths.contains(path)).toSet().toList()
        ..sort();
  return missing;
}
