import 'dart:convert';
import 'dart:io';

const registryDir = 'docs/audit_registry';
const filesPath = '$registryDir/files.jsonl';
const passesPath = '$registryDir/passes.jsonl';
const docVersionsPath = '$registryDir/doc_versions.json';
const backlogPath = '$registryDir/backlog.json';
const docSummariesPath = '$registryDir/doc_summaries.json';
const rulesPath = '$registryDir/rules.json';

const trackedPaths = [
  '.github/workflows',
  'analysis_options.yaml',
  'admin',
  'analytics',
  'contracts',
  'design',
  'design_context_pack',
  'extensions',
  'firebase',
  'firebase.json',
  'lib',
  'package.json',
  'packages',
  'pubspec.lock',
  'pubspec.yaml',
  'integration_test',
  'test',
  'functions/package-lock.json',
  'functions/package.json',
  'functions/src',
  'functions/test',
  'tool',
  'website',
  'docs',
  'firestore.rules',
  'firestore.indexes.json',
  'PROJECT_CONTEXT.md',
  'README.md',
];

void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  switch (args.first) {
    case 'refresh':
      _refresh();
    case 'report':
      _report();
    case 'backlog':
      _backlog();
    case 'docs':
      _docs(args.skip(1).toList());
    case 'rules':
      _rules(args.skip(1).toList());
    case 'next':
      _next(args.skip(1).toList());
    case 'stale':
      _stale(args.skip(1).toList());
    case 'mark-pass':
      _markPass(args.skip(1).toList());
    default:
      _fail('Unknown command: ${args.first}');
  }
}

void _printHelp() {
  stdout.writeln('''
Usage: dart tool/audit_registry.dart <command>

Commands:
  refresh                 Regenerate tracked file inventory while preserving stamps.
  report                  Print compact counts by status, kind, and area.
  backlog                 Print active backlog, next-up queue, and scanner counts.
  docs [--path p]         Print compact doc summaries/read policies.
  rules [--status active] Print rules, optionally filtered by lifecycle status.
  next [--limit n]        Print highest-priority unstamped or follow-up files.
  stale --doc id --version x.y.z [--limit n]
                          Print files reviewed before a doc version.
  mark-pass --pass id --rules A,B --paths p1,p2 [--proof "..."] [--status clean]
                          Stamp touched files and append a pass receipt.
''');
}

void _refresh() {
  Directory(registryDir).createSync(recursive: true);
  final existing = _readFileEntries();
  final paths = _trackedFiles();
  final entries = <Map<String, dynamic>>[];

  for (final path in paths) {
    final previous = existing[path] ?? <String, dynamic>{};
    entries.add({
      'path': path,
      'area': previous['area'] ?? _areaFor(path),
      'kind': previous['kind'] ?? _kindFor(path),
      'status': previous['status'] ?? 'unreviewed',
      'last_pass_id': previous['last_pass_id'],
      'doc_versions': previous['doc_versions'] ?? <String, dynamic>{},
      'rules_applied': previous['rules_applied'] ?? <dynamic>[],
      'debt': previous['debt'] ?? <dynamic>[],
      'proof': previous['proof'] ?? <dynamic>[],
      'notes': previous['notes'] ?? '',
    });
  }

  _writeJsonLines(filesPath, entries);
  stdout.writeln('Refreshed ${entries.length} file entries.');
}

void _report() {
  final entries = _readFileEntries().values.toList();
  if (entries.isEmpty) {
    stdout.writeln('No file entries. Event refresh first.');
    return;
  }

  stdout.writeln('Files: ${entries.length}');
  _printCounts('Status', entries, (entry) => entry['status'] as String?);
  _printCounts('Kind', entries, (entry) => entry['kind'] as String?);
  _printCounts('Area', entries, (entry) => entry['area'] as String?);
}

void _backlog() {
  final data = _readJsonFile(backlogPath);
  if (data.isEmpty) {
    stdout.writeln('No backlog file found at $backlogPath.');
    return;
  }

  stdout.writeln(
    'Backlog ${data['version'] ?? ''} updated ${data['updated'] ?? ''}',
  );
  final scanner = data['scanner_snapshot'];
  if (scanner is Map) {
    stdout.writeln('\nScanner: ${scanner['command'] ?? ''}');
    final counts = scanner['counts'];
    if (counts is Map) {
      for (final entry in counts.entries) {
        stdout.writeln('  ${entry.key}: ${entry.value}');
      }
    }
  }

  final nextUp = data['next_up'];
  if (nextUp is List) {
    stdout.writeln('\nNext up: ${nextUp.join(', ')}');
  }

  final pending = data['pending'];
  if (pending is List) {
    stdout.writeln('\nPending:');
    for (final item in pending.whereType<Map>()) {
      stdout.writeln(
        '  ${item['id']} | ${item['status']} | ${item['priority']} | '
        '${item['title']}',
      );
    }
  }
}

void _docs(List<String> args) {
  final pathFilter = _stringOption(args, '--path');
  final data = _readJsonFile(docSummariesPath);
  final summaries = data['summaries'];
  if (summaries is! Map) {
    stdout.writeln('No doc summaries found at $docSummariesPath.');
    return;
  }

  final paths = summaries.keys.whereType<String>().where((path) {
    return pathFilter == null || path.contains(pathFilter);
  }).toList()..sort();

  for (final path in paths) {
    final summary = summaries[path];
    if (summary is! Map) continue;
    stdout.writeln('\n$path');
    stdout.writeln('  purpose: ${summary['purpose']}');
    final readWhen = summary['read_when'];
    if (readWhen is List) {
      stdout.writeln('  read_when: ${readWhen.join('; ')}');
    }
    final skipWhen = summary['skip_when'];
    if (skipWhen is List) {
      stdout.writeln('  skip_when: ${skipWhen.join('; ')}');
    }
  }
}

void _rules(List<String> args) {
  final statusFilter = _stringOption(args, '--status');
  final data = _readJsonFile(rulesPath);
  final rules = data['rules'];
  if (rules is! Map) {
    stdout.writeln('No rules found at $rulesPath.');
    return;
  }

  final ids = rules.keys.whereType<String>().where((id) {
    final rule = rules[id];
    if (statusFilter == null) return true;
    return rule is Map && rule['status'] == statusFilter;
  }).toList()..sort();

  for (final id in ids) {
    final rule = rules[id];
    if (rule is! Map) continue;
    stdout.writeln('\n$id | ${rule['status']} | ${rule['title']}');
    stdout.writeln('  ${rule['instruction']}');
  }
}

void _next(List<String> args) {
  final limit = _intOption(args, '--limit') ?? 40;
  final entries = _readFileEntries().values.toList()
    ..sort((a, b) {
      final statusCompare = _statusRank(a).compareTo(_statusRank(b));
      if (statusCompare != 0) return statusCompare;
      return (a['path'] as String).compareTo(b['path'] as String);
    });

  for (final entry in entries.take(limit)) {
    stdout.writeln(
      '${entry['status']} | ${entry['kind']} | ${entry['area']} | '
      '${entry['path']} | last=${entry['last_pass_id'] ?? 'never'}',
    );
  }
}

void _stale(List<String> args) {
  final docId = _stringOption(args, '--doc');
  final version = _stringOption(args, '--version');
  final limit = _intOption(args, '--limit') ?? 80;
  if (docId == null || version == null) {
    _fail('stale requires --doc and --version.');
  }

  final entries =
      _readFileEntries().values.where((entry) {
          final versions = entry['doc_versions'];
          if (versions is! Map) return true;
          final seen = versions[docId];
          if (seen is! String) return true;
          return _compareVersions(seen, version) < 0;
        }).toList()
        ..sort((a, b) => (a['path'] as String).compareTo(b['path'] as String));

  for (final entry in entries.take(limit)) {
    final versions = entry['doc_versions'];
    final seen = versions is Map ? versions[docId] : null;
    stdout.writeln('${entry['path']} | $docId=${seen ?? 'never'}');
  }
  stdout.writeln('Stale matches: ${entries.length}');
}

void _markPass(List<String> args) {
  final passId = _stringOption(args, '--pass');
  final rules = _csvOption(args, '--rules');
  final paths = _csvOption(args, '--paths');
  final proof = _multiOption(args, '--proof');
  final status = _stringOption(args, '--status') ?? 'reviewed';
  final notes = _stringOption(args, '--notes') ?? '';
  if (passId == null || passId.isEmpty) {
    _fail('mark-pass requires --pass.');
  }
  if (paths.isEmpty) {
    _fail('mark-pass requires --paths.');
  }

  final docVersions = _readDocVersions();
  final entries = _readFileEntries();
  if (entries.isEmpty) {
    _refresh();
    entries.addAll(_readFileEntries());
  }

  final activeDocVersions = <String, String>{};
  for (final item in docVersions.entries) {
    final value = item.value;
    if (value is Map && value['version'] is String) {
      activeDocVersions[item.key] = value['version'] as String;
    }
  }

  for (final path in paths) {
    final entry = entries[path];
    if (entry == null) {
      stderr.writeln('Skipping untracked path: $path');
      continue;
    }
    entry['status'] = status;
    entry['last_pass_id'] = passId;
    entry['doc_versions'] = {
      ...?entry['doc_versions'] as Map?,
      ...activeDocVersions,
    };
    entry['rules_applied'] = _mergedList(entry['rules_applied'], rules);
    entry['proof'] = _mergedList(entry['proof'], proof);
    if (notes.isNotEmpty) {
      entry['notes'] = notes;
    }
  }

  _writeJsonLines(
    filesPath,
    entries.values.toList()
      ..sort((a, b) => (a['path'] as String).compareTo(b['path'] as String)),
  );

  final receipt = {
    'pass_id': passId,
    'started': DateTime.now().toIso8601String().split('T').first,
    'scope': paths,
    'rules_applied': rules,
    'commands': proof,
    'outcome': status,
    'new_debt': <String>[],
    if (notes.isNotEmpty) 'notes': notes,
  };
  File(
    passesPath,
  ).writeAsStringSync('${jsonEncode(receipt)}\n', mode: FileMode.append);
  stdout.writeln('Stamped ${paths.length} path(s) for $passId.');
}

Map<String, Map<String, dynamic>> _readFileEntries() {
  final file = File(filesPath);
  if (!file.existsSync()) return {};
  final entries = <String, Map<String, dynamic>>{};
  for (final line in file.readAsLinesSync()) {
    if (line.trim().isEmpty) continue;
    final decoded = jsonDecode(line) as Map<String, dynamic>;
    entries[decoded['path'] as String] = decoded;
  }
  return entries;
}

Map<String, dynamic> _readDocVersions() {
  final file = File(docVersionsPath);
  if (!file.existsSync()) return {};
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Map<String, dynamic> _readJsonFile(String path) {
  final file = File(path);
  if (!file.existsSync()) return {};
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

List<String> _trackedFiles() {
  final result = Process.runSync('git', [
    'ls-files',
    '-co',
    '--exclude-standard',
    '--',
    ...trackedPaths,
  ]);
  if (result.exitCode != 0) {
    _fail('git ls-files failed: ${result.stderr}');
  }
  final paths =
      LineSplitter.split(result.stdout as String)
          .where((path) => path.isNotEmpty)
          .where((path) => File(path).existsSync())
          .toSet()
          .toList()
        ..sort();
  return paths;
}

String _areaFor(String path) {
  final parts = path.split('/');
  if (path == 'README.md' || path == 'PROJECT_CONTEXT.md') return 'repo';
  if (path == 'firestore.rules' || path == 'firestore.indexes.json') {
    return 'firebase';
  }
  if (parts.first == 'docs') return 'docs';
  if (parts.first == 'tool') return 'tooling';
  if (parts.first == 'packages') {
    return parts.length > 1 ? parts[1] : 'packages';
  }
  if (parts.first == 'functions') {
    return parts.length > 2 ? parts[2] : 'functions';
  }
  if (parts.first == 'test') return parts.length > 1 ? parts[1] : 'test';
  if (parts.first == 'lib') return parts.length > 1 ? parts[1] : 'lib';
  return parts.first;
}

String _kindFor(String path) {
  final name = path.split('/').last;
  if (path == 'firestore.rules' || path == 'firestore.indexes.json') {
    return 'firebase_contract';
  }
  if (path.startsWith('docs/') || name.endsWith('.md')) return 'doc';
  if (path.startsWith('tool/')) return 'tool';
  if (path.startsWith('test/')) return 'test';
  if (path.startsWith('functions/src/')) return 'function';
  if (name.contains('controller')) return 'controller';
  if (name.contains('repository')) return 'repository';
  if (name.contains('provider')) return 'provider';
  if (name.contains('screen')) return 'screen';
  if (path.contains('/widgets/') || name.contains('widget')) return 'widget';
  if (path.contains('/domain/')) return 'domain';
  if (path.contains('/data/')) return 'data';
  return 'source';
}

void _writeJsonLines(String path, List<Map<String, dynamic>> entries) {
  final sink = File(path).openWrite();
  for (final entry in entries) {
    sink.writeln(jsonEncode(entry));
  }
  sink.close();
}

void _printCounts(
  String label,
  List<Map<String, dynamic>> entries,
  String? Function(Map<String, dynamic>) valueFor,
) {
  final counts = <String, int>{};
  for (final entry in entries) {
    final value = valueFor(entry) ?? 'unknown';
    counts[value] = (counts[value] ?? 0) + 1;
  }
  stdout.writeln('\n$label:');
  final keys = counts.keys.toList()..sort();
  for (final key in keys) {
    stdout.writeln('  $key: ${counts[key]}');
  }
}

int _statusRank(Map<String, dynamic> entry) {
  switch (entry['status']) {
    case 'needs_followup':
      return 0;
    case 'unreviewed':
      return 1;
    case 'reviewed':
      return 2;
    case 'clean':
      return 3;
    default:
      return 4;
  }
}

List<String> _mergedList(Object? existing, List<String> additions) {
  final values = <String>{
    if (existing is List) ...existing.whereType<String>(),
    ...additions,
  }.toList()..sort();
  return values;
}

String? _stringOption(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

List<String> _csvOption(List<String> args, String name) {
  final value = _stringOption(args, name);
  if (value == null || value.isEmpty) return [];
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _multiOption(List<String> args, String name) {
  final values = <String>[];
  for (var i = 0; i < args.length; i += 1) {
    if (args[i] == name && i + 1 < args.length) {
      values.add(args[i + 1]);
    }
  }
  return values;
}

int? _intOption(List<String> args, String name) {
  final value = _stringOption(args, name);
  return value == null ? null : int.tryParse(value);
}

int _compareVersions(String left, String right) {
  final l = left.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  final r = right.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  for (var i = 0; i < 3; i += 1) {
    final diff = (i < l.length ? l[i] : 0) - (i < r.length ? r[i] : 0);
    if (diff != 0) return diff;
  }
  return 0;
}

Never _fail(String message) {
  stderr.writeln(message);
  exitCode = 64;
  exit(64);
}
