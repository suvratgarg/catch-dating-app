import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Filters loading composition',
  type: FiltersBody,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget filtersContentSkeletonStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'FiltersBody.loading',
    contractId: 'screen.catches.filters.loading',
    children: [
      WidgetbookPageStateCard(
        label: 'loading',
        child: WidgetbookCatchesDeviceFrame(child: FiltersBody.loading()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Filter section states',
  type: FiltersSection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget filtersSectionStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'FiltersSection',
    contractId: 'screen.catches.filters.section',
    children: [
      WidgetbookPageStateCard(
        label: 'value section',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.compactPanelHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: FiltersSection(
              title: 'Age',
              child: FiltersValueText(value: '24 - 36'),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Filter value states',
  type: FiltersValueText,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget filtersValueStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'FiltersValueText',
    contractId: 'screen.catches.filters.value',
    children: [
      WidgetbookPageStateCard(
        label: 'default',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.smallPreviewExtent,
          child: Padding(
            padding: CatchInsets.content,
            child: FiltersValueText(value: '24 - 36'),
          ),
        ),
      ),
    ],
  );
}
