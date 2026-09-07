import 'package:catch_dating_app/core/widgets/catch_master_detail_layout.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Short and overflowing content',
  type: CatchFillViewportScrollView,
  path: '[Core patterns]/Viewport',
)
Widget fillViewportStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Viewport scrolling',
  catalogId: 'catch.screen_body.fill_viewport_scroll_view',
  children: [
    for (final tall in [false, true]) ...[
      CatchMonoLabel(
        tall ? 'Overflowing content' : 'Short content',
        color: CatchTokens.of(context).ink2,
      ),
      SizedBox(
        height: 180,
        child: CatchFillViewportScrollView(
          maxContentWidth: 280,
          child: SizedBox(
            height: tall ? 340 : null,
            child: ColoredBox(
              color: CatchTokens.of(context).primarySoft,
              child: Padding(
                padding: const EdgeInsets.all(CatchSpacing.s4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Start', style: CatchTextStyles.bodyM(context)),
                    Text('End', style: CatchTextStyles.bodyM(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ],
);

@widgetbook.UseCase(
  name: 'Bounded scene geometry',
  type: CatchSceneViewport,
  path: '[Core patterns]/Viewport',
)
Widget sceneViewportStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Scene viewport',
  catalogId: 'catch.screen_body.scene_viewport',
  children: [
    for (final maximum in [240.0, 520.0]) ...[
      CatchMonoLabel(
        'Maximum width ${maximum.toInt()}',
        color: CatchTokens.of(context).ink2,
      ),
      MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: const EdgeInsets.only(top: 24, bottom: 16)),
        child: SizedBox(
          height: 180,
          child: CatchSceneViewport(
            maxWidth: maximum,
            builder: (context, viewport) => WidgetbookLayoutPane(
              label:
                  '${viewport.width.toInt()} × ${viewport.height.toInt()}\n'
                  'Insets ${viewport.mediaPadding.top.toInt()} / '
                  '${viewport.mediaPadding.bottom.toInt()}',
            ),
          ),
        ),
      ),
    ],
  ],
);

@widgetbook.UseCase(
  name: 'Compact and split panes',
  type: CatchMasterDetailLayout,
  path: '[Core patterns]/Viewport',
)
Widget masterDetailStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Master and detail',
  catalogId: 'catch.screen_body.master_detail_layout',
  children: [
    for (final expanded in [false, true]) ...[
      CatchMonoLabel(
        expanded ? 'Split panes' : 'Compact pane',
        color: CatchTokens.of(context).ink2,
      ),
      WidgetbookLayoutViewport(
        size: Size(expanded ? 760 : 360, 180),
        child: CatchMasterDetailLayout(
          expanded: expanded,
          master: const WidgetbookLayoutPane(label: 'Index'),
          detail: const WidgetbookLayoutPane(label: 'Detail', accent: false),
        ),
      ),
    ],
  ],
);

@widgetbook.UseCase(
  name: 'Route body breakpoint',
  type: CatchAdaptiveMasterDetailLayout,
  path: '[Core patterns]/Viewport',
)
Widget adaptiveMasterDetailStates(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'Adaptive master and detail',
      catalogId: 'catch.screen_body.adaptive_master_detail_layout',
      children: [
        for (final width in [719.0, 720.0]) ...[
          CatchMonoLabel(
            'Route body ${width.toInt()}',
            color: CatchTokens.of(context).ink2,
          ),
          WidgetbookLayoutViewport(
            size: Size(width, 180),
            child: CatchAdaptiveMasterDetailLayout(
              minimumExpandedWidth: 720,
              masterBuilder: (context, expanded) => WidgetbookLayoutPane(
                label: expanded ? 'Split index' : 'Compact index',
              ),
              detail: const WidgetbookLayoutPane(
                label: 'Detail',
                accent: false,
              ),
            ),
          ),
        ],
      ],
    );

/// Keeps desktop layout constraints intact on a narrow review canvas.
class WidgetbookLayoutViewport extends StatelessWidget {
  const WidgetbookLayoutViewport({
    super.key,
    required this.size,
    required this.child,
  });

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: WidgetbookViewportFrame.device(size: size, child: child),
  );
}

/// Caller slot that makes the production layout's occupied area visible.
class WidgetbookLayoutPane extends StatelessWidget {
  const WidgetbookLayoutPane({
    super.key,
    required this.label,
    this.accent = true,
  });

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return ColoredBox(
      color: accent ? tokens.primarySoft : tokens.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(CatchSpacing.s4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: CatchTextStyles.bodyM(context),
          ),
        ),
      ),
    );
  }
}
