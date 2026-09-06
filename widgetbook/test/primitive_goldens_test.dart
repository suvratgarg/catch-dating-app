import 'dart:io';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_golden_test_core/widgetbook_golden_test_core.dart';
import 'package:widgetbook_workspace/main.directories.g.dart';
import 'package:widgetbook_workspace/primitives/core_catalog_use_cases.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

import '../../test/goldens/support/golden_pump.dart';
import 'support/triage_inventory.dart';

// These ids select generated use cases; they do not redeclare component states.
const _referenceCases = <String, String>{
  'Core catalog/Menus/CatchMenuRow/Catalog states': 'menu_row',
  'Core catalog/Typography/CatchMonoLabel/Catalog states': 'mono_label',
  'Core catalog/Typography/CatchSectionLabel/Catalog states': 'section_label',
  'Core catalog/Inputs/CatchControlShell/Catalog states': 'control_shell',
  'Core catalog/Navigation/CatchStepProgress/Catalog states': 'step_progress',
  'Core catalog/Navigation/CatchPageDots/Catalog states': 'page_dots',
  'Core catalog/Data display/CatchStatColumn/Catalog states': 'stat_column',
  'Core catalog/Data display/CatchMetaDotRow/Catalog states': 'meta_dot_row',
  'Core catalog/Sheets and footers/CatchBottomSheetGrabber/Catalog states':
      'bottom_sheet_grabber',
  'Core catalog/Icon atoms/CatchIconTile/Catalog states': 'icon_tile',
};

String _annotationKey(Map<String, Object?> row) {
  final type = (row['type'] as String).replaceFirst(RegExp(r'<.*>'), '');
  return [row['file'], row['builder'], type, row['name']].join(':');
}

List<Map<String, Object?>> _inventoryRows(Object? value) {
  return (value! as List<Object?>)
      .map((row) => (row! as Map<Object?, Object?>).cast<String, Object?>())
      .toList();
}

Map<String, bool> _coreGoldenDesignations() {
  final fromWidgetbook = File('lib/main.directories.g.dart').existsSync();
  final inventory = readWidgetbookInventory(
    repoRoot: fromWidgetbook ? '..' : '.',
  );
  final registrations = {
    for (final row in _inventoryRows(inventory['generated']))
      _annotationKey(row): '${row['path']}/${row['name']}',
  };
  return {
    for (final row in _inventoryRows(inventory['cases']))
      if (row['typeFile'] is String &&
          _isGoldenSource(row['typeFile'] as String) &&
          registrations.containsKey(_annotationKey(row)))
        registrations[_annotationKey(row)]!:
            (row['file'] as String).startsWith('widgetbook/lib/primitives/') ||
            (row['file'] as String).startsWith('widgetbook/lib/geometry/'),
  };
}

bool _isGoldenSource(String path) =>
    path.startsWith('lib/core/widgets/') ||
    path.startsWith('packages/catch_ui/lib/src/primitives/') ||
    path.startsWith('packages/catch_ui/lib/src/components/') ||
    path.startsWith('packages/catch_ui/lib/src/patterns/');

String _corpusStem(String id) {
  final legacy = _referenceCases[id];
  if (legacy != null) return legacy;
  var hash = 0x811c9dc5;
  for (final unit in id.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  final slug = id
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final tail = slug.length <= 96 ? slug : slug.substring(slug.length - 96);
  return 'corpus/${tail}_${hash.toRadixString(16).padLeft(8, '0')}';
}

void main() {
  final coreGoldenDesignations = _coreGoldenDesignations();
  final coreGoldenIds = coreGoldenDesignations.keys.toSet();
  final renderer = _CatchGoldenRenderer(coreGoldenDesignations);
  WidgetbookGoldenTestGenerator(
    properties: WidgetbookGoldenTestsProperties(),
    renderer: renderer,
  ).generate(nodes: directories, goldenSnapshotsOutputPath: '');

  test('generator visits every registered case and every designation once', () {
    final source = File('lib/main.directories.g.dart').readAsStringSync();
    final registered = RegExp(
      r'_widgetbook\.WidgetbookUseCase\(',
    ).allMatches(source).length;
    expect(registered, greaterThan(0));
    expect(renderer.visited.length, registered);
    expect(renderer.visited.toSet().length, registered);
    expect(coreGoldenIds, hasLength(265));
    expect(renderer.selected, unorderedEquals(coreGoldenIds));
    expect(
      coreGoldenIds.map(_corpusStem).toSet(),
      hasLength(coreGoldenIds.length),
    );
  });

  testWidgets('booking dock catalog mounts the production state surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WidgetbookCaseScope(
            builder: eventDetailBookingDockCatalogStates,
          ),
        ),
      ),
    );
    final docks = tester.widgetList<EventBookingDock>(
      find.byType(EventBookingDock),
    );
    expect(docks, hasLength(4));
    expect(docks.map((dock) => dock.label), [
      'Join event - 3 spots left',
      'Cancel booking',
      'Join waitlist',
      'You attended this event',
    ]);
    expect(
      docks.where((dock) => dock.onPressed == null).single.label,
      'You attended this event',
    );
  });

  testWidgets('shared scope preserves theme, scale and knob defaults', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: WidgetbookCaseScope(
            builder: (context) {
              expect(Theme.of(context).brightness, Brightness.dark);
              expect(MediaQuery.textScalerOf(context).scale(1), 2);
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Catch',
              );
              return Text(label);
            },
          ),
        ),
      ),
    );
    expect(find.text('Catch'), findsOneWidget);
  });
}

/// Adopt the maintained traversal/generator, adapting only rendering to Catch.
/// Every designated case is rebuilt under each theme by matchCatchGolden.
class _CatchGoldenRenderer implements WidgetbookGoldenRenderer {
  _CatchGoldenRenderer(this.designations);

  final Map<String, bool> designations;
  Set<String> get designatedIds => designations.keys.toSet();
  final visited = <String>[];
  final selected = <String>[];

  @override
  void renderSimpleGoldenTest({
    required WidgetbookUseCase useCase,
    required String goldenPath,
    required WidgetbookGoldenTestsProperties properties,
    required bool skip,
    WidgetbookGoldenTestBuilder? goldenTestBuilder,
  }) {
    final id = '$goldenPath/${useCase.name}'.replaceFirst(RegExp(r'^/'), '');
    visited.add(id);
    if (!designatedIds.contains(id)) return;
    final stem = _corpusStem(id);
    if (skip || goldenTestBuilder != null) {
      throw StateError(
        'Designated case needs explicit Catch rendering support: $id',
      );
    }
    selected.add(id);
    final scales = designations[id]! ? const [1.0, 2.0] : const [1.0];
    for (final scale in scales) {
      testWidgets('$id at scale $scale', (tester) async {
        final preservesReference =
            _referenceCases.containsKey(id) &&
            (scale == 1 || stem == 'mono_label');
        await goldenTestZoneRunner(
          properties: properties,
          testBody: () => matchCatchGolden(
            tester,
            'widgetbook/$stem${scale == 1 ? '' : '@2.0'}',
            size: Size(440, preservesReference ? 1000 : 1400),
            textScale: scale,
            fitContentKey: preservesReference
                ? null
                : widgetbookCatalogContentKey,
            fitFirstScrollable: !preservesReference,
            builder: (_) => WidgetbookFixtureScope(
              overrides: const [],
              child: WidgetbookCaseScope(
                // A fresh scope for each light/dark render resets knob state.
                key: UniqueKey(),
                builder: useCase.builder,
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  void renderGoldenPlayActionTest({
    required WidgetbookUseCase useCase,
    required String goldenPath,
    required WidgetbookGoldenTestsProperties properties,
    required GoldenPlayAction action,
    required bool skip,
    WidgetbookGoldenTestBuilder? goldenTestBuilder,
  }) {
    if (designatedIds.contains(
      '$goldenPath/${useCase.name}'.replaceFirst(RegExp(r'^/'), ''),
    )) {
      throw UnsupportedError(
        'Reference slice does not designate play actions.',
      );
    }
  }
}
