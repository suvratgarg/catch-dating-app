import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Fraction and absolute cap',
  type: CatchFractionalMaxWidth,
  path: '[Core primitives]/Layout',
)
Widget fractionalWidthStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Fractional content width',
  catalogId: 'catch.screen_body.fractional_max_width',
  children: [
    for (final fraction in [0.5, 1.0])
      CatchFractionalMaxWidth(
        fraction: fraction,
        maxWidth: 280,
        child: CatchSurface.card(
          child: Text(
            'Fraction $fraction; maximum 280',
            style: CatchTextStyles.bodyM(context),
          ),
        ),
      ),
  ],
);

@widgetbook.UseCase(
  name: 'Editable pager content',
  type: CatchPagerFocusBoundary,
  path: '[Core primitives]/Layout',
)
Widget pagerFocusStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Pager focus boundary',
  catalogId: 'catch.screen_body.pager_focus_boundary',
  children: const [
    CatchPagerFocusBoundary(
      child: CatchSurface.card(
        child: TextField(
          decoration: InputDecoration(labelText: 'Pager message'),
        ),
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Resting and transition poses',
  type: CatchFadeScaleViewport,
  path: '[Core primitives]/Motion',
)
Widget fadeScaleStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Fade and scale viewport',
  catalogId: 'catch.motion_viewport.fade_scale',
  children: [
    for (final value in [0.0, 0.5, 1.0])
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchMonoLabel(
            'Progress $value',
            color: CatchTokens.of(context).ink2,
          ),
          gapH8,
          CatchFadeScaleViewport(
            animation: AlwaysStoppedAnimation<double>(value),
            child: CatchSurface.card(
              child: Text(
                'Route content',
                style: CatchTextStyles.bodyM(context),
              ),
            ),
          ),
        ],
      ),
  ],
);

@widgetbook.UseCase(
  name: 'Transparent hero material',
  type: CatchHeroViewport,
  path: '[Core primitives]/Motion',
)
Widget heroViewportStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Hero viewport',
  catalogId: 'catch.motion_viewport.hero',
  children: [
    CatchHeroViewport(
      tag: 'hero-viewport-catalog',
      child: CatchSurface.card(
        child: Text(
          'Card flight surface',
          style: CatchTextStyles.bodyM(context),
        ),
      ),
    ),
  ],
);
