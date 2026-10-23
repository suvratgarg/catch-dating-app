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
typedef TextMigrationCounts = Map<String, Map<String, int>>;

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
  Set<String>? variants,
) {
  final visitor = _TextCalls(variants);
  unit.accept(visitor);
  return visitor.sites;
}

class _TextCalls extends RecursiveAstVisitor<void> {
  _TextCalls(this.variants);
  final Set<String>? variants;
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
        (variants != null && !variants!.contains(role))) {
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

TextMigrationCounts parseTextMigrationBaseline(String source) {
  final json = jsonDecode(source);
  if (json is! Map || json['version'] != 2 || json['files'] is! Map) {
    throw const FormatException('Invalid CatchText migration baseline');
  }
  final counts = <String, Map<String, int>>{};
  for (final entry in (json['files'] as Map).entries) {
    if (entry.key is! String ||
        !textMigrationScope(entry.key as String) ||
        (entry.key as String).split('/').contains('..') ||
        entry.value is! Map ||
        (entry.value as Map).isEmpty) {
      throw const FormatException('Invalid CatchText migration baseline row');
    }
    final roles = <String, int>{};
    for (final role in (entry.value as Map).entries) {
      if (role.key is! String ||
          !RegExp(r'^[A-Za-z][A-Za-z0-9]*$').hasMatch(role.key as String) ||
          role.value is! int ||
          (role.value as int) <= 0) {
        throw const FormatException('Invalid CatchText migration role budget');
      }
      roles[role.key as String] = role.value as int;
    }
    counts[entry.key as String] = roles;
  }
  return counts;
}

List<String> textMigrationGrowth(
  TextMigrationCounts actual,
  TextMigrationCounts budget,
) => [
  for (final entry in actual.entries)
    for (final role in entry.value.entries)
      if (role.value > (budget[entry.key]?[role.key] ?? 0))
        '${entry.key}:${role.key}: ${role.value} exceeds ${budget[entry.key]?[role.key] ?? 0}',
];

/// Existing uncovered roles retain only their original allowance. They are not
/// enforced until a variant exists, and cannot acquire a larger reservation.
TextMigrationCounts textMigrationPrunedCounts(
  TextMigrationCounts actual,
  TextMigrationCounts? recorded,
  Set<String> variants,
) => {
  for (final file in actual.entries)
    if (file.value.entries.any(
      (role) =>
          variants.contains(role.key) ||
          recorded == null ||
          (recorded[file.key]?[role.key] ?? 0) > 0,
    ))
      file.key: {
        for (final role in file.value.entries)
          if (variants.contains(role.key) ||
              recorded == null ||
              (recorded[file.key]?[role.key] ?? 0) > 0)
            role.key: variants.contains(role.key) || recorded == null
                ? role.value
                : role.value < recorded[file.key]![role.key]!
                ? role.value
                : recorded[file.key]![role.key]!,
      },
};

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
    <
      String,
      ({String stamp, Set<String> variants, TextMigrationCounts counts})
    >{};

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
  final seen = <String, int>{};
  return [
    for (final site in sites)
      if ((seen.update(site.role, (value) => value + 1, ifAbsent: () => 1)) >
          (inputs.counts[relative]?[site.role] ?? 0))
        site,
  ];
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
    if (args.single == '--check' && recorded == null) {
      throw StateError('Missing CatchText migration baseline');
    }
    if (recorded == null && previous == null) {
      final changed =
          git([
                'diff',
                '--name-only',
                base,
                '--',
                'lib',
                'apps',
                'packages/catch_ui/lib/src/foundations/catch_text_styles.dart',
                'packages/catch_ui/lib/src/primitives/catch_text_variant.dart',
              ]).stdout
              as String;
      if (changed.trim().isNotEmpty) {
        throw StateError(
          'Initial role reservations require unchanged app/style source at the merge base',
        );
      }
    }
    final files =
        (git(['ls-files', '-z', '--', 'lib', 'apps']).stdout as String)
            .split('\u0000')
            .where((path) => path.endsWith('.dart') && textMigrationScope(path))
            .toList()
          ..sort();
    if (files.isEmpty) throw StateError('CatchText scan has no source files');
    final variants = textMigrationVariants(root);
    if (variants.isEmpty) throw StateError('CatchText has no variants');
    final counts = <String, Map<String, int>>{};
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
        final roles = <String, int>{};
        for (final site in textMigrationSites(unit.unit, null)) {
          roles.update(site.role, (count) => count + 1, ifAbsent: () => 1);
        }
        if (roles.isNotEmpty) {
          counts[file] = Map.fromEntries(
            roles.entries.toList()
              ..sort((left, right) => left.key.compareTo(right.key)),
          );
        }
      }
    } finally {
      await collection.dispose();
    }
    final checking = args.single == '--check';
    final current = textMigrationPrunedCounts(counts, recorded, variants);
    final proposed = checking ? recorded! : current;
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
    final differences = [
      for (final file in {...current.keys, ...?recorded?.keys})
        for (final role in {...?current[file]?.keys, ...?recorded?[file]?.keys})
          if ((current[file]?[role] ?? 0) != (recorded?[file]?[role] ?? 0))
            '$file:$role: recorded ${recorded?[file]?[role] ?? 0}, actual ${current[file]?[role] ?? 0}',
    ];
    if (checking && differences.isNotEmpty) {
      throw StateError(
        'CatchText baseline is stale:\n${differences.join('\n')}\nRun bash tool/check_catch_ui_lint_drift.sh --update-text-baseline',
      );
    }
    if (!checking) {
      baseline.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({'version': 2, 'owner': 'app_architecture', 'targetPhase': 'docs/plans/ui_system_blueprint_and_conformance_audit.md#phase-7--cross-framework-conformance-react', 'files': current})}\n',
      );
    }
    final enabled = current.values
        .expand((roles) => roles.entries)
        .where((role) => variants.contains(role.key))
        .fold(0, (sum, role) => sum + role.value);
    final total = current.values
        .expand((roles) => roles.values)
        .fold(0, (sum, count) => sum + count);
    stdout.writeln(
      'CatchText migration baseline ${checking ? 'passed' : 'updated'}: $enabled covered calls, ${total - enabled} reserved legacy calls in ${current.length} files (${files.length} resolved files).',
    );
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
