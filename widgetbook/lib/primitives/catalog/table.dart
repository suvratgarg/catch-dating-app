import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/primitives/contracts/table.dart';
import 'package:widgetbook_workspace/support/catalog_preview.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTableRow,
  path: '[Core catalog]/Data display',
)
Widget catchTableRowCatalogStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'CatchTableRow',
    catalogId: 'catch.table.row',
    children: [
      WidgetbookCatalogStateCard(
        label: 'rows inside a table',
        child: CatchTable(
          columns: widgetbookTableColumns,
          children: widgetbookTableRows(context),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTableScope,
  path: '[Core catalog]/Data display',
)
Widget catchTableScopeCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookCatalogFrame(
    title: 'CatchTableScope',
    catalogId: 'catch.table.scope',
    children: [
      WidgetbookCatalogStateCard(
        label: 'columns published to rows',
        child: CatchTableScope(
          columns: widgetbookTableColumns,
          child: Builder(
            builder: (context) => Text(
              '${CatchTableScope.columnsOf(context).length} columns in scope',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ),
      ),
    ],
  );
}
