// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter_test/flutter_test.dart';

import '../../tool/lib/audit_registry_paths.dart';

void main() {
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
