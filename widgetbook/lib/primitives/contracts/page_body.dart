import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

import '../../preview_layout_contracts.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchScaffold,
  path: '[Core primitives]/Sections',
)
Widget catchScreenScaffoldContractStates(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final t = CatchTokens.of(context);

  return CatchScaffold.standalone(
    body: WidgetbookContractFrame(
      title: 'CatchScaffold',
      contractId: 'catch.screen_body.screen_scaffold',
      states: const [
        'standalone-safe-area',
        'step-flow-safe-area',
        'workspace-owned-insets',
        'keyboard-resize',
      ],
      children: [
        const WidgetbookContractStateCard(
          label: 'role-owned surface',
          child: WidgetbookContractBodySpec(
            label: 'The named constructor owns surface and safe-area policy.',
          ),
        ),
        WidgetbookContractStateCard(
          label: 'keyboard-resize',
          description:
              'A simulated keyboard inset shortens the scaffold body so its '
              'bottom action remains above the obstruction.',
          child: WidgetbookContractBodyFrame(
            child: MediaQuery(
              data: mediaQuery.copyWith(
                viewInsets: const EdgeInsets.only(
                  bottom: WidgetbookPreviewLayout.compactPanelHeight,
                ),
              ),
              child: CatchScaffold.standalone(
                safeArea: CatchScaffoldPlacement.none,
                resizeToAvoidBottomInset: true,
                body: ColoredBox(
                  color: t.surface,
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: CatchInsets.content,
                      child: WidgetbookContractBodySpec(
                        label: 'Bottom action clears the keyboard inset.',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPageBody,
  path: '[Core primitives]/Sections',
)
Widget catchPageBodyContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'Page body recipes',
    contractId: 'catch.screen_body',
    states: const [
      'scrolling-gutter',
      'non-scroll',
      'no-gutter',
      'custom-padding',
      'page-insets',
      'form-step-insets',
      'sliver-insets',
      'standard-slivers',
      'full-bleed-slivers',
      'responsive-sliver-width',
    ],
    children: [
      WidgetbookContractStateCard(
        label: 'scrolling-gutter',
        child: WidgetbookContractBodyFrame(
          child: CatchPageBody.screen(
            child: CatchSectionList(
              emptyStateOmitted: true,
              gap: CatchGaps.section,
              children: const [
                WidgetbookContractBodySpec(label: 'Top section'),
                WidgetbookContractBodySpec(label: 'Scrollable body content'),
                WidgetbookContractBodySpec(
                  label: 'Bottom padding remains tokenized',
                ),
              ],
            ),
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'non-scroll',
        child: WidgetbookContractBodyFrame(
          child: CatchPageBody.screen(
            variant: CatchPageBodyVariant.fixed,
            child: WidgetbookContractBodySpec(
              label: 'Static body with standard gutter',
            ),
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'no-gutter',
        child: WidgetbookContractBodyFrame(
          child: CatchPageBody.screen(
            gutter: false,
            variant: CatchPageBodyVariant.fixed,
            pt: 0,
            pb: 0,
            child: WidgetbookContractBodySpec(
              label: 'Embedded body without page gutter',
            ),
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'custom-padding',
        child: WidgetbookContractBodyFrame(
          child: CatchPageBody.screen(
            variant: CatchPageBodyVariant.fixed,
            padding: EdgeInsets.all(CatchSpacing.s4),
            child: WidgetbookContractBodySpec(
              label: 'Body with explicit inset override',
            ),
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'page-insets',
        child: SizedBox(
          height: WidgetbookPreviewLayout.insetPreviewHeight,
          child: CatchPageBody(
            child: WidgetbookContractBodySpec(label: 'Inset page content'),
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'form-step-insets',
        child: SizedBox(
          height: WidgetbookPreviewLayout.insetPreviewHeight,
          child: CatchPageBody.formStep(
            child: WidgetbookContractBodySpec(label: 'Form step content'),
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'sliver-insets',
        child: WidgetbookContractBodyFrame(
          child: CustomScrollView(
            slivers: [
              CatchPageBody.sliver(
                child: SliverToBoxAdapter(
                  child: WidgetbookContractBodySpec(
                    label: 'Sliver page content',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      for (final mode in CatchPageBodyMode.values)
        WidgetbookContractStateCard(
          label: mode == CatchPageBodyMode.standard
              ? 'standard-slivers'
              : 'full-bleed-slivers',
          child: WidgetbookContractBodyFrame(
            child: CustomScrollView(
              slivers: [
                CatchPageBody.slivers(
                  mode: mode,
                  children: const [
                    SliverToBoxAdapter(
                      child: WidgetbookContractBodySpec(
                        label: 'Semantic sliver content',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      const WidgetbookContractStateCard(
        label: 'responsive-sliver-width',
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: WidgetbookViewportFrame.device(
            size: Size(760, 240),
            child: CustomScrollView(
              slivers: [
                CatchPageBody.slivers(
                  mode: CatchPageBodyMode.standard,
                  constrainToContentWidth: true,
                  maxContentExtent: 520,
                  children: [
                    SliverToBoxAdapter(
                      child: WidgetbookContractBodySpec(
                        label: 'Centered readable sliver lane',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
