import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'flutter_test_selection.dart';

const fixture = {
  'pubspec.yaml': 'name: example\n',
  'lib/a.dart': 'const a = 1;',
  'lib/b.dart': "export 'a.dart';",
  'lib/c.dart': 'const c = 1;',
  'test/a_test.dart': "import 'package:example/b.dart'; void main() {}",
  'test/c_test.dart': "import '../lib/c.dart'; void main() {}",
};
List<String> selected(Map<String, Object> plan) =>
    plan['files']! as List<String>;
Map<String, Object> plan(
  Set<String> changed, {
  Map<String, String>? before,
  Map<String, String>? after,
  bool full = false,
  Set<String> ordinaryDocuments = const {},
}) => selectFlutterTests(
  before: before ?? fixture,
  after: after ?? fixture,
  changed: changed,
  full: full,
  ordinaryDocuments: ordinaryDocuments,
);

void main() {
  test('CLI binds document ownership and full fallback to committed trees', () {
    final root = Directory.systemTemp.createTempSync(
      'catch-flutter-selection-',
    );
    final selector = File(
      'tool/harness/lib/flutter_test_selection.dart',
    ).absolute.path;
    final packages = File('.dart_tool/package_config.json').absolute.path;
    String git(List<String> args) {
      final result = Process.runSync('git', args, workingDirectory: root.path);
      expect(result.exitCode, 0, reason: result.stderr as String);
      return (result.stdout as String).trim();
    }

    void write(String name, String text) {
      final file = File('${root.path}/$name');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(text);
    }

    String commit() {
      git(['add', '.']);
      git([
        '-c',
        'user.name=CI test',
        '-c',
        'user.email=ci@example.invalid',
        'commit',
        '--quiet',
        '-m',
        'fixture',
      ]);
      return git(['rev-parse', 'HEAD']);
    }

    try {
      git(['init', '--quiet']);
      for (final entry in fixture.entries) {
        write(entry.key, entry.value);
      }
      write('test/probe_test.dart', "import 'dart:io'; void main() {}");
      write('docs/feature.md', 'Before');
      write(
        'tool/harness/component_graph.json',
        File('tool/harness/component_graph.json').readAsStringSync(),
      );
      write('.gitignore', 'plan.json\nbin/\n');
      final base = commit();
      write('lib/a.dart', 'const a = 2;');
      write('docs/feature.md', 'After');
      final head = commit();
      Map<String, dynamic> run({
        bool full = false,
        String? path,
        bool commitWindow = false,
        String? selectedBase,
        String? selectedHead,
      }) {
        final result = Process.runSync(
          Platform.resolvedExecutable,
          [
            '--packages=$packages',
            selector,
            '--base',
            selectedBase ?? base,
            '--head',
            selectedHead ?? head,
            '--full',
            '$full',
            '--commit-window',
            '$commitWindow',
            '--output',
            '${root.path}/plan.json',
          ],
          workingDirectory: root.path,
          environment: path == null ? null : {'PATH': path},
        );
        expect(result.exitCode, 0, reason: result.stderr as String);
        return jsonDecode(File('${root.path}/plan.json').readAsStringSync())
            as Map<String, dynamic>;
      }

      final selected = run();
      expect(selected['baseSha'], base);
      expect(selected['sourceSha'], head);
      expect(selected['mode'], 'affected');
      expect(selected['files'], ['test/a_test.dart', 'test/probe_test.dart']);
      expect(selected['ordinaryDocuments'], ['docs/feature.md']);
      expect(run(full: true)['selectedTests'], 3);
      // Missing classifier runtime must broaden coverage, never fail open.
      final bin = Directory('${root.path}/bin')..createSync();
      final gitPath = (Process.runSync('which', ['git']).stdout as String)
          .trim();
      Link('${bin.path}/git').createSync(gitPath);
      expect(run(path: bin.path)['selectedTests'], 3);
      // An intermediate dependency edge is absent from both initial snapshots.
      // Its changed owner remains in the committed window, selecting the head
      // test that a finalized predecessor-based selector would require.
      write('lib/b.dart', "export 'c.dart';");
      final intermediate = commit();
      write('lib/b.dart', "export 'a.dart';");
      write('lib/c.dart', 'const c = 2;');
      final restored = commit();
      final endpoint = run(selectedBase: head, selectedHead: restored);
      expect(endpoint['files'], ['test/c_test.dart', 'test/probe_test.dart']);
      final window = run(
        selectedBase: head,
        selectedHead: restored,
        commitWindow: true,
      );
      expect(window['reason'], startsWith('Union of base/head'));
      expect(window['commitWindow'], true);
      expect(window['files'], [
        'test/a_test.dart',
        'test/c_test.dart',
        'test/probe_test.dart',
      ]);
      final finalized = run(selectedBase: intermediate, selectedHead: restored);
      expect(
        (window['files'] as List).toSet().containsAll(
          finalized['files'] as List,
        ),
        isTrue,
      );
      // A removed/renamed dependency also survives the window and never loses
      // the dependent test when the original name is restored.
      git(['mv', 'lib/a.dart', 'lib/renamed.dart']);
      write('lib/b.dart', "export 'renamed.dart';");
      commit();
      git(['mv', 'lib/renamed.dart', 'lib/a.dart']);
      write('lib/b.dart', "export 'a.dart';");
      final renamedBack = commit();
      final renamedWindow = run(
        selectedBase: restored,
        selectedHead: renamedBack,
        commitWindow: true,
      );
      expect((renamedWindow['files'] as List), contains('test/a_test.dart'));
    } finally {
      root.deleteSync(recursive: true);
    }
  });
  test('lint engine probes follow their API dependencies and fail closed', () {
    final tree = {
      ...fixture,
      'tool/check_catch_ui_lints.sh':
          "run_probe <<'DART'\nimport 'package:example/b.dart';\nDART\n",
      'packages/catch_ui_lints/probes/catch_ui_lint_probes.dart':
          'const probe = 1;',
    };
    bool needs(Set<String> changed) =>
        needsUiLintSmoke(before: tree, after: tree, changed: changed);
    expect(needs({'lib/c.dart'}), false);
    expect(
      needsUiLintSmoke(
        before: tree,
        after: tree,
        changed: {'lib/c.dart', 'docs/feature.md'},
        ordinaryDocuments: {'docs/feature.md'},
      ),
      false,
    );
    expect(
      needsUiLintSmoke(
        before: tree,
        after: tree,
        changed: {'lib/a.dart', 'docs/feature.md'},
        ordinaryDocuments: {'docs/feature.md'},
      ),
      true,
    );

    expect(needs({'test/c_test.dart'}), false);
    expect(needs({'lib/a.dart'}), true);
    expect(needs({'pubspec.lock'}), true);
    expect(needs({'packages/catch_ui_lints/lib/plugin.dart'}), true);
    expect(
      needsUiLintSmoke(before: {}, after: tree, changed: {'lib/c.dart'}),
      true,
    );
    expect(
      needsUiLintSmoke(
        before: tree,
        after: tree,
        changed: {'lib/c.dart'},
        full: true,
      ),
      true,
    );
  });
  test('ordinary prose does not broaden a proven source change', () {
    expect(
      selected(
        plan(
          {'lib/a.dart', 'docs/feature.md'},
          ordinaryDocuments: {'docs/feature.md'},
        ),
      ),
      ['test/a_test.dart'],
    );
    expect(plan({'lib/a.dart', 'docs/feature.md'})['mode'], 'full');
    expect(
      plan({'docs/feature.md'}, ordinaryDocuments: {'docs/feature.md'})['mode'],
      'full',
    );
    expect(
      plan(
        {'lib/a.dart', 'docs/feature.md'},
        ordinaryDocuments: {'docs/feature.md'},
        full: true,
      )['mode'],
      'full',
    );
    final files = {
      ...fixture,
      'test/probe_test.dart': "import 'dart:io'; void main() {}",
    };
    expect(
      selected(
        plan(
          {'lib/a.dart', 'docs/feature.md'},
          before: files,
          after: files,
          ordinaryDocuments: {'docs/feature.md'},
        ),
      ),
      ['test/a_test.dart', 'test/probe_test.dart'],
    );
  });
  test('transitive exports select dependent tests only', () {
    expect(selected(plan({'lib/a.dart'})), ['test/a_test.dart']);
  });
  test('changed tests and imported test helpers are selected', () {
    expect(selected(plan({'test/c_test.dart'})), ['test/c_test.dart']);
    final files = {
      ...fixture,
      'test/helper.dart': 'const x = 1;',
      'test/a_test.dart': "import 'helper.dart'; void main() {}",
    };
    expect(selected(plan({'test/helper.dart'}, before: files, after: files)), [
      'test/a_test.dart',
    ]);
  });
  test('old dependency edges survive deletion and rename', () {
    final after = {...fixture}..remove('lib/a.dart');
    after['lib/b.dart'] = 'const b = 1;';
    expect(selected(plan({'lib/a.dart', 'lib/b.dart'}, after: after)), [
      'test/a_test.dart',
    ]);
  });
  test(
    'new tests and removed old tests are handled without an empty shard',
    () {
      final after = {...fixture, 'test/new_test.dart': 'void main() {}'}
        ..remove('test/c_test.dart');
      expect(
        selected(
          plan({'test/new_test.dart', 'test/c_test.dart'}, after: after),
        ),
        ['test/new_test.dart'],
      );
    },
  );
  test('conditional imports and part directives propagate impact', () {
    final files = {
      ...fixture,
      'lib/b.dart':
          "import 'a.dart' if (dart.library.io) 'conditional.dart'; part 'fragment.dart';",
      'lib/conditional.dart': 'const value = 1;',
      'lib/fragment.dart': "part of 'b.dart'; const fragment = 1;",
    };
    for (final changed in ['lib/conditional.dart', 'lib/fragment.dart']) {
      expect(selected(plan({changed}, before: files, after: files)), [
        'test/a_test.dart',
      ]);
    }
  });
  test('filesystem source probes always run', () {
    final files = {
      ...fixture,
      'test/probe_test.dart': "import 'dart:io'; void main() {}",
    };
    expect(selected(plan({'lib/c.dart'}, before: files, after: files)), [
      'test/c_test.dart',
      'test/probe_test.dart',
    ]);
    expect(
      plan(
        {'lib/untested.dart'},
        before: files,
        after: {...files, 'lib/untested.dart': 'const x = 1;'},
      )['mode'],
      'full',
      reason: 'Filesystem probes must not disguise an unproven dependency.',
    );
  });
  test('cycles terminate and imports in comments do not create edges', () {
    final files = {
      ...fixture,
      'lib/a.dart': "import 'b.dart'; // import 'c.dart';\nconst a = 1;",
    };
    expect(selected(plan({'lib/c.dart'}, before: files, after: files)), [
      'test/c_test.dart',
    ]);
  });
  test('external packages are opaque until dependencies change', () {
    final files = {
      ...fixture,
      'lib/a.dart': "import 'package:external/external.dart'; const a = 1;",
    };
    expect(selected(plan({'lib/a.dart'}, before: files, after: files)), [
      'test/a_test.dart',
    ]);
    expect(plan({'pubspec.lock'}, before: files, after: files)['mode'], 'full');
  });
  test(
    'assets, configuration, nightly and unknown inputs retain full suite',
    () {
      for (final changed in [
        'assets/font.ttf',
        'test/fixture.json',
        'test/flutter_test_config.dart',
        'tool/generator.dart',
        '.github/workflows/flutter-ci.yml',
      ]) {
        expect(plan({changed})['mode'], 'full');
      }
      expect(plan({'lib/a.dart'}, full: true)['mode'], 'full');
      expect(plan({})['mode'], 'full');
    },
  );
  test('unresolved, malformed and untested source fail conservatively', () {
    expect(
      plan(
        {'lib/a.dart'},
        after: {...fixture, 'lib/a.dart': "import 'missing.dart';"},
      )['mode'],
      'full',
    );
    expect(
      plan(
        {'lib/a.dart'},
        after: {...fixture, 'lib/a.dart': 'void broken('},
      )['mode'],
      'full',
    );
    expect(
      plan(
        {'lib/untested.dart'},
        after: {...fixture, 'lib/untested.dart': 'const x = 1;'},
      )['mode'],
      'full',
    );
    expect(
      () => selectFlutterTests(before: {}, after: {}, changed: {}),
      throwsStateError,
    );
  });
}
