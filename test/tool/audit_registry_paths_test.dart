// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/lib/audit_registry_paths.dart';

void main() {
  group('retired registry writers', () {
    late Directory fixture;
    late String auditRegistryScript;

    setUp(() {
      auditRegistryScript = File('tool/audit_registry.dart').absolute.path;
      fixture = Directory.systemTemp.createTempSync(
        'catch-audit-registry-read-only-',
      );
      final registry = Directory('${fixture.path}/docs/audit_registry')
        ..createSync(recursive: true);
      File(
        '${registry.path}/files.jsonl',
      ).writeAsStringSync('${jsonEncode(_rootManifestInventoryEntry)}\n');
      File(
        '${registry.path}/passes.jsonl',
      ).writeAsStringSync('{"pass_id":"existing-receipt"}\n');
      final rootManifest = File(
        '${fixture.path}/tool/repository_root_manifest.json',
      )..createSync(recursive: true);
      rootManifest.writeAsStringSync('{"auditPolicies":[]}\n');
      expect(
        Process.runSync('git', [
          'init',
          '--quiet',
        ], workingDirectory: fixture.path).exitCode,
        0,
      );
      expect(
        Process.runSync('git', [
          'add',
          'tool/repository_root_manifest.json',
        ], workingDirectory: fixture.path).exitCode,
        0,
      );
    });

    tearDown(() {
      fixture.deleteSync(recursive: true);
    });

    test('refresh without --check refuses without changing snapshots', () {
      final before = _registrySnapshots(fixture);

      final result = Process.runSync('dart', [
        auditRegistryScript,
        'refresh',
      ], workingDirectory: fixture.path);

      expect(result.exitCode, 64);
      expect('${result.stderr}', contains('Audit registry writes are retired'));
      expect(_registrySnapshots(fixture), before);
    });

    test('mark-pass refuses without changing snapshots', () {
      final before = _registrySnapshots(fixture);

      final result = Process.runSync('dart', [
        auditRegistryScript,
        'mark-pass',
        '--pass',
        'should-not-exist',
        '--rules',
        'AUDIT-REGISTRY-001',
        '--paths',
        'tool/repository_root_manifest.json',
      ], workingDirectory: fixture.path);

      expect(result.exitCode, 64);
      expect('${result.stderr}', contains('Audit pass receipts are retired'));
      expect(_registrySnapshots(fixture), before);
    });

    test('refresh --check verifies parity without changing snapshots', () {
      final before = _registrySnapshots(fixture);

      final result = Process.runSync('dart', [
        auditRegistryScript,
        'refresh',
        '--check',
      ], workingDirectory: fixture.path);

      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(
        '${result.stdout}',
        contains('inventory is current (1 file entries)'),
      );
      expect(_registrySnapshots(fixture), before);
    });
  });

  test('keeps index paths that are absent from a sparse working tree', () {
    const gitOutput =
        '100644 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 0\t'
        'tool/audit_registry.dart\u0000'
        '100644 bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb 0\t'
        'apps/consumer/lib/main.dart\u0000'
        '100755 cccccccccccccccccccccccccccccccccccccccc 0\t'
        'tool/ci/check.sh\u0000'
        '120000 dddddddddddddddddddddddddddddddddddddddd 0\t'
        'apps/consumer/assets\u0000'
        '100644 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 0\t'
        'tool/audit_registry.dart\u0000';

    expect(trackedAuditPathsFromGitIndex(gitOutput), <String>[
      'apps/consumer/lib/main.dart',
      'tool/audit_registry.dart',
      'tool/ci/check.sh',
    ]);
  });

  test('rejects malformed or unsupported index records', () {
    for (final output in <String>[
      '100644 abc 0\ttool/file.dart',
      'malformed\u0000',
      '100644 not-a-hash 0\ttool/file.dart\u0000',
      '100600 abc 0\ttool/file.dart\u0000',
      '100644 abc 2\ttool/file.dart\u0000',
    ]) {
      expect(
        () => trackedAuditPathsFromGitIndex(output),
        throwsFormatException,
      );
    }
  });

  test('detects staged deletions and registry entries needing refresh', () {
    expect(
      missingAuditPaths(
        requested: <String>['kept.dart', 'deleted.dart', 'deleted.dart'],
        available: <String>['kept.dart', 'new.dart'],
      ),
      <String>['deleted.dart'],
    );
    expect(
      missingAuditPaths(
        requested: <String>['new.dart'],
        available: <String>['kept.dart'],
      ),
      <String>['new.dart'],
    );
  });

  test('loads required JSON from the index when sparse checkout omits it', () {
    expect(
      requiredJsonObjectFromWorkingTreeOrIndex(
        path: 'tool/repository_root_manifest.json',
        indexExitCode: 0,
        indexStdout: '{"auditPolicies": []}',
        requiredListKeys: const <String>['auditPolicies'],
      ),
      <String, dynamic>{'auditPolicies': <dynamic>[]},
    );

    expect(
      () => requiredJsonObjectFromWorkingTreeOrIndex(
        path: 'tool/repository_root_manifest.json',
        indexExitCode: 128,
        indexStderr: 'path not in the index',
      ),
      throwsStateError,
    );
    expect(
      () => requiredJsonObjectFromWorkingTreeOrIndex(
        path: 'tool/repository_root_manifest.json',
        workingTreeContent: '[]',
        requiredListKeys: const <String>['auditPolicies'],
      ),
      throwsFormatException,
    );
    expect(
      () => requiredJsonObjectFromWorkingTreeOrIndex(
        path: 'tool/repository_root_manifest.json',
        workingTreeContent: '{invalid',
        requiredListKeys: const <String>['auditPolicies'],
      ),
      throwsFormatException,
    );
    for (final content in <String>['{}', '{"auditPolicies": "all"}']) {
      expect(
        () => requiredJsonObjectFromWorkingTreeOrIndex(
          path: 'tool/repository_root_manifest.json',
          workingTreeContent: content,
          requiredListKeys: const <String>['auditPolicies'],
        ),
        throwsFormatException,
      );
    }
  });
}

const _rootManifestInventoryEntry = <String, dynamic>{
  'path': 'tool/repository_root_manifest.json',
  'area': 'tooling',
  'kind': 'tool',
  'status': 'unreviewed',
  'last_pass_id': null,
  'doc_versions': <String, dynamic>{},
  'rules_applied': <dynamic>[],
  'debt': <dynamic>[],
  'proof': <dynamic>[],
  'notes': '',
};

Map<String, String> _registrySnapshots(Directory fixture) {
  final registry = '${fixture.path}/docs/audit_registry';
  return <String, String>{
    'files.jsonl': File('$registry/files.jsonl').readAsStringSync(),
    'passes.jsonl': File('$registry/passes.jsonl').readAsStringSync(),
  };
}
