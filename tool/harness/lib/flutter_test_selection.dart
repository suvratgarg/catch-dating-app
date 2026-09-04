import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

bool _testFile(String name) =>
    name.startsWith('test/') &&
    name.endsWith('_test.dart') &&
    !name.startsWith('test/goldens/') &&
    !name.startsWith('test/integration/');

const _uiProbeScript = 'tool/check_catch_ui_lints.sh';
const _generatedProbe =
    'packages/catch_ui_lints/probes/catch_ui_lint_probes.dart';

/// Tests of the lint engine depend on its probe APIs, not every screen that
/// uses those APIs. Product diagnostics still run on every selected Flutter CI.
bool needsUiLintSmoke({
  required Map<String, String> before,
  required Map<String, String> after,
  required Set<String> changed,
  bool full = false,
}) {
  if (full ||
      changed.isEmpty ||
      changed.any(
        (name) =>
            !name.endsWith('.dart') ||
            !(name.startsWith('lib/') || name.startsWith('test/')),
      )) {
    return true;
  }
  try {
    for (final tree in [before, after]) {
      final script = tree[_uiProbeScript];
      if (script == null || !tree.containsKey(_generatedProbe)) return true;
      final corpora = RegExp(
        "<<'DART'\\n([\\s\\S]*?)\\nDART",
        multiLine: true,
      ).allMatches(script).map((match) => match.group(1)!).toList();
      if (corpora.isEmpty) return true;
      final graph = _Imports({...tree});
      final inputs = graph.closure(_generatedProbe);
      for (var index = 0; index < corpora.length; index++) {
        final name = 'tool/ui_probe_$index.dart';
        graph.files[name] = corpora[index];
        inputs.addAll(graph.closure(name));
      }
      if (inputs.any(changed.contains)) return true;
    }
    return false;
  } on Object {
    return true;
  }
}

/// Only narrows root unit/widget tests. Native, package, golden, integration,
/// analysis and contract gates retain their independent owners.
Map<String, Object> selectFlutterTests({
  required Map<String, String> before,
  required Map<String, String> after,
  required Set<String> changed,
  bool full = false,
}) {
  final all = after.keys.where(_testFile).toList()..sort();
  if (all.isEmpty) throw StateError('No root Flutter tests exist.');
  Map<String, Object> result(List<String> files, String reason) => {
    'mode': files.length == all.length ? 'full' : 'affected',
    'reason': reason,
    'totalTests': all.length,
    'selectedTests': files.length,
    'files': files,
  };
  if (full || changed.isEmpty) {
    return result(all, 'Full validation or no usable change window');
  }
  // Unknown/non-Dart inputs can be loaded without an import (assets, fixtures,
  // configuration, generators, plugins). Keep the full suite for those changes.
  if (changed.any(
    (name) =>
        !name.endsWith('.dart') ||
        !(name.startsWith('lib/') || name.startsWith('test/')) ||
        name.endsWith('/flutter_test_config.dart'),
  )) {
    return result(
      all,
      'Non-source, toolchain, test configuration or unmodelled input changed',
    );
  }
  try {
    final oldGraph = _Imports(before);
    final newGraph = _Imports(after);
    final selected = <String>[];
    var provenImpact = false;
    for (final test in all) {
      final current = newGraph.closure(test);
      final previous = before.containsKey(test)
          ? oldGraph.closure(test)
          : <String>{};
      final impacted =
          !before.containsKey(test) ||
          {...current, ...previous}.any(changed.contains);
      provenImpact = provenImpact || impacted;
      if (impacted ||
          current.contains(_Imports.fileSystemProbe) ||
          previous.contains(_Imports.fileSystemProbe)) {
        selected.add(test);
      }
    }
    // An untested source or an unsupported relationship must not turn the
    // required test gate into a green no-op.
    if (!provenImpact || selected.isEmpty) {
      return result(all, 'No impacted test could be proven; full fallback');
    }
    return result(
      selected,
      'Union of base/head transitive imports, exports and parts; filesystem probes retained',
    );
  } on Object catch (error) {
    return result(all, 'Conservative fallback: $error');
  }
}

class _Imports {
  _Imports(this.files) {
    for (final entry in files.entries) {
      if (entry.key != 'pubspec.yaml' && !entry.key.endsWith('/pubspec.yaml')) {
        continue;
      }
      final name = RegExp(
        r'^name:\s*([a-zA-Z_][a-zA-Z_0-9]*)\s*$',
        multiLine: true,
      ).firstMatch(entry.value)?.group(1);
      if (name == null) {
        throw StateError('Unsupported package declaration: ${entry.key}');
      }
      final root = entry.key.substring(
        0,
        entry.key.length - 'pubspec.yaml'.length,
      );
      if (packages.containsKey(name)) {
        throw StateError('Ambiguous package: $name');
      }
      packages[name] = '${root}lib/';
    }
  }
  static const fileSystemProbe = '@filesystem-probe';
  final Map<String, String> files;
  final packages = <String, String>{};
  final edges = <String, Set<String>>{};

  Set<String> closure(String start) {
    final visited = <String>{};
    void walk(String name) {
      if (!visited.add(name) || name == fileSystemProbe) return;
      for (final dependency in edges.putIfAbsent(name, () => imports(name))) {
        walk(dependency);
      }
    }

    walk(start);
    return visited;
  }

  Set<String> imports(String name) {
    final source = files[name];
    if (source == null) throw StateError('Missing local Dart module: $name');
    final parsed = parseString(
      content: source,
      path: name,
      throwIfDiagnostics: false,
    );
    if (parsed.errors.isNotEmpty) {
      throw StateError('Cannot parse Dart module: $name');
    }
    final dependencies = <String>{};
    void add(StringLiteral literal) {
      final value = literal.stringValue;
      if (value == null) throw StateError('Nonliteral Dart URI in $name');
      final uri = Uri.parse(value);
      if (uri.scheme == 'dart') {
        if (value == 'dart:io' &&
            (name.startsWith('test/') || name.startsWith('tool/'))) {
          dependencies.add(fileSystemProbe);
        }
        return;
      }
      String target;
      if (uri.scheme == 'package') {
        final split = uri.path.indexOf('/');
        if (split < 1) throw StateError('Invalid package URI: $value');
        final package = uri.path.substring(0, split);
        final root = packages[package];
        if (root == null) {
          return; // External packages are bounded by the lockfile.
        }
        target = '$root${uri.path.substring(split + 1)}';
      } else if (uri.scheme.isEmpty && !uri.hasAbsolutePath) {
        target = Uri(path: name).resolveUri(uri).normalizePath().path;
      } else {
        throw StateError('Unsupported Dart URI: $value');
      }
      if (!files.containsKey(target)) {
        throw StateError('Missing local Dart module: $target');
      }
      dependencies.add(target);
    }

    for (final directive in parsed.unit.directives) {
      if (directive is UriBasedDirective) {
        add(directive.uri);
        if (directive is NamespaceDirective) {
          for (final conditional in directive.configurations) {
            add(conditional.uri);
          }
        }
      }
    }
    return dependencies;
  }
}

ProcessResult _git(List<String> arguments) {
  final result = Process.runSync(
    'git',
    arguments,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (result.exitCode != 0) {
    throw StateError('git ${arguments.first} failed: ${result.stderr}');
  }
  return result;
}

Future<Map<String, String>> _tree(String sha) async {
  final listing = (_git(['ls-tree', '-rz', sha]).stdout as String)
      .split('\u0000')
      .where((entry) => entry.isNotEmpty);
  final entries = <(String, String)>[];
  for (final entry in listing) {
    final split = entry.indexOf('\t');
    final name = entry.substring(split + 1);
    if (name != _uiProbeScript &&
        !name.endsWith('.dart') &&
        name != 'pubspec.yaml' &&
        !name.endsWith('/pubspec.yaml')) {
      continue;
    }
    final header = entry.substring(0, split).split(' ');
    if (header[1] != 'blob' || !['100644', '100755'].contains(header[0])) {
      throw StateError('Unsupported Git entry: $name');
    }
    entries.add((name, header[2]));
  }
  final process = await Process.start('git', ['cat-file', '--batch']);
  final bytesFuture = process.stdout.fold<List<int>>(
    [],
    (bytes, chunk) => bytes..addAll(chunk),
  );
  final errorsFuture = process.stderr.transform(utf8.decoder).join();
  process.stdin.write('${entries.map((entry) => entry.$2).join('\n')}\n');
  await process.stdin.close();
  final bytes = await bytesFuture;
  final errors = await errorsFuture;
  if (await process.exitCode != 0) {
    throw StateError('Cannot read committed sources: $errors');
  }
  var offset = 0;
  final result = <String, String>{};
  for (final (name, object) in entries) {
    final end = bytes.indexOf(10, offset);
    final header = utf8.decode(bytes.sublist(offset, end)).split(' ');
    if (header[0] != object || header[1] != 'blob') {
      throw StateError('Invalid Git object: $name');
    }
    final size = int.parse(header[2]);
    result[name] = utf8.decode(bytes.sublist(end + 1, end + 1 + size));
    offset = end + size + 2;
  }
  return result;
}

Future<void> main(List<String> arguments) async {
  final args = <String, String>{};
  for (var i = 0; i < arguments.length; i += 2) {
    if (i + 1 >= arguments.length ||
        !arguments[i].startsWith('--') ||
        args.containsKey(arguments[i])) {
      throw ArgumentError('Expected unique --name value pairs');
    }
    args[arguments[i]] = arguments[i + 1];
  }
  if (args.keys.any(
    (key) => ![
      '--base',
      '--head',
      '--full',
      '--output',
      '--github-output',
    ].contains(key),
  )) {
    throw ArgumentError('Unknown option');
  }
  final base = args['--base'] ?? '';
  final head = args['--head'] ?? '';
  for (final sha in [base, head]) {
    if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(sha)) {
      throw ArgumentError('Exact Git SHAs required');
    }
    _git(['cat-file', '-e', '$sha^{commit}']);
  }
  _git(['merge-base', '--is-ancestor', base, head]);
  if (!['true', 'false'].contains(args['--full'] ?? 'false')) {
    throw ArgumentError('Invalid --full');
  }
  final changed =
      (_git(['diff', '--name-only', '--no-renames', '-z', base, head]).stdout
              as String)
          .split('\u0000')
          .where((name) => name.isNotEmpty)
          .toSet();
  final before = await _tree(base);
  final after = await _tree(head);
  final plan = selectFlutterTests(
    before: before,
    after: after,
    changed: changed,
    full: args['--full'] == 'true',
  );
  plan['uiLintSmoke'] = needsUiLintSmoke(
    before: before,
    after: after,
    changed: changed,
    full: args['--full'] == 'true',
  );
  final files = plan['files']! as List<String>;
  final count = math.min(4, files.length);
  final shards = List.generate(
    count,
    (index) => {
      'shard_index': index,
      'shard_label': index + 1,
      'shard_total': count,
      'files': [for (var i = index; i < files.length; i += count) files[i]],
    },
  );
  final output = args['--output'];
  if (output == null) throw ArgumentError('--output is required');
  File(output).parent.createSync(recursive: true);
  File(output).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({...plan, 'baseSha': base, 'sourceSha': head, 'shards': shards})}\n',
  );
  final githubOutput = args['--github-output'];
  if (githubOutput != null) {
    final matrix = {
      'include': shards
          .map((shard) => Map.from(shard)..remove('files'))
          .toList(),
    };
    File(githubOutput).writeAsStringSync(
      'matrix=${jsonEncode(matrix)}\nshard_total=$count\nui_lint_smoke=${plan['uiLintSmoke']}\n',
      mode: FileMode.append,
    );
  }
  stdout.writeln(jsonEncode({...plan}..remove('files')));
}
