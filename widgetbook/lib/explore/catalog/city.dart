import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'City picker states',
  type: ExploreCityPicker,
  path: '[Explore]/Controls',
)
Widget exploreCityPickerStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreCityPicker',
    catalogId: 'control.explore.city_picker',
    children: [
      WidgetbookPageStateCard(
        label: 'ready',
        child: Center(
          child: ExploreCityPicker(
            state: widgetbookExploreCityPickerState(),
            onSelected: widgetbookExploreNoopCity,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'city source loading',
        child: Center(
          child: ExploreCityPicker(
            state: widgetbookExploreCityPickerState(
              cities: const [],
              cityListLoading: true,
            ),
            onSelected: widgetbookExploreNoopCity,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Trigger states',
  type: CityTrigger,
  path: '[Explore]/Controls',
)
Widget exploreCityTriggerStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookScrollCatalogFrame(
    title: 'CityTrigger',
    catalogId: 'control.explore.city_trigger',
    children: [
      WidgetbookPageStateCard(
        label: 'icon ready',
        child: Center(
          child: CityTrigger(
            city: widgetbookExploreMumbai,
            focused: false,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'icon focused',
        child: Center(
          child: CityTrigger(
            city: widgetbookExploreDelhi,
            focused: true,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'scope label disabled',
        child: Center(
          child: CityTrigger(
            city: widgetbookExploreMumbai,
            focused: false,
            enabled: false,
            presentation: ExploreCityPickerPresentation.scopeLabel,
            foregroundColor: t.ink,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'City picker sheet states',
  type: ExploreCityPickerSheet,
  path: '[Explore]/Controls',
)
Widget exploreCityPickerSheetStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreCityPickerSheet',
    catalogId: 'control.explore.city_picker_sheet',
    children: [
      WidgetbookPageStateCard(
        label: 'default',
        child: WidgetbookContentFrame(
          child: ExploreCityPickerSheet(
            cities: const [widgetbookExploreMumbai, widgetbookExploreDelhi],
            selectedCity: widgetbookExploreMumbai,
            onSelected: (_) {},
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'empty list',
        child: WidgetbookContentFrame(
          child: ExploreCityPickerSheet(
            cities: const [],
            selectedCity: widgetbookExploreMumbai,
            onSelected: (_) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'City option tile states',
  type: CityOptionTile,
  path: '[Explore]/Controls',
)
Widget cityOptionTileStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'CityOptionTile',
    catalogId: 'control.explore.city_option_tile',
    children: [
      WidgetbookPageStateCard(
        label: 'selected',
        child: CityOptionTile(
          city: widgetbookExploreMumbai,
          selected: true,
          onTap: widgetbookNoop,
        ),
      ),
      WidgetbookPageStateCard(
        label: 'unselected',
        child: CityOptionTile(
          city: widgetbookExploreDelhi,
          selected: false,
          onTap: widgetbookNoop,
        ),
      ),
    ],
  );
}
