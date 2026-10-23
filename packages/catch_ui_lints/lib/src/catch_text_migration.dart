import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

const textMigrationBaseline =
    'tool/architecture/catch_text_migration_baseline.json';
const _variantPath =
    'packages/catch_ui/lib/src/primitives/catch_text_variant.dart';
typedef TextMigrationSite = ({InstanceCreationExpression node, String role});

bool textMigrationScope(String relative) =>
    (relative.startsWith('lib/') ||
        RegExp(r'^apps/[^/]+/lib/').hasMatch(relative) ||
        relative.startsWith('tool/catch_ui_lints_probe/')) &&
    !relative.startsWith('lib/core/theme/') &&
    !relative.startsWith('lib/core/schema_contracts/generated/') &&
    !relative.startsWith('lib/l10n/generated/') &&
    !relative.endsWith('.g.dart') &&
    !relative.endsWith('.freezed.dart');

/// Only direct, resolved role calls whose arguments CatchText can preserve.
List<TextMigrationSite> textMigrationSites(
  CompilationUnit unit,
  Set<String> variants,
) {
  final visitor = _TextCalls(variants);
  unit.accept(visitor);
  return visitor.sites;
}

class _TextCalls extends RecursiveAstVisitor<void> {
  _TextCalls(this.variants);
  final Set<String> variants;
  final sites = <TextMigrationSite>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    final constructor = node.constructorName.element?.baseElement;
    if (constructor?.enclosingElement.name != 'Text' ||
        constructor?.library.uri.toString() !=
            'package:flutter/src/widgets/text.dart' ||
        node.constructorName.name != null) {
      return;
    }
    final named = {
      for (final arg
          in node.argumentList.arguments.whereType<NamedExpression>())
        arg.name.label.name: arg.expression,
    };
    final data = node.argumentList.arguments
        .where((arg) => arg is! NamedExpression)
        .toList();
    if (data.length != 1 ||
        named.keys.any(
          (name) => !{
            'key',
            'style',
            'maxLines',
            'overflow',
            'textAlign',
          }.contains(name),
        )) {
      return;
    }
    final style = named['style'];
    if (style is! MethodInvocation) return;
    final method = style.methodName.element?.baseElement;
    final role = style.methodName.name;
    if (method?.enclosingElement?.name != 'CatchTextStyles' ||
        method?.library?.uri.toString() !=
            'package:catch_ui/src/foundations/catch_text_styles.dart' ||
        !variants.contains(role)) {
      return;
    }
    final contexts = style.argumentList.arguments
        .where((arg) => arg is! NamedExpression)
        .toList();
    if (contexts.length != 1 ||
        contexts.single.toSource() != 'context' ||
        style.argumentList.arguments.whereType<NamedExpression>().any(
          (arg) => arg.name.label.name != 'color',
        )) {
      return;
    }
    if (named.containsKey('maxLines')) {
      if (named['maxLines']?.staticType?.getDisplayString() != 'int' ||
          named['overflow']?.toSource() != 'TextOverflow.ellipsis') {
        return;
      }
    } else if (named.containsKey('overflow')) {
      return;
    }
    sites.add((node: node, role: role));
  }
}

Set<String> textMigrationVariants(String root) =>
    parseString(content: File('$root/$_variantPath').readAsStringSync())
        .unit
        .declarations
        .whereType<EnumDeclaration>()
        .singleWhere(
          (node) => node.namePart.typeName.lexeme == 'CatchTextVariant',
        )
        .body
        .constants
        .map((node) => node.name.lexeme)
        .toSet();

Map<String, int> parseTextMigrationBaseline(String source) {
  final json = jsonDecode(source);
  if (json is! Map || json['version'] != 1 || json['files'] is! Map) {
    throw const FormatException('Invalid CatchText migration baseline');
  }
  final counts = <String, int>{};
  for (final entry in (json['files'] as Map).entries) {
    if (entry.key is! String ||
        !textMigrationScope(entry.key as String) ||
        (entry.key as String).split('/').contains('..') ||
        entry.value is! int ||
        (entry.value as int) <= 0) {
      throw const FormatException('Invalid CatchText migration baseline row');
    }
    counts[entry.key as String] = entry.value as int;
  }
  return counts;
}

List<String> textMigrationGrowth(
  Map<String, int> actual,
  Map<String, int> budget,
) => [
  for (final entry in actual.entries)
    if (entry.value > (budget[entry.key] ?? 0))
      '${entry.key}: ${entry.value} exceeds ${budget[entry.key] ?? 0}',
];

String? _repositoryRoot(String path) {
  var directory = File(path).parent;
  while (directory.parent.path != directory.path) {
    if (File('${directory.path}/.git').existsSync() ||
        Directory('${directory.path}/.git').existsSync()) {
      return directory.path;
    }
    directory = directory.parent;
  }
  return null;
}

final _cache =
    <String, ({String stamp, Set<String> variants, Map<String, int> counts})>{};

/// Existing counts are silent; newly added replaceable calls name their role.
List<TextMigrationSite> newTextMigrationSites(
  CompilationUnit unit,
  String path,
) {
  final root = _repositoryRoot(path);
  if (root == null) return const [];
  final relative = path.substring(root.length + 1).replaceAll(r'\', '/');
  if (!textMigrationScope(relative)) return const [];
  final baseline = File('$root/$textMigrationBaseline');
  final variant = File('$root/$_variantPath');
  final stamp =
      '${baseline.statSync().modified}:${variant.statSync().modified}';
  var inputs = _cache[root];
  if (inputs == null || inputs.stamp != stamp) {
    inputs = (
      stamp: stamp,
      variants: textMigrationVariants(root),
      counts: parseTextMigrationBaseline(baseline.readAsStringSync()),
    );
    _cache[root] = inputs;
  }
  final sites = textMigrationSites(unit, inputs.variants);
  // Baselines count in source order, not recursive visitor completion order.
  sites.sort((left, right) => left.node.offset.compareTo(right.node.offset));
  return sites.skip(inputs.counts[relative] ?? 0).toList();
}

// Internal mode of the existing lint-drift wrapper, not another check registry.
Future<void> main(List<String> args) async {
  try {
    if (args.length != 1 || !{'--check', '--update'}.contains(args.single)) {
      throw ArgumentError(
        'Use the lint-drift wrapper: --check-text-baseline or --update-text-baseline',
      );
    }
    final root = Directory.current.path;
    ProcessResult git(List<String> arguments) {
      final result = Process.runSync('git', arguments, workingDirectory: root);
      if (result.exitCode != 0) {
        throw StateError('git ${arguments.first} failed: ${result.stderr}');
      }
      return result;
    }

    final base = (git(['merge-base', 'origin/main', 'HEAD']).stdout as String)
        .trim();
    final hasBase =
        (git(['ls-tree', '--name-only', base, textMigrationBaseline]).stdout
                as String)
            .trim()
            .isNotEmpty;
    final previous = hasBase
        ? parseTextMigrationBaseline(
            git(['show', '$base:$textMigrationBaseline']).stdout as String,
          )
        : null;
    final baseline = File('$root/$textMigrationBaseline');
    final recorded = baseline.existsSync()
        ? parseTextMigrationBaseline(baseline.readAsStringSync())
        : null;
    final files =
        (git(['ls-files', '-z', '--', 'lib', 'apps']).stdout as String)
            .split('\u0000')
            .where((path) => path.endsWith('.dart') && textMigrationScope(path))
            .toList()
          ..sort();
    if (files.isEmpty) throw StateError('CatchText scan has no source files');
    final variants = textMigrationVariants(root);
    if (variants.isEmpty) throw StateError('CatchText has no variants');
    final counts = <String, int>{};
    final collection = AnalysisContextCollection(
      includedPaths: [root, '$root/apps/consumer', '$root/apps/host'],
    );
    try {
      for (final file in files) {
        final path = '$root/$file';
        final unit = await collection
            .contextFor(path)
            .currentSession
            .getResolvedUnit(path);
        if (unit is! ResolvedUnitResult ||
            unit.diagnostics.any(
              (error) =>
                  error.diagnosticCode.severity == DiagnosticSeverity.ERROR,
            )) {
          throw StateError('Incomplete resolved CatchText scan: $file');
        }
        final count = textMigrationSites(unit.unit, variants).length;
        if (count > 0) counts[file] = count;
      }
    } finally {
      await collection.dispose();
    }
    final checking = args.single == '--check';
    if (checking && recorded == null) {
      throw StateError('Missing CatchText migration baseline');
    }
    final proposed = checking ? recorded! : counts;
    final growth = [
      if (previous != null) ...textMigrationGrowth(proposed, previous),
      if (!checking && recorded != null)
        ...textMigrationGrowth(proposed, recorded),
    ];
    if (growth.isNotEmpty) {
      throw StateError(
        'CatchText baseline may only shrink:\n${growth.join('\n')}',
      );
    }
    final differences = {
      ...counts.keys,
      ...?recorded?.keys,
    }.where((file) => counts[file] != recorded?[file]);
    if (checking && differences.isNotEmpty) {
      throw StateError(
        'CatchText baseline is stale:\n${differences.map((file) => '$file: recorded ${recorded?[file] ?? 0}, actual ${counts[file] ?? 0}').join('\n')}\nRun bash tool/check_catch_ui_lint_drift.sh --update-text-baseline',
      );
    }
    if (!checking) {
      baseline.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({'version': 1, 'owner': 'app_architecture', 'targetPhase': 'docs/plans/ui_system_blueprint_and_conformance_audit.md#phase-7--cross-framework-conformance-react', 'files': counts})}\n',
      );
    }
    stdout.writeln(
      'CatchText migration baseline ${checking ? 'passed' : 'updated'}: ${counts.values.fold(0, (sum, count) => sum + count)} calls in ${counts.length} files (${files.length} resolved files).',
    );
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
