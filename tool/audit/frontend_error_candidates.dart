import 'dart:convert';
import 'dart:io';

/// Frontend / local / provider / plugin / global error-handling candidate
/// scanner.
///
/// This is the non-backend parallel to `tool/audit/backend_error_candidates.dart`.
/// The backend scanner owns Firebase service call sites; this scanner owns
/// everything the app does locally or through a platform plugin:
///
/// - bare `catch (_)` / `catch (e)` that may swallow errors,
/// - `.catchError(...)` callbacks that swallow,
/// - raw `print` / `debugPrint` of errors,
/// - validation throwing raw strings / `StateError` / `ArgumentError`,
/// - plugin side effects (image picker, url_launcher, share, permissions,
///   geolocation, notifications) that may not normalize failures,
/// - `FlutterError.onError` / `PlatformDispatcher.onError` / `ErrorWidget`
///   global-handler setup, and
/// - usage of the new frontend op-context API
///   (`withAppErrorContext` / `normalizeAppError` / `logAppError` /
///   `runLoggingAppErrors`).
///
/// Each candidate is classified into stable buckets:
/// `mustMigrate`, `review`, `verified`, `intentional`, `fixture`, `migrated`.
/// The finished-state invariant is `mustMigrate == 0` and `review == 0`.
const defaultRoots = ['lib', 'test'];
const generatedSuffixes = ['.g.dart', '.freezed.dart', '.mocks.dart'];

final rules = <CandidateRule>[
  // Usage of the unified frontend op-context API → already migrated.
  CandidateRule(
    id: 'frontend_error_api',
    status: CandidateStatus.migrated,
    pattern: RegExp(
      r'\b(withAppErrorContext|normalizeAppError|logAppError|runLoggingAppErrors)\b',
    ),
    recommendation: 'Already using the unified frontend op-context API.',
  ),
  // Bare catch sites that may swallow a failure.
  CandidateRule(
    id: 'bare_catch',
    status: CandidateStatus.review,
    pattern: RegExp(r'\}\s*catch\s*\(\s*_\s*(,\s*_?\w*\s*)?\)'),
    recommendation:
        'Bare catch: log via logAppError/ErrorLogger, surface to the user, '
        'rethrow, or document why the failure is intentionally swallowed.',
  ),
  CandidateRule(
    id: 'named_catch',
    status: CandidateStatus.review,
    pattern: RegExp(r'\}\s*catch\s*\(\s*(e|err|ex|error|exception)\b'),
    recommendation:
        'Normalize and surface/log the caught error, or document the swallow.',
  ),
  CandidateRule(
    id: 'catch_error_callback',
    status: CandidateStatus.review,
    pattern: RegExp(r'\.catchError\('),
    recommendation:
        'catchError callback: forward to a completer, log, or rethrow — '
        'do not silently discard.',
  ),
  // Raw error printing.
  CandidateRule(
    id: 'raw_error_print',
    status: CandidateStatus.review,
    pattern: RegExp(r'\b(print|debugPrint)\s*\([^)]*\$(e|err|error|stack)\b'),
    recommendation:
        'Route error output through ErrorLogger/logAppError instead of raw '
        'print/debugPrint.',
  ),
  // Raw throws that may be user-correctable validation.
  CandidateRule(
    id: 'raw_string_throw',
    status: CandidateStatus.review,
    pattern: RegExp(r'''\bthrow\s+(['"]|Exception\s*\()'''),
    recommendation:
        'Throw a typed AppException (e.g. ValidationException) for product '
        'failures instead of a raw string/Exception.',
  ),
  CandidateRule(
    id: 'state_error_throw',
    status: CandidateStatus.review,
    pattern: RegExp(r'\bthrow\s+StateError\s*\('),
    recommendation:
        'User-correctable failures should throw ValidationException; keep '
        'StateError only for true invariant/programmer bugs.',
  ),
  CandidateRule(
    id: 'argument_error_throw',
    status: CandidateStatus.review,
    pattern: RegExp(r'\bthrow\s+ArgumentError'),
    recommendation:
        'User-correctable failures should throw ValidationException; keep '
        'ArgumentError only for programmer-guard preconditions.',
  ),
  // Plugin / platform side effects. Match true plugin/package invocations
  // (the raw seam), not higher-level repository methods that merely happen to
  // share a name (e.g. a repository `pickImage` that already wraps the picker).
  CandidateRule(
    id: 'plugin_side_effect',
    status: CandidateStatus.review,
    pattern: RegExp(
      r'(\blaunchUrl(String)?\s*\(|\bSharePlus\b|'
      r'\b_picker\.pickImage\s*\(|\b_picker\.pickMultiImage\s*\(|'
      r'\bGeolocator\.|\.requestPermission\s*\(|\.getCurrentPosition\s*\(|'
      r'\bflutterLocalNotifications\b|\bSharedPreferences\.getInstance\s*\(|'
      r'\bFlutterSecureStorage\b)',
    ),
    recommendation:
        'Verify the plugin call is wrapped in withAppErrorContext or a '
        'normalizing seam so plugin failures become typed app exceptions.',
  ),
  // Global framework / platform handlers.
  CandidateRule(
    id: 'global_error_handler',
    status: CandidateStatus.review,
    pattern: RegExp(
      r'\b(FlutterError\.onError|PlatformDispatcher\.instance\.onError|'
      r'ErrorWidget\.builder|FlutterError\.presentError)\b',
    ),
    recommendation:
        'Global handler: confirm it forwards to ErrorLogger / branded '
        'framework fallback and stays installed.',
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
        if (_isComment(line)) continue;
        for (final rule in rules) {
          final requiredImport = rule.requiredImport;
          if (requiredImport != null && !imports.contains(requiredImport)) {
            continue;
          }
          if (!rule.pattern.hasMatch(line)) continue;
          final disposition = _dispositionFor(
            path: file.path,
            lineIndex: i,
            lines: lines,
            rule: rule,
          );
          candidates.add(
            Candidate(
              path: file.path,
              line: i + 1,
              rule: rule,
              status: disposition.status,
              disposition: disposition.reason,
              recommendation: disposition.recommendation ?? rule.recommendation,
              snippet: line.trim(),
            ),
          );
        }
      }
    }
  }

  candidates.sort((a, b) {
    final statusCompare = a.status.index.compareTo(b.status.index);
    if (statusCompare != 0) return statusCompare;
    final pathCompare = a.path.compareTo(b.path);
    if (pathCompare != 0) return pathCompare;
    return a.line.compareTo(b.line);
  });
  return candidates;
}

bool _isComment(String line) {
  final trimmed = line.trimLeft();
  return trimmed.startsWith('//') ||
      trimmed.startsWith('*') ||
      trimmed.startsWith('/*');
}

Map<String, int> _summary(List<Candidate> candidates) {
  final summary = <String, int>{
    for (final status in CandidateStatus.values) status.name: 0,
  };
  for (final candidate in candidates) {
    summary[candidate.status.name] = (summary[candidate.status.name] ?? 0) + 1;
  }
  return summary;
}

void _printText(List<String> roots, List<Candidate> candidates) {
  stdout.writeln('Frontend error candidates');
  stdout.writeln('roots: ${roots.join(', ')}');
  for (final entry in _summary(candidates).entries) {
    stdout.writeln('${entry.key}: ${entry.value}');
  }
  stdout.writeln();
  for (final candidate in candidates) {
    stdout.writeln(
      '${candidate.status.name} | ${candidate.rule.id} | '
      '${candidate.path}:${candidate.line} | ${candidate.disposition} | '
      '${candidate.snippet}',
    );
  }
}

void _printMarkdown(List<String> roots, List<Candidate> candidates) {
  stdout.writeln('# Frontend Error Candidate Scan');
  stdout.writeln();
  stdout.writeln('- Roots: `${roots.join('`, `')}`');
  for (final entry in _summary(candidates).entries) {
    stdout.writeln('- ${entry.key}: ${entry.value}');
  }
  stdout.writeln();
  stdout.writeln('| Status | Rule | Location | Recommendation |');
  stdout.writeln('|---|---|---|---|');
  for (final candidate in candidates) {
    stdout.writeln(
      '| ${candidate.status.name} | ${candidate.rule.id} | '
      '`${candidate.path}:${candidate.line}` | '
      '${candidate.disposition}: ${candidate.recommendation} |',
    );
  }
}

CandidateDisposition _dispositionFor({
  required String path,
  required int lineIndex,
  required List<String> lines,
  required CandidateRule rule,
}) {
  if (rule.status != CandidateStatus.review) {
    return CandidateDisposition(
      status: rule.status,
      reason: rule.status == CandidateStatus.migrated
          ? 'uses unified frontend op-context API'
          : 'flagged candidate',
    );
  }

  // Tests and fixtures: classify so the scanner is actionable but does not
  // demand production normalization inside test code.
  if (_isTestPath(path)) {
    return const CandidateDisposition(
      status: CandidateStatus.fixture,
      reason: 'test fixture / fake / assertion',
    );
  }

  // ── Bootstrap / framework / central logging seams ──────────────────────────
  if (rule.id == 'global_error_handler') {
    if (path == 'lib/app_bootstrap.dart' || path == 'lib/main.dart') {
      return const CandidateDisposition(
        status: CandidateStatus.intentional,
        reason: 'bootstrap owns framework/platform global error handlers',
      );
    }
    return const CandidateDisposition(
      status: CandidateStatus.review,
      reason: 'global handler outside bootstrap — confirm it is intentional',
    );
  }

  // The central logger and the op-context layer are the implementations that
  // own raw logging / normalization themselves.
  if (_isCoreErrorInfraFile(path)) {
    return const CandidateDisposition(
      status: CandidateStatus.intentional,
      reason: 'core error infrastructure owns raw logging/normalization',
    );
  }

  // ── Raw error printing ─────────────────────────────────────────────────────
  if (rule.id == 'raw_error_print') {
    if (_near(lines, lineIndex, before: 4, after: 1, needle: 'assert(')) {
      return const CandidateDisposition(
        status: CandidateStatus.intentional,
        reason: 'debug-only assert(() {...}) diagnostic, swallowed in release',
      );
    }
    if (path == 'lib/app_bootstrap.dart' || path == 'lib/main.dart') {
      // Bootstrap runs before ErrorLogger is constructed; best-effort warmup
      // diagnostics can only go to the console at this point.
      return const CandidateDisposition(
        status: CandidateStatus.intentional,
        reason: 'pre-logger bootstrap diagnostic (ErrorLogger not yet built)',
      );
    }
    return const CandidateDisposition(
      status: CandidateStatus.review,
      reason: 'raw print/debugPrint of an error outside debug-only diagnostics',
    );
  }

  // ── Raw throws (validation vs programmer guard) ────────────────────────────
  if (rule.id == 'state_error_throw' ||
      rule.id == 'argument_error_throw' ||
      rule.id == 'raw_string_throw') {
    return _throwDisposition(path, lineIndex, lines, rule);
  }

  // ── Plugin side effects ────────────────────────────────────────────────────
  if (rule.id == 'plugin_side_effect') {
    return _pluginDisposition(path, lineIndex, lines);
  }

  // ── catch / catchError swallows ────────────────────────────────────────────
  if (rule.id == 'bare_catch' ||
      rule.id == 'named_catch' ||
      rule.id == 'catch_error_callback') {
    return _catchDisposition(path, lineIndex, lines, rule);
  }

  return const CandidateDisposition(
    status: CandidateStatus.review,
    reason: 'needs human review',
  );
}

CandidateDisposition _throwDisposition(
  String path,
  int lineIndex,
  List<String> lines,
  CandidateRule rule,
) {
  // Freezed/sealed exhaustiveness guards: `throw StateError('Unexpected
  // subclass')` is generated-style invariant code, never user-facing.
  final line = lines[lineIndex];
  if (line.contains('Unexpected subclass') ||
      line.contains('Unreachable') ||
      line.contains('should never')) {
    return const CandidateDisposition(
      status: CandidateStatus.intentional,
      reason: 'sealed/exhaustiveness invariant guard, not user-facing',
    );
  }

  // ArgumentError on a clearly internal precondition (id/empty checks) is a
  // programmer guard; keep it as a bug, not a typed product exception.
  if (rule.id == 'argument_error_throw') {
    return const CandidateDisposition(
      status: CandidateStatus.intentional,
      reason: 'programmer-guard precondition (ArgumentError), not user copy',
    );
  }

  // Bootstrap config invariants are programmer/setup errors.
  if (path == 'lib/app_bootstrap.dart' || path == 'lib/main.dart') {
    return const CandidateDisposition(
      status: CandidateStatus.intentional,
      reason: 'bootstrap configuration invariant (programmer/setup error)',
    );
  }

  // A StateError whose message is a user-facing sentence (reads like guidance)
  // is a user-correctable validation failure.
  if (rule.id == 'state_error_throw' && _looksUserFacing(line)) {
    // If the file catches the StateError locally (`on StateError catch`) and
    // converts it into an inline field error, it is used as local validation
    // control flow — it never reaches crash reporting, so it is intentional.
    if (lines.any((l) => l.contains('on StateError catch'))) {
      return const CandidateDisposition(
        status: CandidateStatus.intentional,
        reason: 'user-facing StateError caught locally for inline field-error '
            'control flow (never reported as a crash)',
      );
    }
    // Otherwise it propagates (e.g. into a mutation) and, being a non-App",
    // exception, would be reported as a crash — it must become a typed
    // ValidationException.
    return const CandidateDisposition(
      status: CandidateStatus.review,
      reason:
          'user-facing StateError propagates and must become a '
          'ValidationException',
    );
  }

  // Internal-state guards (rendering pipelines, invariants) stay as StateError.
  return const CandidateDisposition(
    status: CandidateStatus.intentional,
    reason: 'internal invariant guard (StateError), not user-correctable copy',
  );
}

bool _looksUserFacing(String line) {
  final match = RegExp(r'''StateError\s*\(\s*['"](.*?)['"]''').firstMatch(line);
  // Multi-line strings (no closing quote on this line) — inspect what we have.
  final raw =
      match?.group(1) ??
      RegExp(r'''StateError\s*\(\s*['"](.*)''').firstMatch(line)?.group(1) ??
      '';
  final message = raw.trim();
  if (message.isEmpty) return false;
  // User guidance reads like a sentence directed at the user.
  final lower = message.toLowerCase();
  return lower.startsWith('please ') ||
      lower.contains('before continuing') ||
      lower.contains('your ') && message.endsWith('.');
}

CandidateDisposition _pluginDisposition(
  String path,
  int lineIndex,
  List<String> lines,
) {
  // Inside a backend/app op-context wrapper, a normalized catch, or the dp
  // device-location/external seams → verified.
  if (_isWrapped(lines, lineIndex)) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason: 'plugin call is inside an app/backend op-context wrapper',
    );
  }

  // Default value of an injectable launcher/picker seam (e.g. the
  // `ExternalUrlLauncher` field default). The seam itself is wrapped wherever
  // it is *invoked* — this is just the production implementation handed in.
  final line = lines[lineIndex];
  if ((line.contains('launchUrl') || line.contains('SharePlus')) &&
      lines.any(
        (l) =>
            l.contains('ExternalUrlLauncher') ||
            l.contains('ExternalShareLauncher'),
      )) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason:
          'default implementation of an injectable launcher seam (invocations '
          'are wrapped in an op-context elsewhere)',
    );
  }
  if (_isNormalizedCatch(lines, lineIndex)) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason: 'plugin call is caught and normalized before logging',
    );
  }
  // Typed-state plugin services that translate a permission/geolocation result
  // into typed domain state (rather than leaking the raw plugin error).
  if (_near(
        lines,
        lineIndex,
        before: 30,
        after: 30,
        needle: 'LocationPermission',
      ) &&
      _near(lines, lineIndex, before: 30, after: 30, needle: 'return')) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason:
          'permission/geolocation result is translated into typed domain state',
    );
  }

  // SharedPreferences accessors (the `_prefs` getter / installation-id loader)
  // whose actual reads/writes are routed through a normalizing+logging catch or
  // an op-context wrapper elsewhere in the same file are verified seams: a
  // prefs failure surfaces as a typed app exception, not a silent swallow.
  if (_fileRoutesErrorsToLogger(lines)) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason:
          'local-persistence accessor whose reads are normalized/logged in-file',
    );
  }

  return const CandidateDisposition(
    status: CandidateStatus.review,
    reason: 'plugin side effect without a normalizing op-context seam',
  );
}

/// True when the file routes its failures through the normalizer + logger or an
/// op-context wrapper, i.e. errors from local seams in this file are observable.
bool _fileRoutesErrorsToLogger(List<String> lines) {
  // logAppError / runLoggingAppErrors both normalize *and* log, so either alone
  // is sufficient evidence that this file's failures are observable.
  if (lines.any(
    (line) =>
        line.contains('logAppError') || line.contains('runLoggingAppErrors'),
  )) {
    return true;
  }
  final hasLogger = lines.any(
    (line) =>
        line.contains('logAppException') ||
        line.contains('_errorLogger') ||
        line.contains('errorLoggerProvider'),
  );
  final hasNormalizer = lines.any(
    (line) =>
        line.contains('normalizeBackendError') ||
        line.contains('normalizeAppError') ||
        line.contains('withBackendErrorContext') ||
        line.contains('withAppErrorContext'),
  );
  return hasLogger && hasNormalizer;
}

CandidateDisposition _catchDisposition(
  String path,
  int lineIndex,
  List<String> lines,
  CandidateRule rule,
) {
  // .catchError callbacks: a `test:` filter scopes the swallow to a specific
  // expected error (e.g. Firestore not-found), and a surrounding op-context
  // wrapper normalizes everything else — both are verified, not swallows.
  if (rule.id == 'catch_error_callback') {
    if (_near(lines, lineIndex, before: 0, after: 5, needle: 'test:')) {
      return const CandidateDisposition(
        status: CandidateStatus.verified,
        reason: 'scoped .catchError(test:) only swallows a specific expected '
            'error; all others propagate',
      );
    }
    if (_isWrapped(lines, lineIndex)) {
      return const CandidateDisposition(
        status: CandidateStatus.verified,
        reason: '.catchError inside an op-context wrapper that normalizes '
            'unexpected errors',
      );
    }
    // A .catchError that forwards the error to a completer / logger is handled.
    if (_catchLogs(lines, lineIndex) ||
        _near(lines, lineIndex, before: 0, after: 6, needle: 'completeError')) {
      return const CandidateDisposition(
        status: CandidateStatus.verified,
        reason: 'caught error is forwarded to a completer / logged',
      );
    }
  }

  // Errors that are explicitly normalized/logged in or around the catch.
  if (_catchLogs(lines, lineIndex)) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason: 'caught error is normalized/logged (not silently swallowed)',
    );
  }

  // Best-effort cleanup that rethrows after compensating.
  if (_catchRethrows(lines, lineIndex)) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason: 'best-effort cleanup rethrows the original error',
    );
  }

  // Riverpod mutation pattern: the try ran a Mutation, whose error state is
  // displayed by a mutation-error listener/banner. The local catch only stops
  // the awaited run() from rethrowing into the handler.
  if (_catchAfterMutationRun(lines, lineIndex)) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason: 'mutation error state owns user-facing display',
    );
  }

  // Error is surfaced to the user through a snackbar / banner / error UI state.
  if (_catchSurfacesToUser(lines, lineIndex)) {
    return const CandidateDisposition(
      status: CandidateStatus.verified,
      reason: 'caught error is surfaced to the user (snackbar / error state)',
    );
  }

  // Defensive boolean reads that intentionally fall back to false/null and are
  // documented as such.
  if (_catchDocumented(lines, lineIndex)) {
    return const CandidateDisposition(
      status: CandidateStatus.intentional,
      reason: 'documented intentional swallow / defensive fallback',
    );
  }

  return CandidateDisposition(
    status: CandidateStatus.review,
    reason: 'catch may swallow the failure without log/surface/rethrow',
    recommendation: rule.recommendation,
  );
}

bool _catchLogs(List<String> lines, int lineIndex) {
  return _near(
    lines,
    lineIndex,
    before: 0,
    after: 14,
    needles: const [
      'logAppError',
      'normalizeAppError',
      'logAppException',
      'logError(',
      'logFlutterError',
      '.log(',
      'errorLoggerProvider',
      '_errorLogger',
      'ErrorLogger',
      // Forwards the error to Flutter's global pipeline (bootstrap reports it).
      'FlutterError.reportError',
      // Common "fail/report/handle" helpers that forward the caught error and
      // its stack trace to a logging path.
      '_failUploading',
      '_failUpload',
      'reportError(',
    ],
  );
}

bool _catchRethrows(List<String> lines, int lineIndex) {
  // `rethrow`, or `throw <normalized>` that converts the caught error into a
  // typed app exception before propagating it.
  if (_near(lines, lineIndex, before: 0, after: 14, needle: 'rethrow')) {
    return true;
  }
  return _near(
    lines,
    lineIndex,
    before: 0,
    after: 14,
    needles: const [
      'throw _normalize',
      'throw normalize',
      'throw _map',
      'throw const ',
      'throw AppException',
      'throw ValidationException',
      'throw PaymentFailedException',
      'completeError',
    ],
  );
}

bool _catchAfterMutationRun(List<String> lines, int lineIndex) {
  // The Mutation.run(...) call sits in the try block just above the catch.
  return _near(
    lines,
    lineIndex,
    before: 30,
    after: 0,
    needles: const ['Mutation.run(', '.run(ref', 'Mutation.run (', '.run(\n'],
  );
}

bool _catchSurfacesToUser(List<String> lines, int lineIndex) {
  return _near(
    lines,
    lineIndex,
    before: 0,
    after: 14,
    needles: const [
      'ScaffoldMessenger',
      'showCatchErrorSnackBar',
      'showSnackBar',
      'CatchErrorBanner',
      'ErrorBanner',
      '_searchError',
      '_error =',
      'Error =',
      'Error;',
      'completeError',
    ],
  );
}

bool _catchDocumented(List<String> lines, int lineIndex) {
  // A comment in the catch body explaining the swallow, OR a return of a typed
  // fallback (false/null/empty domain state) directly after the catch.
  for (var i = lineIndex; i <= lineIndex + 8 && i < lines.length; i += 1) {
    final trimmed = lines[i].trimLeft();
    if (trimmed.startsWith('//')) return true;
    if (trimmed.startsWith('return false') ||
        trimmed.startsWith('return null') ||
        trimmed.startsWith('return const') ||
        trimmed.startsWith('return WeeklyActivitySnapshot') ||
        trimmed.startsWith('return [];') ||
        trimmed.startsWith('return <')) {
      return true;
    }
  }
  return false;
}

bool _isWrapped(List<String> lines, int lineIndex) {
  return _near(
    lines,
    lineIndex,
    before: 40,
    after: 60,
    needles: const [
      'withAppErrorContext',
      'withBackendErrorContext',
      'withBackendErrorStream',
      'runLoggingAppErrors',
    ],
  );
}

bool _isNormalizedCatch(List<String> lines, int lineIndex) {
  return _near(lines, lineIndex, before: 4, after: 40, needle: 'catch') &&
      _near(
        lines,
        lineIndex,
        before: 4,
        after: 45,
        needles: const [
          'normalizeAppError',
          'normalizeBackendError',
          'logAppError',
          'logAppException',
        ],
      );
}

bool _isTestPath(String path) {
  return path.startsWith('test/') ||
      path.startsWith('test\\') ||
      path.contains('/test/') ||
      path.contains('_test.dart') ||
      path.contains('/testing/') ||
      path.endsWith('test_helpers.dart') ||
      path.contains('/fakes/') ||
      path.contains('fake_') ||
      path.contains('mock_');
}

bool _isCoreErrorInfraFile(String path) {
  return path == 'lib/core/app_error_context.dart' ||
      path == 'lib/core/backend_error_util.dart' ||
      path == 'lib/core/backend_error_message.dart' ||
      path == 'lib/core/app_error_message.dart' ||
      path == 'lib/exceptions/error_logger.dart' ||
      path == 'lib/exceptions/console_crash_reporter.dart';
}

bool _near(
  List<String> lines,
  int lineIndex, {
  required int before,
  required int after,
  String? needle,
  List<String> needles = const [],
}) {
  final all = <String>[?needle, ...needles];
  final start = lineIndex - before < 0 ? 0 : lineIndex - before;
  final end = lineIndex + after >= lines.length
      ? lines.length - 1
      : lineIndex + after;
  for (var i = start; i <= end; i += 1) {
    for (final n in all) {
      if (lines[i].contains(n)) return true;
    }
  }
  return false;
}

enum CandidateStatus {
  mustMigrate,
  review,
  verified,
  intentional,
  fixture,
  migrated,
}

class CandidateDisposition {
  const CandidateDisposition({
    required this.status,
    required this.reason,
    this.recommendation,
  });

  final CandidateStatus status;
  final String reason;
  final String? recommendation;
}

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
    required this.status,
    required this.disposition,
    required this.recommendation,
    required this.snippet,
  });

  final String path;
  final int line;
  final CandidateRule rule;
  final CandidateStatus status;
  final String disposition;
  final String recommendation;
  final String snippet;

  Map<String, Object> toJson() => {
    'path': path,
    'line': line,
    'rule': rule.id,
    'status': status.name,
    'disposition': disposition,
    'recommendation': recommendation,
    'snippet': snippet,
  };
}
