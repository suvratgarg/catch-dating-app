import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Selection and contact indicators',
  type: CatchTabBarIndicator,
  path: '[Core primitives]/Navigation',
)
Widget tabBarIndicatorStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Tab selection and contact',
  catalogId: 'catch.tab_bar.indicator',
  children: [
    for (final state in [
      ('Selected', CatchOpacity.tabBarPillFill, false, false),
      ('Contact', CatchOpacity.tabBarPressedFill, false, false),
      ('Focused', CatchOpacity.tabBarFocusFill, true, false),
      ('Reduced motion focus', CatchOpacity.tabBarFocusFill, true, true),
    ]) ...[
      CatchMonoLabel(state.$1, color: CatchTokens.of(context).ink2),
      SizedBox(
        width: CatchLayout.tabBarMinimumTapExtent * 3,
        height: CatchLayout.tabBarIndicatorExtent,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: state.$4),
          child: CatchTabBarIndicator(
            color: CatchTokens.of(context).ink.withValues(alpha: state.$2),
            focused: state.$3,
          ),
        ),
      ),
    ],
  ],
);
