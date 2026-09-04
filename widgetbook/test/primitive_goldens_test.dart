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

void main() {
  final renderer = _CatchGoldenRenderer();
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
    expect(renderer.selected, unorderedEquals(_referenceCases.keys));
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
    final stem = _referenceCases[id];
    if (stem == null) return;
    if (skip || goldenTestBuilder != null) {
      throw StateError(
        'Designated case needs explicit Catch rendering support: $id',
      );
    }
    selected.add(id);
    for (final scale in [1.0, if (stem == 'mono_label') 2.0]) {
      testWidgets('$id at scale $scale', tags: ['golden'], (tester) async {
        await matchCatchGolden(
          tester,
          'widgetbook/$stem${scale == 1 ? '' : '@2.0'}',
          size: const Size(440, 1000),
          textScale: scale,
          builder: (_) => WidgetbookFixtureScope(
            overrides: const [],
            child: WidgetbookCaseScope(
              // A fresh scope for each light/dark render resets knob state.
              key: UniqueKey(),
              builder: useCase.builder,
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
    if (_referenceCases.containsKey(
      '$goldenPath/${useCase.name}'.replaceFirst(RegExp(r'^/'), ''),
    )) {
      throw UnsupportedError(
        'Reference slice does not designate play actions.',
      );
    }
  }
}
