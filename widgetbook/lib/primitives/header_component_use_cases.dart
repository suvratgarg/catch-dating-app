import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Text, child and icon labels',
  type: CatchTopBarTabLabel,
  path: '[Core primitives]/Navigation',
)
Widget topBarTabLabelStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Top-bar tab labels',
  catalogId: 'catch.top_bar.tab_label',
  children: [
    for (final selected in [true, false]) ...[
      CatchMonoLabel(
        selected ? 'Selected' : 'Resting',
        color: CatchTokens.of(context).ink2,
      ),
      for (final tab in <Widget>[
        const Tab(text: 'Overview'),
        const Tab(child: Text('Custom child')),
        Tab(icon: Icon(CatchIcons.check)),
        const Text('Caller-owned label'),
        const Tab(text: 'A long label that keeps the segment bounded'),
      ])
        SizedBox(
          height:
              CatchIconButton.targetExtentFor(CatchLayout.topBarTabHeight) +
              CatchSpacing.s4,
          child: CatchTopBarTabLabel(tab: tab, selected: selected),
        ),
    ],
  ],
);
