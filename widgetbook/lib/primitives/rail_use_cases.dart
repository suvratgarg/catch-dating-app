import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Bounded and intrinsic rails',
  type: CatchHorizontalRailBody,
  path: '[Core primitives]/Sections',
)
Widget horizontalRailBodyStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Horizontal rail viewport',
  catalogId: 'catch.section.horizontal_rail_body',
  children: [
    for (final height in <double?>[110, null])
      CatchHorizontalRailBody(
        height: height,
        spacing: CatchSpacing.s3,
        listPadding: EdgeInsets.zero,
        itemCount: 3,
        itemWidth: 160,
        itemBuilder: (context, index) => CatchSurface.card(
          height: height == null ? 84 : 110,
          child: Text(
            'Item ${index + 1}',
            style: CatchTextStyles.labelM(context),
          ),
        ),
        trailing: CatchButton(label: 'More', onPressed: () {}),
      ),
  ],
);

@widgetbook.UseCase(
  name: 'Item widths and trailing slots',
  type: CatchHorizontalRailItem,
  path: '[Core primitives]/Sections',
)
Widget horizontalRailItemStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Horizontal rail items',
  catalogId: 'catch.section.horizontal_rail_item',
  children: [
    for (final width in <double?>[null, 180])
      Align(
        alignment: Alignment.centerLeft,
        child: CatchHorizontalRailItem(
          index: 0,
          itemCount: 1,
          width: width,
          itemBuilder: (context, index) => CatchSurface.card(
            child: Text('Item', style: CatchTextStyles.labelM(context)),
          ),
        ),
      ),
    Align(
      alignment: Alignment.centerLeft,
      child: CatchHorizontalRailItem(
        index: 1,
        itemCount: 1,
        width: 180,
        itemBuilder: (context, index) => const Text('Item'),
        trailing: CatchButton(label: 'More', onPressed: () {}),
      ),
    ),
  ],
);
