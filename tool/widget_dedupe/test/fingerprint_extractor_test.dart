// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:test/test.dart';

import '../lib/src/fingerprint_extractor.dart';

void main() {
  final repoRoot = Directory.current.path;
  final fixtureFiles = [
    'tool/widget_dedupe/fixtures/probe_dupe_a.dart',
    'tool/widget_dedupe/fixtures/probe_dupe_b.dart',
    'tool/widget_dedupe/fixtures/probe_near_c.dart',
    'tool/widget_dedupe/fixtures/probe_distinct.dart',
    'tool/widget_dedupe/fixtures/probe_alpha_status_pill.dart',
    'tool/widget_dedupe/fixtures/probe_beta_status_pill.dart',
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
}
