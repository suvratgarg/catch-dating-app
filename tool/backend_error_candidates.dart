import 'dart:convert';
import 'dart:io';

const defaultRoots = ['lib', 'test'];
const generatedSuffixes = ['.g.dart', '.freezed.dart'];

final rules = <CandidateRule>[
  CandidateRule(
    id: 'legacy_firestore_wrapper',
    status: CandidateStatus.mustMigrate,
    pattern: RegExp(r'\bwithFirestoreErrorContext\b'),
    recommendation:
        'Replace with withBackendErrorContext or withBackendErrorStream.',
  ),
  CandidateRule(
    id: 'legacy_firestore_message',
    status: CandidateStatus.mustMigrate,
    pattern: RegExp(r'\bfirestoreErrorMessage\b'),
    recommendation: 'Replace with appErrorMessage or backendErrorMessage.',
  ),
  CandidateRule(
    id: 'legacy_auth_message',
    status: CandidateStatus.mustMigrate,
    pattern: RegExp(r'\b(authErrorMessage|generalErrorMessage)\b'),
    recommendation: 'Replace with appErrorMessage or backendErrorMessage.',
  ),
  CandidateRule(
    id: 'legacy_run_booking_message',
    status: CandidateStatus.mustMigrate,
    pattern: RegExp(r'\brunBookingErrorMessage\b'),
    recommendation: 'Replace with appErrorMessage and AppErrorContext.run.',
  ),
  CandidateRule(
    id: 'legacy_firestore_exception',
    status: CandidateStatus.mustMigrate,
    pattern: RegExp(r'\bFirestoreWriteException\b'),
    recommendation:
        'Replace with BackendOperationException and BackendErrorContext.',
  ),
  CandidateRule(
    id: 'direct_functions_callable',
    status: CandidateStatus.review,
    pattern: RegExp(r'\.httpsCallable\('),
    recommendation: 'Verify callable is wrapped in withBackendErrorContext.',
  ),
  CandidateRule(
    id: 'direct_firestore_stream',
    status: CandidateStatus.review,
    pattern: RegExp(r'\.snapshots\('),
    requiredImport: 'cloud_firestore',
    recommendation: 'Verify stream is wrapped in withBackendErrorStream.',
  ),
  CandidateRule(
    id: 'direct_firestore_read',
    status: CandidateStatus.review,
    pattern: RegExp(r'\.get\('),
    requiredImport: 'cloud_firestore',
    recommendation: 'Verify read future is wrapped in withBackendErrorContext.',
  ),
  CandidateRule(
    id: 'direct_firestore_write',
    status: CandidateStatus.review,
    pattern: RegExp(r'\.(set|update|delete)\('),
    requiredImport: 'cloud_firestore',
    recommendation:
        'Verify write future is wrapped in withBackendErrorContext.',
  ),
  CandidateRule(
    id: 'raw_firebase_exception_type',
    status: CandidateStatus.review,
    pattern: RegExp(
      r'\b(FirebaseException|FirebaseAuthException|FirebaseFunctionsException)\b',
    ),
    recommendation:
        'Verify raw Firebase errors are mapped through backend error utilities.',
  ),
  CandidateRule(
    id: 'manual_error_logging',
    status: CandidateStatus.review,
    pattern: RegExp(r'\.logError\('),
    recommendation: 'Expected AppException paths should use logAppException.',
  ),
  CandidateRule(
    id: 'backend_error_api',
    status: CandidateStatus.migrated,
    pattern: RegExp(
      r'\b(withBackendErrorContext|withBackendErrorStream|normalizeBackendError|backendErrorMessage|appErrorMessage)\b',
    ),
    recommendation: 'Already using the unified backend error API.',
  ),
];

void main(List<String> args) {
  final jsonOutput = args.contains('--json');
  final markdownOutput = args.contains('--markdown');
  final roots = _rootsFromArgs(args);
  final candidates = _scan(roots);

  if (jsonOutput) {
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'roots': roots,
        'summary': _summary(candidates),
        'candidates': candidates
            .map((candidate) => candidate.toJson())
            .toList(),
      }),
    );
    return;
  }

  if (markdownOutput) {
    _printMarkdown(roots, candidates);
    return;
  }

  _printText(roots, candidates);
}

List<String> _rootsFromArgs(List<String> args) {
  final roots = <String>[];
  for (final arg in args) {
    if (arg.startsWith('--')) continue;
    roots.add(arg);
  }
  return roots.isEmpty ? defaultRoots : roots;
}

List<Candidate> _scan(List<String> roots) {
  final candidates = <Candidate>[];
  for (final root in roots) {
    final entity = FileSystemEntity.typeSync(root);
    if (entity == FileSystemEntityType.notFound) continue;
    final files = entity == FileSystemEntityType.file
        ? [File(root)]
        : Directory(root)
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      if (generatedSuffixes.any(file.path.endsWith)) continue;
      final content = file.readAsStringSync();
      final imports = RegExp(
        r'''import ['"]package:([^'"]+)['"]''',
      ).allMatches(content).map((match) => match.group(1) ?? '').join('\n');
      final lines = const LineSplitter().convert(content);
      for (var i = 0; i < lines.length; i += 1) {
        final line = lines[i];
        for (final rule in rules) {
          final requiredImport = rule.requiredImport;
          if (requiredImport != null && !imports.contains(requiredImport)) {
            continue;
          }
          if (!rule.pattern.hasMatch(line)) continue;
          candidates.add(
            Candidate(
              path: file.path,
              line: i + 1,
              rule: rule,
              snippet: line.trim(),
            ),
          );
        }
      }
    }
  }

  candidates.sort((a, b) {
    final statusCompare = a.rule.status.index.compareTo(b.rule.status.index);
    if (statusCompare != 0) return statusCompare;
    final pathCompare = a.path.compareTo(b.path);
    if (pathCompare != 0) return pathCompare;
    return a.line.compareTo(b.line);
  });
  return candidates;
}

Map<String, int> _summary(List<Candidate> candidates) {
  final summary = <String, int>{
    for (final status in CandidateStatus.values) status.name: 0,
  };
  for (final candidate in candidates) {
    summary[candidate.rule.status.name] =
        (summary[candidate.rule.status.name] ?? 0) + 1;
  }
  return summary;
}

void _printText(List<String> roots, List<Candidate> candidates) {
  stdout.writeln('Backend error candidates');
  stdout.writeln('roots: ${roots.join(', ')}');
  for (final entry in _summary(candidates).entries) {
    stdout.writeln('${entry.key}: ${entry.value}');
  }
  stdout.writeln('');
  for (final candidate in candidates) {
    stdout.writeln(
      '${candidate.rule.status.name} | ${candidate.rule.id} | '
      '${candidate.path}:${candidate.line} | ${candidate.snippet}',
    );
  }
}

void _printMarkdown(List<String> roots, List<Candidate> candidates) {
  stdout.writeln('# Backend Error Candidate Scan');
  stdout.writeln('');
  stdout.writeln('- Roots: `${roots.join('`, `')}`');
  for (final entry in _summary(candidates).entries) {
    stdout.writeln('- ${entry.key}: ${entry.value}');
  }
  stdout.writeln('');
  stdout.writeln('| Status | Rule | Location | Recommendation |');
  stdout.writeln('|---|---|---|---|');
  for (final candidate in candidates) {
    stdout.writeln(
      '| ${candidate.rule.status.name} | ${candidate.rule.id} | '
      '`${candidate.path}:${candidate.line}` | '
      '${candidate.rule.recommendation} |',
    );
  }
}

enum CandidateStatus { mustMigrate, review, migrated }

class CandidateRule {
  const CandidateRule({
    required this.id,
    required this.status,
    required this.pattern,
    required this.recommendation,
    this.requiredImport,
  });

  final String id;
  final CandidateStatus status;
  final RegExp pattern;
  final String recommendation;
  final String? requiredImport;
}

class Candidate {
  const Candidate({
    required this.path,
    required this.line,
    required this.rule,
    required this.snippet,
  });

  final String path;
  final int line;
  final CandidateRule rule;
  final String snippet;

  Map<String, Object> toJson() => {
    'path': path,
    'line': line,
    'rule': rule.id,
    'status': rule.status.name,
    'recommendation': rule.recommendation,
    'snippet': snippet,
  };
}
