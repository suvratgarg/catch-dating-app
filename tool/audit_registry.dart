import 'dart:convert';
import 'dart:io';

import 'lib/audit_inventory_policy.dart';
import 'lib/audit_registry_gap_classifier.dart';
import 'lib/audit_registry_paths.dart';

const registryDir = 'docs/audit_registry';
const filesPath = '$registryDir/files.jsonl';
const passesPath = '$registryDir/passes.jsonl';
const docVersionsPath = '$registryDir/doc_versions.json';
const backlogPath = '$registryDir/backlog.json';
const rulesPath = '$registryDir/rules.json';
const screenContractsPath = 'design/screens/catch.screens.json';
const rootManifestPath = 'tool/repository_root_manifest.json';

const trackedPaths = [
  'AGENTS.md',
  '.github/workflows',
  'android',
  'analysis_options.yaml',
  'admin',
  'analytics',
  'apps',
  'contracts',
  'design',
  'design_context_pack',
  'extensions',
  'firebase',
  'firebase.json',
  'ios',
  'lib',
  'macos',
  'operations',
  'package.json',
  'packages',
  'pubspec.lock',
  'pubspec.yaml',
  'integration_test',
  'test',
  'functions/package-lock.json',
  'functions/package.json',
  'functions/scripts',
  'functions/src',
  'functions/test',
  'tool',
  'web',
  'website',
  'widgetbook',
  'docs',
  'firestore.rules',
  'firestore.indexes.json',
  'PROJECT_CONTEXT.md',
  'README.md',
  'TESTS.md',
];

void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  switch (args.first) {
    case 'refresh':
      final options = args.skip(1).toList();
      final unknown = options.where((option) => option != '--check').toList();
      if (unknown.isNotEmpty) {
        _fail('Unknown refresh option(s): ${unknown.join(', ')}');
      }
      _refresh(check: options.contains('--check'));
    case 'report':
      _report();
    case 'backlog':
      _backlog(args.skip(1).toList());
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
  refresh [--check]       Regenerate tracked file inventory, or verify exact parity.
  report                  Print compact counts by status, kind, and area.
  backlog [--stored-scanner]
                          Print active backlog, next-up queue, and live scanner counts.
  docs [--path p]         Print compact read policies from the doc catalog.
  rules [--status active] Print rules, optionally filtered by lifecycle status.
  next [--limit n] [--screen-limit n] [--code-only]
                          Print actionable screen gaps, then unstamped/follow-up files.
                          --code-only skips reference-only/product-conditional gaps.
  stale --doc id --version x.y.z [--limit n]
                          Print files reviewed before a doc version.
  mark-pass --pass id --rules A,B --paths p1,p2 [--proof "..."] [--status clean]
                          Stamp touched files and append a pass receipt.
''');
}

void _refresh({bool check = false}) {
  Directory(registryDir).createSync(recursive: true);
  final existing = _readFileEntries();
  final paths = _trackedFiles();
  final rootManifest = _readRequiredJsonFile(rootManifestPath);
  final entries = <Map<String, dynamic>>[];

  for (final path in paths) {
    final previous = existing[path] ?? <String, dynamic>{};
    final policy = auditPolicyFor(path, rootManifest);
    final reviewPolicy = policy?['review'] as String? ?? 'file';
    final previousStatus = previous['status'];
    final previousReviewPolicy = previous['audit_policy'];
    final fileStatus =
        previous['file_status'] ??
        (previousStatus == 'aggregate'
            ? previous['last_pass_id'] == null
                  ? 'unreviewed'
                  : 'reviewed'
            : previousStatus ?? 'unreviewed');
    final fileKind =
        previous['file_kind'] ??
        (previousReviewPolicy == 'aggregate'
            ? _kindFor(path)
            : previous['kind'] ?? _kindFor(path));
    entries.add({
      'path': path,
      'area': previous['area'] ?? _areaFor(path),
      'kind': policy?['kind'] ?? fileKind,
      'status': reviewPolicy == 'aggregate' ? 'aggregate' : fileStatus,
      if (reviewPolicy != 'file') 'audit_policy': reviewPolicy,
      if (policy?['owner'] != null) 'audit_owner': policy?['owner'],
      if (reviewPolicy == 'aggregate') 'file_status': fileStatus,
      if (reviewPolicy == 'aggregate') 'file_kind': fileKind,
      'last_pass_id': previous['last_pass_id'],
      'doc_versions': previous['doc_versions'] ?? <String, dynamic>{},
      'rules_applied': previous['rules_applied'] ?? <dynamic>[],
      'debt': previous['debt'] ?? <dynamic>[],
      'proof': previous['proof'] ?? <dynamic>[],
      'notes': previous['notes'] ?? '',
    });
  }

  if (check) {
    final actual = File(filesPath).existsSync()
        ? File(filesPath).readAsStringSync()
        : '';
    final expected = _encodeJsonLines(entries);
    if (actual != expected) {
      _fail(
        'Audit registry inventory is stale. Stage additions/deletions and run '
        '`dart tool/audit_registry.dart refresh`.',
      );
    }
    stdout.writeln(
      'Audit registry inventory is current (${entries.length} file entries).',
    );
    return;
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

void _backlog(List<String> args) {
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
    final command = scanner['command'];
    if (!args.contains('--stored-scanner') && command is String) {
      final liveSummary = _liveScannerSummary(command);
      if (liveSummary != null) {
        stdout.writeln('\nScanner live: $command');
        for (final line in LineSplitter.split(liveSummary)) {
          if (line.startsWith('Widget cleanup candidate scan summary')) {
            continue;
          }
          stdout.writeln(line);
        }
      } else {
        stdout.writeln(
          '\nScanner live failed; stored snapshot follows '
          '(${scanner['updated'] ?? 'unknown'}).',
        );
        _printStoredScanner(scanner);
      }
    } else {
      _printStoredScanner(scanner);
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

String? _liveScannerSummary(String command) {
  if (command != 'bash tool/widget_cleanup_scan.sh --summary') {
    return null;
  }

  final result = Process.runSync('bash', [
    'tool/widget_cleanup_scan.sh',
    '--summary',
  ]);
  if (result.exitCode != 0) {
    return null;
  }
  return result.stdout as String;
}

void _printStoredScanner(Map scanner) {
  stdout.writeln(
    '\nScanner snapshot (${scanner['updated'] ?? 'unknown'}): '
    '${scanner['command'] ?? ''}',
  );
  final counts = scanner['counts'];
  if (counts is Map) {
    for (final entry in counts.entries) {
      stdout.writeln('  ${entry.key}: ${entry.value}');
    }
  }
}

void _docs(List<String> args) {
  final pathFilter = _stringOption(args, '--path');
  final docs = <({String path, String readPolicy})>[];
  for (final value in _readDocVersions().values) {
    if (value is! Map || value['status'] == 'retired') continue;
    final path = value['path'];
    final readPolicy = value['read_policy'];
    if (path is! String || readPolicy is! String) continue;
    if (pathFilter == null || path.contains(pathFilter)) {
      docs.add((path: path, readPolicy: readPolicy));
    }
  }
  docs.sort((a, b) => a.path.compareTo(b.path));
  if (docs.isEmpty) {
    _fail('No governed document read policy matched ${pathFilter ?? 'all'}.');
  }
  for (final doc in docs) {
    stdout.writeln('\n${doc.path}');
    stdout.writeln('  read_policy: ${doc.readPolicy}');
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
  final screenLimit = _intOption(args, '--screen-limit') ?? 12;
  final codeOnly = args.contains('--code-only');
  final screenGaps = _actionableScreenGaps(codeOnly: codeOnly);
  if (screenLimit > 0) {
    stdout.writeln(
      codeOnly
          ? 'Engineering-actionable screen gaps:'
          : 'Actionable screen gaps:',
    );
    if (screenGaps.isEmpty) {
      stdout.writeln('  none');
    } else {
      for (final gap in screenGaps.take(screenLimit)) {
        stdout.writeln(
          '  ${gap.priority} | ${gap.screenId} | ${gap.gapId} | '
          '${gap.status} | ${gap.actionKind} | '
          '${_truncate(gap.nextAction, 180)}',
        );
      }
      if (screenGaps.length > screenLimit) {
        stdout.writeln(
          '  ... ${screenGaps.length - screenLimit} more; rerun with '
          '--screen-limit ${screenGaps.length} to show all.',
        );
      }
    }
    stdout.writeln();
  }

  stdout.writeln('Unreviewed/follow-up files:');
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

List<_ScreenGap> _actionableScreenGaps({bool codeOnly = false}) {
  final data = _readJsonFile(screenContractsPath);
  final screens = data['screens'];
  if (screens is! List) return const <_ScreenGap>[];

  final gaps = <_ScreenGap>[];
  for (final screen in screens.whereType<Map>()) {
    final screenStatus = '${screen['status'] ?? ''}';
    if (_isBlockedStatus(screenStatus)) continue;
    final priority = '${screen['priority'] ?? 'P4'}';
    final screenId = '${screen['id'] ?? 'screen.unknown'}';
    final openGaps = screen['openGaps'];
    if (openGaps is! List) continue;
    for (final gap in openGaps.whereType<Map>()) {
      final status = '${gap['status'] ?? ''}';
      final nextAction = '${gap['nextAction'] ?? ''}';
      if (!_isActionableGap(status, nextAction)) continue;
      final actionKind = classifyScreenGapAction(nextAction);
      if (codeOnly && actionKind != 'engineering' && actionKind != 'mixed') {
        continue;
      }
      gaps.add(
        _ScreenGap(
          priority: priority,
          screenId: screenId,
          gapId: '${gap['id'] ?? 'unknown'}',
          status: status,
          nextAction: nextAction,
          actionKind: actionKind,
        ),
      );
    }
  }

  gaps.sort((a, b) {
    final priorityCompare = _priorityRank(
      a.priority,
    ).compareTo(_priorityRank(b.priority));
    if (priorityCompare != 0) return priorityCompare;
    final screenCompare = a.screenId.compareTo(b.screenId);
    if (screenCompare != 0) return screenCompare;
    return a.gapId.compareTo(b.gapId);
  });
  return gaps;
}

bool _isActionableGap(String status, String nextAction) {
  if (status == 'closed') return false;
  if (_isBlockedStatus(status)) return false;
  final lowerAction = nextAction.toLowerCase();
  if (_containsAny(lowerAction, const [
    'if contractual',
    'if product keeps',
    'if product wants',
    'if that surface keeps growing',
    'owner/product',
    'product decision',
    'product-only',
    'product review',
  ])) {
    return false;
  }
  if (lowerAction.contains('owner-blocked')) return false;
  if (lowerAction.contains('blocked until')) return false;
  if (lowerAction.contains('blocked:')) return false;
  return true;
}

bool _containsAny(String value, List<String> needles) {
  for (final needle in needles) {
    if (value.contains(needle)) return true;
  }
  return false;
}

bool _isBlockedStatus(String status) => status.toLowerCase().contains('block');

int _priorityRank(String priority) {
  switch (priority) {
    case 'P1':
      return 0;
    case 'P2':
      return 1;
    case 'P3':
      return 2;
    case 'P4':
      return 3;
    default:
      return 4;
  }
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength - 3)}...';
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

  final absentFromIndex = missingAuditPaths(
    requested: paths,
    available: _trackedFiles(),
  );
  if (absentFromIndex.isNotEmpty) {
    _fail(
      'Audit pass scope is absent from the Git index: '
      '${absentFromIndex.join(', ')}. Record staged deletions in receipt proof '
      'and stamp their surviving governing files.',
    );
  }

  final missingPaths = missingAuditPaths(
    requested: paths,
    available: entries.keys,
  );
  if (missingPaths.isNotEmpty) {
    _fail(
      'Audit registry is missing indexed path(s): ${missingPaths.join(', ')}. '
      'Stage new files, run refresh, then retry mark-pass.',
    );
  }

  for (final path in paths) {
    final entry = entries[path];
    if (entry == null) continue;
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

Map<String, dynamic> _readRequiredJsonFile(String path) {
  final file = File(path);
  String? workingTreeContent;
  ProcessResult? indexResult;
  if (file.existsSync()) {
    workingTreeContent = file.readAsStringSync();
  } else {
    indexResult = Process.runSync('git', ['show', ':$path']);
  }

  try {
    return requiredJsonObjectFromWorkingTreeOrIndex(
      path: path,
      workingTreeContent: workingTreeContent,
      indexExitCode: indexResult?.exitCode,
      indexStdout: indexResult?.stdout as String? ?? '',
      indexStderr: indexResult?.stderr as String? ?? '',
      requiredListKeys: const ['auditPolicies'],
    );
  } on Object catch (error) {
    _fail(error.toString());
  }
}

List<String> _trackedFiles() {
  final result = Process.runSync('git', [
    'ls-files',
    '--stage',
    '--cached',
    '-z',
    '--',
    ...trackedPaths,
  ]);
  if (result.exitCode != 0) {
    _fail('git ls-files failed: ${result.stderr}');
  }
  return trackedAuditPathsFromGitIndex(result.stdout as String);
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
  File(path).writeAsStringSync(_encodeJsonLines(entries));
}

String _encodeJsonLines(List<Map<String, dynamic>> entries) {
  final buffer = StringBuffer();
  for (final entry in entries) {
    buffer.writeln(jsonEncode(entry));
  }
  return buffer.toString();
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

class _ScreenGap {
  const _ScreenGap({
    required this.priority,
    required this.screenId,
    required this.gapId,
    required this.status,
    required this.nextAction,
    required this.actionKind,
  });

  final String priority;
  final String screenId;
  final String gapId;
  final String status;
  final String nextAction;
  final String actionKind;
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
