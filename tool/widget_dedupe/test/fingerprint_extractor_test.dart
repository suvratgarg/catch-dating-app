// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../lib/src/fingerprint_extractor.dart';

void main() {
  final repoRoot = _findRepoRoot(Directory.current).path;
  final fixtureFiles = [
    'tool/widget_dedupe/fixtures/probe_dupe_a.dart',
    'tool/widget_dedupe/fixtures/probe_dupe_b.dart',
    'tool/widget_dedupe/fixtures/probe_near_c.dart',
    'tool/widget_dedupe/fixtures/probe_distinct.dart',
    'tool/widget_dedupe/fixtures/probe_alpha_status_pill.dart',
    'tool/widget_dedupe/fixtures/probe_beta_status_pill.dart',
    'tool/widget_dedupe/fixtures/probe_parameter_shapes.dart',
  ];

  test('seeded structural probes produce expected fingerprints', () {
    final result = extractFingerprints(
      repoRoot: repoRoot,
      files: fixtureFiles,
      generatedAt: DateTime.utc(2026, 7, 2),
    );
    expect(result['failures'], isEmpty);
    final widgets = {
      for (final widget in result['widgets'] as List<Object?>)
        (widget as Map<String, Object?>)['name'] as String: widget,
    };

    expect(
      widgets['ProbeDupeA']!['shapeHash'],
      widgets['ProbeDupeB']!['shapeHash'],
    );
    expect(
      widgets['ProbeDupeA']!['shapeHash'],
      isNot(widgets['ProbeNearC']!['shapeHash']),
    );
    expect(
      widgets['ProbeDupeA']!['shapeHash'],
      isNot(widgets['ProbeDistinct']!['shapeHash']),
    );
    expect(widgets['ProbeDupeA']!['tokensUsed'], contains('CatchSpacing.s4'));
    expect(widgets['ProbeParameterShapes']!['constructorParams'], [
      {'name': 'label', 'type': 'String', 'required': false},
      {'name': 'onTap', 'type': 'void', 'required': true},
      {'name': 'enabled', 'type': 'bool', 'required': false},
    ]);
  });

  test('coarse stream sorts args and coarsens token members', () {
    final result = extractFingerprints(
      repoRoot: repoRoot,
      files: [
        'tool/widget_dedupe/fixtures/probe_alpha_status_pill.dart',
        'tool/widget_dedupe/fixtures/probe_beta_status_pill.dart',
      ],
      generatedAt: DateTime.utc(2026, 7, 2),
    );
    expect(result['failures'], isEmpty);
    final widgets = {
      for (final widget in result['widgets'] as List<Object?>)
        (widget as Map<String, Object?>)['name'] as String: widget,
    };

    expect(
      widgets['ProbeAlphaStatusPill']!['shapeHash'],
      isNot(widgets['ProbeBetaStatusPill']!['shapeHash']),
    );
    expect(
      widgets['ProbeAlphaStatusPill']!['coarseShapeHash'],
      widgets['ProbeBetaStatusPill']!['coarseShapeHash'],
    );
    expect(
      widgets['ProbeAlphaStatusPill']!['coarseTokenStream'],
      contains('T:CatchSpacing'),
    );
    expect(
      widgets['ProbeAlphaStatusPill']!['coarseTokenStream'],
      isNot(contains('T:CatchSpacing.s2')),
    );
  });

  test('state class methods are folded into owning widget fingerprints', () {
    final result = extractFingerprints(
      repoRoot: repoRoot,
      files: ['lib/core/widgets/catch_button.dart'],
      generatedAt: DateTime.utc(2026, 7, 2),
    );
    expect(result['failures'], isEmpty);
    final catchButton = (result['widgets'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((widget) => widget['name'] == 'CatchButton');

    expect(catchButton['stateClass'], '_CatchButtonState');
    expect(catchButton['tokenStreamLength'] as int, greaterThan(20));
  });

  test('widget-returning helpers are folded into the owning fingerprint', () {
    final result = extractFingerprints(
      repoRoot: repoRoot,
      files: ['tool/widget_dedupe/fixtures/probe_stateful_helper.dart'],
      generatedAt: DateTime.utc(2026, 7, 2),
    );
    expect(result['failures'], isEmpty);
    final widget = (result['widgets'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((entry) => entry['name'] == 'ProbeStatefulHelper');

    expect(widget['stateClass'], '_ProbeStatefulHelperState');
    expect(widget['hasWidgetHelpers'], isTrue);
    expect(widget['widgetsUsed'], contains('SizedBox'));
  });

  test('explicit classification drives targets and preserves metadata', () {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'catch-widget-classification-',
    );
    addTearDown(() => tempDirectory.deleteSync(recursive: true));
    final classification =
        File('${tempDirectory.path}/widget_classification.json')
          ..writeAsStringSync(
            jsonEncode({
              'widgets': [
                {
                  'name': 'ProbeDupeA',
                  'file': 'tool/widget_dedupe/fixtures/probe_dupe_a.dart',
                  'classKind': 'widget',
                  'role': 'pattern',
                  'contractId': 'probe.dupe',
                },
              ],
            }),
          );

    final result = extractFingerprints(
      repoRoot: repoRoot,
      classificationPath: classification.path,
      generatedAt: DateTime.utc(2026, 7, 2),
    );

    expect(result['failures'], isEmpty);
    final widget = (result['widgets'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .single;
    expect(widget['role'], 'pattern');
    expect(widget['contractId'], 'probe.dupe');
  });

  test('classification is required when no explicit files are supplied', () {
    expect(
      () => extractFingerprints(
        repoRoot: repoRoot,
        generatedAt: DateTime.utc(2026, 7, 2),
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('classificationPath is required'),
        ),
      ),
    );
  });
}

Directory _findRepoRoot(Directory start) {
  var current = start.absolute;
  while (true) {
    if (File('${current.path}/AGENTS.md').existsSync() &&
        Directory('${current.path}/tool/widget_dedupe').existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError(
        'Could not find the Catch repository root from ${start.path}.',
      );
    }
    current = parent;
  }
}
