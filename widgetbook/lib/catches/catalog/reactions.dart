import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_reaction_controls.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Reaction control states',
  type: ProfileReactionControls,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesReactionControlStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ProfileReactionControls',
    contractId: 'screen.catches.event.reaction_controls',
    children: [
      WidgetbookPageStateCard(
        label: 'surface and overlay',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: Center(
            child: Wrap(
              spacing: CatchSpacing.s5,
              runSpacing: CatchSpacing.s4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: widgetbookCatchesNoopReaction,
                ),
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: widgetbookCatchesNoopReaction,
                  style: ProfileReactionControlsStyle.overlay,
                ),
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: widgetbookCatchesNoopReaction,
                  axis: Axis.vertical,
                ),
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: widgetbookCatchesNoopReaction,
                  enabled: false,
                ),
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: widgetbookCatchesNoopReaction,
                  isPending: true,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Reaction button states',
  type: ReactionControlButton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget reactionControlButtonStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ReactionControlButton',
    contractId: 'screen.catches.event.reaction_button',
    children: [
      WidgetbookPageStateCard(
        label: 'surface',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.compactPanelHeight,
          child: Center(
            child: ReactionControlButton(
              tooltip: 'Like prompt',
              icon: CatchIcons.favoriteBorderRounded,
              onPressed: widgetbookNoop,
              style: ProfileReactionControlsStyle.surface,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'overlay pending disabled',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.compactPanelHeight,
          child: Center(
            child: Wrap(
              spacing: CatchSpacing.s3,
              children: [
                ReactionControlButton(
                  tooltip: 'Comment on photo',
                  icon: CatchIcons.chatBubbleOutlineRounded,
                  onPressed: widgetbookNoop,
                  style: ProfileReactionControlsStyle.overlay,
                  isPending: true,
                ),
                ReactionControlButton(
                  tooltip: 'Like section unavailable',
                  icon: CatchIcons.favoriteBorderRounded,
                  onPressed: null,
                  style: ProfileReactionControlsStyle.surface,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Reaction comment sheet states',
  type: ProfileReactionCommentSheet,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileReactionCommentSheetStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ProfileReactionCommentSheet',
    contractId: 'screen.catches.event.reaction_comment_sheet',
    children: [
      WidgetbookPageStateCard(
        label: 'empty draft',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.catchesSkeletonPreviewHeight,
          child: ProfileReactionCommentSheet(target: _reactionTarget),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'filled draft',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.catchesSkeletonPreviewHeight,
          child: ProfileReactionCommentSheet(
            target: _reactionTarget,
            initialComment: 'Your sunrise loop sounds like my kind of Sunday.',
          ),
        ),
      ),
    ],
  );
}

const _reactionTarget = ProfileReactionTarget(
  id: 'design-catches-prompt',
  type: SwipeReactionTargetType.profilePrompt,
  label: 'prompt',
  preview:
      'Ask me about the bookshop detour I take after long runs and the breakfast order I defend every Sunday.',
);
