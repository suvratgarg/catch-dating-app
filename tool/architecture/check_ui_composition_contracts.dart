import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';

const screenRegistryConformanceCode = 'catch_screen_registry_conformance';
const screenTopBarConformanceCode = 'catch_screen_top_bar_conformance';
const screenNestedScaffoldCode = 'catch_screen_nested_scaffold';

const _registryPath = 'design/screens/catch.screens.json';
const _topBarRegistryPath = 'tool/design/screen_top_bar_contracts.json';
const _baselinePath = 'tool/architecture/ui_composition_baseline.json';

Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final jsonIndex = arguments.indexOf('--json');
  final jsonPath = jsonIndex >= 0 && jsonIndex + 1 < arguments.length
      ? arguments[jsonIndex + 1]
      : null;
  final known = <String>{'--check', '--json'};
  for (var index = 0; index < arguments.length; index += 1) {
    final argument = arguments[index];
    if (argument == '--json') {
      index += 1;
      continue;
    }
    if (!known.contains(argument)) {
      stderr.writeln(
        'Usage: dart run tool/architecture/check_ui_composition_contracts.dart [--check] [--json PATH]',
      );
      exitCode = 64;
      return;
    }
  }

  final root = Directory.current.absolute.path;
  final registry = _readJson(_fromRoot(root, _registryPath));
  final topBarRegistry = _readJson(_fromRoot(root, _topBarRegistryPath));
  final screens = (registry['screens'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final collection = AnalysisContextCollection(includedPaths: <String>[root]);
  final hardFailures = <String>[];
  final findings = <Map<String, Object?>>[];

  for (final screen in screens) {
    final source = (screen['source'] as Map<String, Object?>?) ?? const {};
    final relativePath = source['file'] as String? ?? '';
    final absolutePath = _fromRoot(root, relativePath);
    if (!File(absolutePath).existsSync()) {
      hardFailures.add(
        '$screenRegistryConformanceCode ${screen['id']}: missing $relativePath',
      );
      continue;
    }
    final result = await collection
        .contextFor(absolutePath)
        .currentSession
        .getResolvedUnit(absolutePath);
    if (result is! ResolvedUnitResult) {
      hardFailures.add(
        '$screenRegistryConformanceCode ${screen['id']}: analyzer could not resolve $relativePath',
      );
      continue;
    }
    final sourceText = result.content;
    final evaluation = evaluateSourceContract(screen, sourceText);
    hardFailures.addAll(evaluation.hardFailures);
    findings.addAll(evaluation.findings);
  }

  _validateMediaHeroes(root, screens, topBarRegistry, hardFailures);
  final counts = <String, int>{};
  for (final finding in findings) {
    final code = finding['code']! as String;
    counts[code] = (counts[code] ?? 0) + 1;
  }
  final report = <String, Object?>{
    'version': 1,
    'complete': hardFailures.isEmpty,
    'screenCount': screens.length,
    'counts': counts,
    'hardFailures': hardFailures,
    'findings': findings,
  };
  final encoded = const JsonEncoder.withIndent('  ').convert(report);
  if (jsonPath != null) File(jsonPath).writeAsStringSync('$encoded\n');

  if (hardFailures.isNotEmpty) {
    stderr.writeln('Catch UI composition contract check failed:');
    for (final failure in hardFailures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }

  if (check) {
    final baseline = _readJson(_fromRoot(root, _baselinePath));
    final maxima = (baseline['maxCounts'] as Map<String, Object?>?) ?? const {};
    final expectedCodes = <String>{screenNestedScaffoldCode};
    if (maxima.keys.toSet().difference(expectedCodes).isNotEmpty ||
        expectedCodes.difference(maxima.keys.toSet()).isNotEmpty) {
      stderr.writeln(
        'Catch UI composition baseline must cover exactly $expectedCodes.',
      );
      exitCode = 1;
      return;
    }
    for (final code in expectedCodes) {
      final maximum = maxima[code];
      final current = counts[code] ?? 0;
      if (maximum is! int || maximum < 0 || current > maximum) {
        stderr.writeln(
          '$code: $current exceeds invalid/ratcheted maximum $maximum.',
        );
        exitCode = 1;
        return;
      }
    }
  }

  stdout.writeln(
    'Catch UI composition contracts passed (${screens.length} screens, ${findings.length} ratcheted findings).',
  );
}

SourceContractEvaluation evaluateSourceContract(
  Map<String, Object?> screen,
  String sourceText,
) {
  final hardFailures = <String>[];
  final findings = <Map<String, Object?>>[];
  final id = screen['id'] as String? ?? '<missing-screen>';
  final source = (screen['source'] as Map<String, Object?>?) ?? const {};
  final symbol = source['symbol'] as String? ?? '';
  final relativePath = source['file'] as String? ?? '';
  if (symbol.isEmpty ||
      !RegExp(
        '\\b(?:class|mixin|enum|extension\\s+type)\\s+${RegExp.escape(symbol)}\\b',
      ).hasMatch(sourceText)) {
    hardFailures.add(
      '$screenRegistryConformanceCode $id: symbol $symbol is not declared by $relativePath',
    );
  }

  final statePolicy =
      (screen['statePolicy'] as Map<String, Object?>?) ?? const {};
  final declaredStates = ((screen['states'] as List<Object?>?) ?? const [])
      .cast<Map<String, Object?>>()
      .map((state) => state['kind'] == 'populated' ? 'data' : state['kind'])
      .whereType<String>()
      .toSet();
  for (final required
      in ((statePolicy['requiredStates'] as List<Object?>?) ?? const [])) {
    if (!declaredStates.contains(required)) {
      hardFailures.add(
        '$screenRegistryConformanceCode $id: statePolicy requires unregistered state $required',
      );
    }
  }

  final topBar = (screen['topBar'] as Map<String, Object?>?) ?? const {};
  final role = topBar['role'] as String? ?? '';
  final expression = topBar['expression'] as String? ?? '';
  if (<String>{
        'screen',
        'compact',
        'identity',
        'step-flow',
        'inline',
      }.contains(role) &&
      !sourceText.contains(expression)) {
    hardFailures.add(
      '$screenTopBarConformanceCode $id: $relativePath does not contain registered $expression',
    );
  }

  final shell = (screen['shell'] as Map<String, Object?>?) ?? const {};
  if (shell['owner'] != 'standalone' &&
      shell['nestedScaffoldAllowed'] != true) {
    final scaffoldCount = RegExp(
      r'(?<!Catch)\bScaffold\s*\(',
    ).allMatches(sourceText).length;
    for (var index = 0; index < scaffoldCount; index += 1) {
      findings.add(<String, Object?>{
        'code': screenNestedScaffoldCode,
        'screen': id,
        'path': relativePath,
        'message':
            'A shell-reachable screen instantiates Scaffold; root chrome belongs to the adaptive shell.',
      });
    }
  }

  return SourceContractEvaluation(
    hardFailures: hardFailures,
    findings: findings,
  );
}

void _validateMediaHeroes(
  String root,
  List<Map<String, Object?>> screens,
  Map<String, Object?> topBarRegistry,
  List<String> hardFailures,
) {
  final exceptionPaths =
      ((topBarRegistry['rawChromeExceptions'] as List<Object?>?) ?? const [])
          .cast<Map<String, Object?>>()
          .where((entry) => entry['expression'] == 'SliverAppBar')
          .map((entry) => entry['path'])
          .whereType<String>()
          .toList();
  for (final screen in screens.where(
    (screen) =>
        (screen['topBar'] as Map<String, Object?>?)?['role'] == 'media-hero',
  )) {
    final source = (screen['source'] as Map<String, Object?>?) ?? const {};
    final sourcePath = source['file'] as String? ?? '';
    final sourceParts = sourcePath.split('/');
    final feature = sourceParts.length > 1 ? sourceParts[1] : '';
    final matching = exceptionPaths
        .where((path) => path.contains('/$feature/'))
        .toList();
    if (matching.isEmpty ||
        !matching.any(
          (path) => File(
            _fromRoot(root, path),
          ).readAsStringSync().contains('SliverAppBar'),
        )) {
      hardFailures.add(
        '$screenTopBarConformanceCode ${screen['id']}: no registered resolved SliverAppBar media hero for feature $feature',
      );
    }
  }
}

Map<String, Object?> _readJson(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

String _fromRoot(String root, String relativePath) => '$root/$relativePath';

final class SourceContractEvaluation {
  const SourceContractEvaluation({
    required this.hardFailures,
    required this.findings,
  });

  final List<String> hardFailures;
  final List<Map<String, Object?>> findings;
}
