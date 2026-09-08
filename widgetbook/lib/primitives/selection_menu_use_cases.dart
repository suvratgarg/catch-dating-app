import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

const _choices = [
  CatchSelectionMenuItem(value: 'recent', label: 'Last seen'),
  CatchSelectionMenuItem(
    value: 'attended',
    label: 'Most attended',
    sublabel: 'Highest event attendance first',
    icon: Icons.people_outline,
  ),
  CatchSelectionMenuItem(value: 'name', label: 'Name', enabled: false),
];

@widgetbook.UseCase(
  name: 'Selected and disabled choices',
  type: CatchSelectionSheet,
  path: '[Core primitives]/Menus',
)
Widget selectionSheetStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Selection sheet',
  catalogId: 'catch.menu.selection_sheet',
  children: [
    for (final selected in ['recent', 'attended'])
      Align(
        child: SizedBox(
          width: 390,
          child: CatchSelectionSheet<String>(
            title: 'Sort customers',
            subtitle: 'Choose how this list is ordered.',
            items: _choices,
            value: selected,
          ),
        ),
      ),
  ],
);

@widgetbook.UseCase(
  name: 'Custom trigger at window boundaries',
  type: CatchAdaptiveSelectionMenu,
  path: '[Core primitives]/Menus',
)
Widget adaptiveSelectionMenuStates(BuildContext context) {
  var selected = 'recent';
  return WidgetbookCatalogFrame(
    title: 'Custom selection trigger',
    catalogId: 'catch.menu.adaptive_trigger',
    children: [
      for (final width in [599.0, 600.0, 840.0]) ...[
        CatchMetadataText(
          '${width.toInt()} px window',
          color: CatchTokens.of(context).ink2,
        ),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(size: Size(width, 800)),
          child: StatefulBuilder(
            builder: (context, setState) => CatchAdaptiveSelectionMenu<String>(
              title: 'Sort customers',
              items: _choices,
              value: selected,
              onSelected: (value) => setState(() => selected = value),
              builder: (context, item, open, toggle) =>
                  CatchButton.text(label: item.label, onPressed: toggle),
            ),
          ),
        ),
      ],
    ],
  );
}

@widgetbook.UseCase(
  name: 'Visible trigger at window boundaries',
  type: CatchAdaptiveSelectionControl,
  path: '[Core primitives]/Menus',
)
Widget adaptiveSelectionControlStates(BuildContext context) {
  var selected = 'attended';
  return WidgetbookCatalogFrame(
    title: 'Visible selection control',
    catalogId: 'catch.menu.adaptive_selection',
    children: [
      for (final width in [599.0, 600.0, 840.0]) ...[
        CatchMetadataText(
          '${width.toInt()} px window',
          color: CatchTokens.of(context).ink2,
        ),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(size: Size(width, 800)),
          child: StatefulBuilder(
            builder: (context, setState) =>
                CatchAdaptiveSelectionControl<String>(
                  title: 'Sort customers',
                  tooltip: 'Sort customers',
                  items: _choices,
                  value: selected,
                  triggerLabel: (item) => 'Sort: ${item.label}',
                  onSelected: (value) => setState(() => selected = value),
                ),
          ),
        ),
        gapH8,
      ],
    ],
  );
}
